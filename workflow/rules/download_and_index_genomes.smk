

# note that torq is just a wildcard for something that should be either "target" or "query"
rule download_genome:
  params:
    url=genome_url_from_torq
  log:
    wget="resources/logs/download_genome/{torq}/wget.log",
    gunzip="resources/logs/download_genome/{torq}/gunzip.log"
  conda:
    "../envs/wget.yaml"
  output:
    fna="resources/genomes/{torq}/{torq}.fna"
  shell:
    "wget -O {output.fna}.gz {params.url} 2> {log.wget}; "
    " gunzip {output.fna}.gz  2> {log.gunzip}"


rule faidx_genome:
  input:
    fna="resources/genomes/{torq}/{torq}.fna"
  log:
    "resources/logs/faidx_genome/{torq}/faidx.log"
  conda:
    "../envs/samtools.yaml"
  output:
    "resources/genomes/{torq}/{torq}.fna.fai"
  shell:
    "samtools faidx {input.fna} 2> {log}"