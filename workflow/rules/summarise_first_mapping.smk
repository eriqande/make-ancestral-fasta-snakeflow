
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
		

rule make_plotable_segments:
	input:
		"results/SCOV/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}.maf"
	output:
		"results/SCOV/step{step}_{trans}_inner{inner}_ident{ident}/{tchrom}.segments"
	shell:
		"workflow/scripts/plotable-segs-from-maf.sh {input} > {output}"


rule catenate_plotable_segments:
	input:
		lambda wc: agg_func1(wildcards=wc, trunk="SCOV", tc=target_chroms, ext="segments")
	output:
		"results/report/step{step}_{trans}_inner{inner}_ident{ident}/plotable_segments.tsv"
	shell:
		"(echo -e 'target\ttstart\ttend\ttstrand\tquery\tqstart\tqend\tqstrand'; cat {input}) > {output}"
