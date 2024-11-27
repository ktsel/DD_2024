# Nextflow Pipeline for Genome Assembly and Annotation

This Nextflow pipeline automates the process of genome assembly, quality assessment, and annotation using various bioinformatics tools. 
The pipeline includes steps for quality control of raw reads, genome assembly, quality assessment of the assembly, gene annotation, and identification of resistance and virulence genes.

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Input Files](#input-files)
- [Output Files](#output-files)
- [Parameters](#parameters)
- [Running the Pipeline](#running-the-pipeline)
- [Example Commands](#example-commands)

## Overview

The pipeline consists of the following steps:

1. **Quality Control (FastQC)**: Assesses the quality of raw sequencing reads.
2. **Genome Assembly (SPAdes)**: Assembles raw reads into contigs.
3. **Quality Assessment (QUAST)**: Evaluates the quality of the assembled genome.
4. **Gene Annotation (Prokka)**: Annotates the assembled genome.
5. **Gene Identification (Abricate)**: Identifies resistance and virulence genes in the annotated genome.

## Requirements

- [Nextflow](https://www.nextflow.io/)
- [Docker](https://www.docker.com/) (optional, for containerized execution)
- [Conda](https://docs.conda.io/en/latest/) (optional, for environment management)

## Input Files

The pipeline expects a CSV file (`samples.csv`) with the following columns:

- `sample_id`: Unique identifier for the sample.
- `read_1`: Path to the forward read file (e.g., `sample_R1.fastq.gz`).
- `read_2`: Path to the reverse read file (e.g., `sample_R2.fastq.gz`).
- `assembly`: Path to the pre-assembled genome file (optional).

Example `samples.csv`:

```csv
sample_id,read_1,read_2,assembly
sample1,/path/to/sample1_R1.fastq.gz,/path/to/sample1_R2.fastq.gz,
sample2,/path/to/sample2_R1.fastq.gz,/path/to/sample2_R2.fastq.gz,/path/to/sample2_assembly.fasta
```

## Output Files

The pipeline generates the following output directories:

- `test_output/fastqc`: FastQC reports.
- `test_output/spades`: SPAdes assembly results.
- `test_output/quast`: QUAST quality assessment reports.
- `test_output/prokka`: Prokka annotation results.
- `test_output/abricate`: Abricate resistance and virulence gene identification results.

## Parameters

The pipeline uses the following parameters:

- `global_params.outdir`: Output directory for all results (default: `./test_output`).
- `global_params.threads`: Number of threads to use for parallel processing (default: `8`).
- `fastqc.threads`: Number of threads for FastQC (default: `8`).
- `spades.threads`: Number of threads for SPAdes (default: `4`).
- `quast.outdir`: Output directory for QUAST results (default: `params.global_params.outdir`).
- `quast.threads`: Number of threads for QUAST (default: `4`).
- `prokka.prefix`: Prefix for Prokka output files (default: `annotation`).
- `abricate.outdir`: Output directory for Abricate results (default: `params.global_params.outdir`).

## Running the Pipeline

To run the pipeline, use the following command:

```bash
nextflow run main.nf --with-docker
