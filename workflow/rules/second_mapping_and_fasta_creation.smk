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
		"results/log/extract_homologous_query_sequences/{tchrom}.log"
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



# convert the alignments into long sequences using multiz's maf2fasta
rule run_maf2fasta:
	input:
		target_fna = "results/target_chroms/{tchrom}.fna",
		maf = "results/second_mapping/SCOV/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}.maf"
	output:
		"results/maf2fasta/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}.fna"
	log:
		"results/log/run_maf2fasta/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}_maf2fasta.log"
	conda:
		"../envs/multiz.yaml"
	shell:
		"maf2fasta {input.target_fna} {input.maf} fasta  > {output} 2> {log}"




# massage the long sequences from run_maf2fasta into a single fasta file that
# is congruent with the original target chrom fasta.  Also print out a summary
# of the number of different aligned base pairs.
rule condense_anc_fastas:
	input:
		maf2fasta = "results/maf2fasta/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}.fna"
	output:
		anc_fasta = "results/ancestral_fastas/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}.fna",
		bp_pairs = "results/pairwise_base_counts/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}.csv"
	log:
		"results/log/condense_anc_fastas/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}_condense_anc_fasta.log"
	envmodules:
		"R/4.0.3" # this is for SEDNA
	script:
		"../scripts/condense-and-summarise-fastas.R"


rule catenate_anc_fastas:
	input:
		lambda wc: agg_func1(wildcards=wc, trunk="ancestral_fastas", tc=target_chroms, ext="fna")
	output:
		"results/catenated_anc_fasta/step{step}_{trans}_inner{inner}_ident{ident}/ancestral.fna"
	log:
		"results/log/catenate_anc_fastas/step{step}_{trans}_inner{inner}_ident{ident}/stderr.log"
	shell:
		"cat {input} > {output} 2> {log}"



rule catenate_pairwise_aligned_base_summaries:
	input:
		lambda wc: agg_func1(wildcards=wc, trunk="pairwise_base_counts", tc=target_chroms, ext="csv")
	output:
		"results/report/step{step}_{trans}_inner{inner}_ident{ident}/pairwise_aligned_base_summary.csv"
	log:
		"results/log/catenate_pairwise_aligned_base_summaries/step{step}_{trans}_inner{inner}_ident{ident}/stderr.log"
	shell:
		"awk 'NR==1 {{header=$0; print; next}} $0==header {{next}} {{print}}' {input} > {output} 2> {log} "


		
