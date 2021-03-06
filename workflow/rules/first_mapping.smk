# these are the rules for doing the first mapping of all the query sequences
# against each of the separate target chromosomes

rule split_target_fasta_by_chrom:
	input: 
		tfasta = config["target_fasta"],
		fai = config["target_fasta"] + ".fai"
	params:
		tc = "{tchrom}"
	output:
		"results/target_chroms/{tchrom}.fna"
	log:
		"results/logs/split_target_fasta_by_chrom/{tchrom}.log"
	conda:
		"../envs/samtools.yaml"
	shell:
		"samtools faidx {input.tfasta} {params.tc} > {output} 2> {log}"




rule extract_query_sequences:
	input:
		qfasta = config["query_fasta"],
		fai = config["query_fasta"] + ".fai"
	params:
		qc = query_chrom_string
	output:
		"results/query/query.fna"
	log:
		"results/log/extract_query_sequences/log.log"
	conda:
		"../envs/samtools.yaml"
	shell:
		"samtools faidx {input.qfasta} {params.qc} > {output} 2> {log}"




# now, our alignments will go into a MAF directory, within
# a subdirectory that gives some of the parameters used, in
# case we want to twiddle those.
rule run_lastz:
	input:
		target_fna = "results/target_chroms/{tchrom}.fna",
		query_fna = "results/query/query.fna"
	params:
		"--{trans}",
		"--step={step}",
		"--inner={inner}",
		"--identity={ident}",
		"--gapped --ambiguous=iupac --format=maf --chain"
	output:
		"results/MAF/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}.maf"
	log:
		"results/log/run_lastz/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}_lastz.log"
	conda:
		"../envs/lastz.yaml"
	shell:
		"lastz {input} {params} > {output} 2> {log}"



# after getting the MAF file, we filter it down to single coverage, keeping
# only the highest-scoring alignment blocks.
rule run_single_cov2:
	input:
		"results/MAF/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}.maf"
	output:
		"results/SCOV/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}.maf"
	log:
		"results/log/run_single_cov2/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}_single_cov2.log"
	conda:
		"../envs/multiz.yaml"
	shell:
		"single_cov2 {input} > {output} 2> {log}"


		
