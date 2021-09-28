# these are the rules for doing the second mapping of just the
# likely colinear homologous query sequences
# against each of the separate target chromosomes






rule extract_homologous_query_sequences:
	input:
		qfasta = config["query_fasta"],
		fai = config["query_fasta"] + ".fai"
	params:
		homos = homologs_from_tchrom
	output:
		"results/second_mapping/queries-for-each-target/{tchrom}.fna"
	log:
		"results/log/extract_homologous_query_sequences/log.log"
	conda:
		"../envs/samtools.yaml"
	shell:
		"samtools faidx {input.qfasta} {params.homos} > {output} 2> {log}"




# now, our alignments will go into a MAF directory that 
# is inside "second_mapping", and also within
# a subdirectory that gives some of the parameters used, in
# case we want to twiddle those.
rule run_lastz_dos:
	input:
		target_fna = "results/target_chroms/{tchrom}.fna",
		query_fna = "results/second_mapping/queries-for-each-target/{tchrom}.fna"
	params:
		"--{trans}",
		"--step={step}",
		"--inner={inner}",
		"--identity={ident}",
		"--gapped --ambiguous=iupac --format=maf --chain"
	output:
		"results/second_mapping/MAF/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}.maf"
	log:
		"results/log/run_lastz_dos/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}_lastz.log"
	conda:
		"../envs/lastz.yaml"
	shell:
		"lastz {input} {params} > {output} 2> {log}"



# after getting the MAF file, we filter it down to single coverage, keeping
# only the highest-scoring alignment blocks.
rule run_single_cov2_dos:
	input:
		"results/second_mapping/MAF/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}.maf"
	output:
		"results/second_mapping/SCOV/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}.maf"
	log:
		"results/log/run_single_cov2_dos/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}_single_cov2.log"
	conda:
		"../envs/multiz.yaml"
	shell:
		"single_cov2 {input} > {output} 2> {log}"


		
