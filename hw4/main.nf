
nextflow.enable.dsl = 2

// Load parameters
params.global_params = [
    outdir: "./test_output",
    threads: 8
]

params.fastqc = [
    threads: 8
]

params.spades = [
    threads: 4
]

params.quast = [
    outdir: "params.global_params.outdir",
    threads: 4

]

params.prokka = [
    prefix: "annotation"
]

params.abricate = [
    outdir: "params.global_params.outdir"
    
]

// Parse samples.csv
Channel
    .fromPath('samples.csv')
    .splitCsv(header: true)
    .map { row ->
        [
            row.sample_id,
            row.read_1 ? file(row.read_1) : null,
            row.read_2 ? file(row.read_2) : null,
            row.assembly ? file(row.assembly) : null
        ]
    }
    .set { samples }

// Define processes

process fastqc {

    publishDir "${params.global_params.outdir}/fastqc", mode: 'copy'

    input:
    tuple val(sample_id), path(reads_1), path(reads_2)

    output:
    path("${params.global_params.outdir}/fastqc_${sample_id}")

    script:
    """
    mkdir -p ${params.global_params.outdir}/fastqc_${sample_id}
    fastqc ${reads_1} ${reads_2} -o ${params.global_params.outdir}/fastqc_${sample_id} -t ${params.fastqc.threads}
    """

}

process spades {

    publishDir "${params.global_params.outdir}/spades", mode: 'copy'

    input:
    tuple val(sample_id), path(reads_1), path(reads_2)

    output:
    tuple val(sample_id), path("${params.global_params.outdir}/spades_${sample_id}/contigs.fasta")

    script:
    """
    mkdir -p ${params.global_params.outdir}/spades_${sample_id}
    spades.py -1 ${reads_1} -2 ${reads_2} -o ${params.global_params.outdir}/spades_${sample_id} --threads ${params.spades.threads} --memory 10
    """
}


process quast {

    publishDir "${params.global_params.outdir}/quast", mode: 'copy'

    input:
    tuple val(sample_id), path(assembly)

    output:
    path("${params.quast.outdir}/quast_${sample_id}")

    script:
    """
    mkdir -p ${params.quast.outdir}/quast_${sample_id}
    quast.py ${assembly} -o ${params.quast.outdir}/quast_${sample_id} --threads ${params.quast.threads}
    """
    
}

process prokka {

    publishDir "${params.global_params.outdir}/prokka", mode: 'copy'
    
    input:
    tuple val(sample_id), path(assembly)

    output:
    path("${params.global_params.outdir}/prokka_${sample_id}")

    script:
    """
    prokka --outdir ${params.global_params.outdir}/prokka_${sample_id} --prefix ${params.prokka.prefix}_${sample_id} ${assembly}
    """
}

process abricate {

    publishDir "${params.global_params.outdir}/abricate", mode: 'copy'
    
    input:
    tuple val(sample_id), path(assembly)

    output:
    path("${params.abricate.outdir}/abricate_${sample_id}")

    script:
    """
    mkdir -p ${params.abricate.outdir}/abricate_${sample_id}
    abricate --db resfinder ${assembly} > ${params.abricate.outdir}/abricate_${sample_id}/results.txt
    """
    
}

// Define workflow

workflow {
    // Separate samples
    samples
        .filter { sample_id, read_1, read_2, assembly -> !assembly } // Samples with reads
        .set { samples_with_reads }

    samples
        .filter { sample_id, read_1, read_2, assembly -> assembly } // Samples with assemblies
        .set { samples_with_assembly }

    // Debug channels
    samples_with_reads.view { "Samples with reads: $it" }
    samples_with_assembly.view { "Samples with assemblies: $it" }

    samples_with_reads
        .filter { sample_id, read_1, read_2, assembly -> !assembly }
        .set { samples_with_reads }

    samples_with_assembly
        .filter { sample_id, read_1, read_2, assembly -> assembly }
        .set { samples_with_assembly }

    // 2. Подготовка входных данных для процессов
    // Для FastQC и SPAdes нужны риды
    paired_reads = samples_with_reads.map { sample_id, read_1, read_2, assembly ->
        tuple(sample_id, read_1, read_2)
    }

    // 3. Запуск процессов первого уровня
    fastqc(paired_reads)
    spades(paired_reads)

    // 4. Обработка выходных данных SPAdes и объединение с готовыми сборками
    assemblies_from_spades = spades.out.map { sample_id, assembly ->
        tuple(sample_id, assembly)
    }

    assemblies_from_input = samples_with_assembly.map { sample_id, read_1, read_2, assembly ->
        tuple(sample_id, assembly)
    }

    // 5. Объединение всех сборок для следующих процессов
    all_assemblies = assemblies_from_spades.mix(assemblies_from_input)

    // 6. Запуск процессов для анализа сборок
    quast(all_assemblies)
    prokka(all_assemblies)
    abricate(all_assemblies)
}