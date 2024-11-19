# Bacterial Genome Analysis Pipeline

This Snakemake pipeline performs comprehensive analysis of bacterial genome data, including quality control, assembly, and annotation steps. The pipeline can handle both raw sequencing data and pre-assembled genomes.

## Overview

The pipeline performs the following analyses:
- Quality control of raw reads (FastQC)
- De novo genome assembly (SPAdes)
- Assembly quality assessment (QUAST)
- Genome annotation (Prokka)
- Antimicrobial resistance gene detection (ABRicate)

## Prerequisites

### Software Requirements
- Snakemake
- Conda (for managing tool environments)

### Required Tools (installed via conda environments)
- FastQC
- SPAdes
- QUAST
- Prokka
- ABRicate

## Input Files Setup

### Directory Structure
```
.
├── samples.csv
├── params.json
├── envs/
│   ├── fastqc.yaml
│   ├── spades.yaml
│   ├── quast.yaml
│   ├── prokka.yaml
│   └── abricate.yaml
└── test_input/
    └── [input files]
```

### samples.csv Format
The `samples.csv` file should contain the following columns:
```csv
sample_id,read_1,read_2,assembly
sample1,/path/to/sample1_R1.fastq,/path/to/sample1_R2.fastq,
sample2,/path/to/sample2_R1.fastq,/path/to/sample2_R2.fastq,
sample3_assembly,,,/path/to/sample3.fasta
```

Notes:
- For raw sequencing data: provide `read_1` and `read_2` paths
- For pre-assembled genomes: add `_assembly` suffix to `sample_id` and provide `assembly` path
- Paths can be relative or absolute

### params.json Configuration
```json
{
  "global_params": {
    "outdir": "./results"
  },
  "fastqc": {
    "threads": 4
  },
  "spades": {
    "threads": 8
  },
  "prokka": {
    "prefix": "annotation"
  }
}
```

## Output Files

The pipeline generates the following directory structure for each sample:

For samples with raw reads:
```
results/
├── {sample}_fastqc/
│   ├── {sample}_1_fastqc.html
│   └── {sample}_2_fastqc.html
├── {sample}_spades/
│   └── scaffolds.fasta
├── {sample}_quast/
│   └── report.html
├── {sample}_prokka/
│   └── annotation.txt
└── {sample}_abricate/
    ├── ncbi_results.txt
    └── resfi_results.txt
```

For pre-assembled samples:
```
results/
├── {sample}_assembly_quast/
│   └── report.html
├── {sample}_assembly_prokka/
│   └── annotation.txt
└── {sample}_assembly_abricate/
    ├── ncbi_results.txt
    └── resfi_results.txt
```

## Running the Pipeline

### Basic Usage
```bash
snakemake --cores N --use-conda
```

### Common Options
- `--cores N`: Specify number of cores to use
- `--use-conda`: Activate conda environment management
- `--dryrun`: Show execution plan without running
- `--printshellcmds`: Print shell commands that will be executed

### Examples
1. Dry run to check workflow:
```bash
snakemake -n --use-conda
```

2. Run with 8 cores:
```bash
snakemake --cores 8 --use-conda
```

3. Run specific rule for a sample:
```bash
snakemake --cores 1 --use-conda results/sample1_fastqc/sample1_1_fastqc.html
```

## Tool-specific Parameters

### FastQC
- Threads: Configured in params.json
- Output: HTML quality reports for each read file

### SPAdes
- Threads: Configured in params.json
- Input: Paired-end reads
- Output: Assembled scaffolds in FASTA format

### QUAST
- Input: Assembly file (either from SPAdes or provided)
- Output: HTML report with assembly statistics

### Prokka
- Prefix: Configured in params.json
- Input: Assembly file
- Output: Annotation files including GFF and FASTA

### ABRicate
- Databases: NCBI and ResFinder
- Input: Assembly file
- Output: Text files with identified resistance genes

## Notes

- The pipeline automatically detects whether a sample needs assembly (based on presence of raw reads) or starts from a provided assembly
- All paths in the output are determined by the `outdir` parameter in params.json
- Each tool runs in its own conda environment to manage dependencies
