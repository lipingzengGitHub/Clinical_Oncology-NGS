# 📦 CHANGELOG

## [v1.0.0] – Initial Release

### Added
- Full pipeline: `Clinical_Oncology-NGS.nf`
- Support for both tumor-only and tumor-normal paired modes
- Germline and somatic variant calling (GATK HaplotypeCaller / Mutect2)
- CNV detection using CNVkit
- Structural variant detection using Manta
- Variant annotation via ANNOVAR
- Interactive clinical reports via RMarkdown
- JSON + PDF output for LIS integration
- GitHub Actions CI support
- Demo test data generator (`setup_project_ci.py`)
- Dockerfile with all required tools

