# DD_2024 — Data-Driven Tools (MSc coursework)

Coursework for the *Development Tools for Data-Driven Solutions* module of the Applied Genomics MSc,
ITMO University (2024). The repository is kept as a record of the assignments;
it is not a maintained tool.

The main content is one bacterial-genome pipeline implemented twice, in
Snakemake and in Nextflow, so that the two workflow managers could be compared
on the same task.

## Pipeline

Reads → FastQC → SPAdes → QUAST → Prokka → ABRicate

Each sample is described by one row of `samples.csv`. A row may provide paired
reads (the full pipeline runs) or a ready assembly (QC and assembly are skipped
and only QUAST, Prokka and ABRicate run).

| Directory | What it is |
|---|---|
| `hw3/` | Snakemake implementation. One conda environment per tool (`envs/`), parameters in `params.json`. See [`hw3/README.md`](hw3/README.md). |
| `hw4/` | Nextflow DSL2 implementation of the same pipeline. Tools run in Biocontainers/StaPH-B Docker images (`nextflow.config`). See [`hw4/README.md`](hw4/README.md). |
| `hw2/` | The same steps run by hand before automating them; `lab_journal.ipynb` records commands and outputs. |
| `exam/` | Course exam: FastQC and QUAST on a provided dataset. |

## Quick start

```bash
# Snakemake (conda)
cd hw3
snakemake --cores 8 --use-conda

# Nextflow (Docker)
cd hw4
nextflow run main.nf
```

Both directories ship a small `test_input/` (two paired-end samples, one of
them also as a pre-built assembly) and write to `test_output/`.

## Requirements

- Snakemake ≥ 7 and conda/mamba, **or** Nextflow ≥ 23 (DSL2) and Docker
- Tools are pulled automatically: FastQC, SPAdes, QUAST, Prokka, ABRicate

## Author

Elizaveta Cociubei (Kochubei) — github.com/ktsel
