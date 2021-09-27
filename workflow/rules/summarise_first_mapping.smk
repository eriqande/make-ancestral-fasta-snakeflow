
rule calc_aligned_length:
	input:
		"results/SCOV/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}.maf"
	output:
		"results/SCOV/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}.aligned_lengths"
	shell:
		"workflow/scripts/count_aligned_bases.sh {wildcards.tchrom} {input} > {output}"



rule catenate_aligned_lengths:
	input:
		lambda wc: agg_func1(wildcards=wc, trunk="SCOV", tc=target_chroms, ext="aligned_lengths")
	output:
		"results/report/step{step}_{trans}_inner{inner}_ident{ident}/aligned_lengths.tsv"
	shell:
		"(echo -e 'target\tquery\tnum_bases\tfraction'; cat {input}) > {output}"
		
