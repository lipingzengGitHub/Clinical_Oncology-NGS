# 🧬 Clinical Oncology NGS Pipeline

This pipeline performs a comprehensive clinical-grade analysis of whole genome/exome sequencing (WGS/WES) data for oncology patients. It supports both **tumor-only** and **tumor-normal paired** analysis, with built-in variant calling, structural analysis, annotation, and report generation.

Project Structure:
Clinical_Oncology-NGS/
├── Clinical_Oncology-NGS.nf
├── Dockerfile
├── Makefile         
├── README.md
├── CHANGELOG.md
├── test_data/
├── assets/
└── .github/


## 🔧 Features

- Supports tumor-only or tumor-normal input per patient
- Automatic detection of sample type from folder structure
- Parallel processing of multiple patients
- Variant detection:
  - Germline (GATK HaplotypeCaller)
  - Somatic (GATK Mutect2)
  - Structural variants (Manta)
  - Copy number variants (CNVkit)
  - Fusions (optional)
- Variant annotation (ANNOVAR)
- HTML clinical reports (RMarkdown)
- LIS-compatible output (JSON/PDF)
- Docker & AWS Batch support
- GitHub Actions CI for automated testing



## 📁 Input Structure

Each patient’s FASTQ files should be placed in their own subdirectory under `data/`.
data/
├── Patient001/
│   ├── tumor_R1.fastq.gz       # required
│   ├── tumor_R2.fastq.gz       # required
│   ├── normal_R1.fastq.gz      # optional (for paired mode)
│   └── normal_R2.fastq.gz      # optional
├── Patient002/
│   ├── tumor_R1.fastq.gz
│   ├── tumor_R2.fastq.gz




## 🚀 Quick Start

### Run with Docker
```bash
nextflow run Clinical_Oncology-NGS.nf -profile docker \
  --input_dir data \
  --ref data/hg38.fa


#Run on AWS Batch
nextflow run Clinical_Oncology-NGS.nf -profile awsbatch \
  --input_dir s3://your-bucket/data \
  --ref s3://your-bucket/hg38.fa


📦 Outputs
*.vcf.gz – Raw variant calls (somatic/germline)

*_annotated.txt – Variant annotation

report_*.html – Clinical HTML reports

*.json, *.pdf – LIS-compatible exports

all_annotated_merged.tsv – Summary of all annotated variants


🧪 Test Locally
python setup_project_ci.py
# This generates minimal test data and enables CI testing with GitHub Actions.






