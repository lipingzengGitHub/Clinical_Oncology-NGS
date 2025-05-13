# Clinical Oncology NGS Pipeline

This pipeline performs full **germline and somatic variant analysis** for oncology samples using WGS or WES data.  
Designed for both **clinical and scientific** use cases, it supports local, Docker, and AWS Batch environments.


## Features

- Germline & somatic SNP/Indel detection (GATK HaplotypeCaller / Mutect2)
- CNV detection using CNVkit or GATK CNV
- Structural variant (SV) detection via Manta
- Fusion detection (STAR-Fusion, optional)
- Variant annotation with ANNOVAR or VEP
- Integration with ClinVar, COSMIC, OncoKB
- Interactive HTML report (RMarkdown)
- JSON/PDF LIS-ready outputs
- AWS Batch and CloudWatch integration
- GitHub Actions CI for continuous testing


## Quickstart

### Run locally with Docker:

```bash
nextflow run Clinical_Oncology-NGS.nf -profile docker --input_dir data --ref data/hg38.fa
```

# Run with AWS Batch:
nextflow run Clinical_Oncology-NGS.nf -profile awsbatch --input_dir s3://your-bucket/data --ref s3://your-bucket/hg38.fa

### Input Structure
Each patient’s FASTQ files should be placed in a separate subdirectory under data/:
data/
├── Patient001/
│   ├── tumor_R1.fastq.gz
│   ├── tumor_R2.fastq.gz
│   ├── normal_R1.fastq.gz  # optional
│   └── normal_R2.fastq.gz

If normal_R1/R2.fastq.gz are provided, tumor-normal paired analysis is automatically triggered. Otherwise, tumor-only mode is used.

### Output Files
*.g.vcf.gz or *_mutect.vcf.gz – Germline or somatic variant calls

*_cnv.cns, *_manta.vcf.gz – CNV and SV results

*_annotated.txt – Annotated variant tables

report_*.html – Interactive reports

*.json, *.pdf – LIS-compatible summary reports

all_annotated_merged.tsv – Combined variant table across samples

### Project Structure
oncology-ngs-pipeline/
├── Clinical_Oncology-NGS.nf        # Main pipeline (Nextflow DSL2)
├── Dockerfile                      # Bioinformatics toolchain
├── Makefile                        # CLI automation
├── README.md                       # This file
├── CHANGELOG.md                    # Version history
├── setup_project_ci.py             # Test data + CI setup
├── assets/
│   └── report_template.Rmd         # HTML report template
├── bin/
│   └── lis_output_formatter.py     # JSON + PDF report output
├── test_data/                      # Minimal demo data
├── .github/
│   └── workflows/test_pipeline.yml # GitHub CI workflow


### Acknowledgements
Built using Nextflow, GATK, CNVkit, Manta, STAR-Fusion, ANNOVAR, and more.
Inspired by open-source efforts in clinical genomics and bioinformatics workflows.


