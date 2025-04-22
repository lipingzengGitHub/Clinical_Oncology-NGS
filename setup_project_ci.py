# Updated setup_project_ci.py for renamed pipeline: Clinical_Oncology-NGS.nf

import os

# Create test data directory and sample files
patient_dir = "Clinical_Oncology-NGS/test_data/Patient1"
os.makedirs(patient_dir, exist_ok=True)

# Minimal FASTQ content
fastq_data = "@SEQ_ID\nGATTTGGGGTTTAAAGGG\n+\nIIIIIIIIIIIIIIIIII\n"
gz_bytes = fastq_data.encode()

for name in ["tumor_R1", "tumor_R2", "normal_R1", "normal_R2"]:
    with open(f"{patient_dir}/{name}.fastq.gz", "wb") as f:
        f.write(gz_bytes)

# Create GitHub workflow directory
workflow_dir = "Clinical_Oncology-NGS/.github/workflows"
os.makedirs(workflow_dir, exist_ok=True)

# GitHub Actions CI workflow file
ci_yaml = """\
name: CI Test for Clinical Oncology NGS Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Install Java
        uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '11'

      - name: Install Nextflow
        run: |
          curl -s https://get.nextflow.io | bash
          sudo mv nextflow /usr/local/bin/

      - name: Run pipeline dry test
        run: |
          nextflow run Clinical_Oncology-NGS.nf \\
            --input_dir test_data \\
            --ref data/hg38.fa \\
            -profile docker \\
            -resume
"""

# Save CI workflow YAML
ci_path = os.path.join(workflow_dir, "test_pipeline.yml")
with open(ci_path, "w") as f:
    f.write(ci_yaml)

print("✅ Updated setup complete for Clinical_Oncology-NGS.nf with test data and GitHub CI workflow.")

