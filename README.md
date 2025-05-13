# Cancer-WGS-Variant-Calling Pipeline

A modular, Dockerized **Nextflow** pipeline for analyzing **whole genome sequencing (WGS)** data from cancer patients, supporting both **tumor-normal paired analysis** and **tumor-only mode**. The workflow is designed to simulate clinical-grade variant analysis, integrating quality control, alignment, somatic/germline variant calling, annotation, and reporting.

---

## Features

- ✅ Supports both **paired tumor-normal** and **tumor-only** input modes
- ✅ Variant calling using **GATK Mutect2** (somatic) and **HaplotypeCaller** (germline)
- ✅ Quality control with **FastQC** and adapter trimming via **Trimmomatic**
- ✅ Read alignment using **BWA**, BAM processing with **SAMtools**, and deduplication using **GATK MarkDuplicates**
- ✅ Annotation with **ANNOVAR** against public cancer-related databases (ClinVar, COSMIC)
- ✅ Report generation via **RMarkdown** (HTML) and LIS-compatible outputs (PDF, JSON)
- 🧪 Designed for benchmarking, training, and prototyping of cancer genomics workflows

---

## Workflow Overview

```mermaid
flowchart TD
    A[FASTQ Input] --> B{Paired or Tumor-only}
    B -->|Paired| C1[Tumor & Normal Alignment]
    B -->|Tumor-only| C2[Tumor Alignment]
    C1 --> D1[Somatic Variant Calling<br>Mutect2]
    C2 --> D2[Germline Variant Calling<br>HaplotypeCaller]
    D1 & D2 --> E[Variant Annotation<br>ANNOVAR]
    E --> F[Report Generation<br>R Markdown, PDF, JSON]
    F --> G[All Results Merged]
