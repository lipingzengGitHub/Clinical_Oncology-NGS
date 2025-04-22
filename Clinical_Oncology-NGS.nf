#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.input_dir = "data"
params.ref = "data/hg38.fa"
params.mode = "auto"  // or "paired" or "tumor_only"
params.fusion_enabled = false

Channel
    .fromPath("${params.input_dir}/*")
    .map { folder -> tuple(folder.getName(), folder) }
    .set { patient_dirs }

workflow {

    patient_dirs
        | map { patient_id, folder ->
            def tumor_r1 = folder.resolve("tumor_R1.fastq.gz")
            def tumor_r2 = folder.resolve("tumor_R2.fastq.gz")
            def normal_r1 = folder.resolve("normal_R1.fastq.gz")
            def normal_r2 = folder.resolve("normal_R2.fastq.gz")
            def mode = params.mode == "auto" ?
                        ((normal_r1.exists() && normal_r2.exists()) ? "paired" : "tumor_only") :
                        params.mode
            tuple(patient_id, mode, tumor_r1, tumor_r2, normal_r1, normal_r2)
        }
        | set { samples }

    samples
        | branch (
            paired: { it[1] == "paired" },
            tumor_only: { it[1] == "tumor_only" }
        )

    paired
        | map { id, _, t_r1, t_r2, n_r1, n_r2 -> tuple(id, [t_r1, t_r2], [n_r1, n_r2]) }
        | processPairedPatient
        | set { somatic_vcf }

    tumor_only
        | map { id, _, t_r1, t_r2, _, _ -> tuple(id, [t_r1, t_r2]) }
        | processTumorOnlyPatient
        | set { germline_vcf }

    somatic_vcf.into { vcf_ann1 }
    germline_vcf.into { vcf_ann2 }

    vcf_ann1.concat(vcf_ann2)
        | annotate_variants
        | generate_report

    annotate_variants.out
        | format_lis_output

    annotate_variants.out
        | collect()
        | merge_annotations
}

workflow.onComplete {
    println "✅ Pipeline completed successfully at ${workflow.complete}"
}


process processPairedPatient {
    tag "$patient_id"
    input:
    val patient_id
    path tumor_reads
    path normal_reads
    output:
    path("${patient_id}_mutect2.vcf.gz"), emit: somatic_vcf
    script:
    """
    echo "Processing $patient_id (paired mode)"

    fastqc ${tumor_reads[0]} ${tumor_reads[1]} -o .
    fastqc ${normal_reads[0]} ${normal_reads[1]} -o .

    trimmomatic PE -phred33 \\
      ${tumor_reads[0]} ${tumor_reads[1]} tumor_trim_R1.fq.gz discard1.fq.gz \\
      tumor_trim_R2.fq.gz discard2.fq.gz \\
      ILLUMINACLIP:/opt/trimmomatic/adapters/TruSeq3-PE.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:50

    bwa mem ${params.ref} tumor_trim_R1.fq.gz tumor_trim_R2.fq.gz > tumor.sam
    bwa mem ${params.ref} ${normal_reads[0]} ${normal_reads[1]} > normal.sam

    samtools view -Sb tumor.sam | samtools sort -o tumor.bam
    samtools index tumor.bam
    samtools view -Sb normal.sam | samtools sort -o normal.bam
    samtools index normal.bam

    gatk MarkDuplicates -I tumor.bam -O tumor.dedup.bam -M tumor.metrics
    samtools index tumor.dedup.bam
    gatk MarkDuplicates -I normal.bam -O normal.dedup.bam -M normal.metrics
    samtools index normal.dedup.bam

    gatk Mutect2 \\
      -R ${params.ref} \\
      -I tumor.dedup.bam -tumor ${patient_id} \\
      -I normal.dedup.bam -normal ${patient_id}_normal \\
      -O ${patient_id}_mutect2.vcf.gz
    """
}


process processTumorOnlyPatient {
    tag "$patient_id"
    input:
    val patient_id
    path tumor_reads
    output:
    path("${patient_id}.g.vcf.gz"), emit: germline_vcf
    script:
    """
    echo "Processing $patient_id (tumor-only)"

    fastqc ${tumor_reads[0]} ${tumor_reads[1]} -o .

    trimmomatic PE -phred33 \\
      ${tumor_reads[0]} ${tumor_reads[1]} trim_R1.fq.gz trash1.fq.gz \\
      trim_R2.fq.gz trash2.fq.gz \\
      ILLUMINACLIP:/opt/trimmomatic/adapters/TruSeq3-PE.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:50

    bwa mem ${params.ref} trim_R1.fq.gz trim_R2.fq.gz > tumor.sam
    samtools view -Sb tumor.sam | samtools sort -o tumor.bam
    samtools index tumor.bam

    gatk MarkDuplicates -I tumor.bam -O tumor.dedup.bam -M metrics.txt
    samtools index tumor.dedup.bam

    gatk HaplotypeCaller \\
      -R ${params.ref} \\
      -I tumor.dedup.bam \\
      -O ${patient_id}.g.vcf.gz \\
      -ERC GVCF
    """
}


process annotate_variants {
    tag "$vcf.simpleName"
    input:
    path vcf
    output:
    path("${vcf.simpleName}_annotated.txt")
    script:
    """
    table_annovar.pl ${vcf} /annovar/humandb/ \\
      -buildver hg38 \\
      -out ${vcf.simpleName}_annotated \\
      -remove \\
      -protocol refGene,clinvar_20210501,cosmic70 \\
      -operation g,f,f \\
      -nastring . \\
      -vcfinput
    """
}


process generate_report {
    tag "$annot_file.simpleName"
    input:
    path annot_file
    output:
    path("report_${annot_file.simpleName}.html")
    script:
    """
    Rscript -e "rmarkdown::render('assets/report_template.Rmd', params=list(annot_file='${annot_file}'), output_file='report_${annot_file.simpleName}.html')"
    """
}


process format_lis_output {
    tag "$annot_file.simpleName"
    input:
    path annot_file
    output:
    path("${annot_file.simpleName}.json")
    path("${annot_file.simpleName}.pdf")
    script:
    """
    python3 bin/lis_output_formatter.py ${annot_file}
    """
}


process merge_annotations {
    input:
    path(annotated_files)
    output:
    path("all_annotated_merged.tsv")
    script:
    """
    head -n 1 ${annotated_files[0]} > all_annotated_merged.tsv
    for file in ${annotated_files[@]}; do
      tail -n +2 \$file >> all_annotated_merged.tsv
    done
    """
}


