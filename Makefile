# Makefile for Clinical Oncology NGS Pipeline

.PHONY: run test report clean help

# Run the pipeline on actual data
run:
	nextflow run Clinical_Oncology-NGS.nf -profile docker --input_dir data --ref data/hg38.fa

# Generate test data and GitHub Actions CI workflow
test:
	python setup_project_ci.py

# Open HTML reports (macOS/Linux compatible)
report:
	open report_*.html || xdg-open report_*.html || echo "Please open report manually."

# Remove intermediate and output files (use with caution)
clean:
	rm -rf work .nextflow* *.html *.vcf.gz *.bam *.sam *.cns *.txt *.json *.pdf *.tsv manta_* report_*

# Help menu
help:
	@echo "Usage:"
	@echo "  make run      Run the main pipeline"
	@echo "  make test     Generate test data and CI setup"
	@echo "  make report   Open generated reports"
	@echo "  make clean    Delete intermediate/output files"







