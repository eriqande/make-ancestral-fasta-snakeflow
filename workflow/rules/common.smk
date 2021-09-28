import pandas as pd

# these two lines are for testing.  Comment out before distribution
from snakemake.io import load_configfile
config = load_configfile("config/config.yaml")

configfile: "config/config.yaml"  


# read in the target chroms into a list
file = open(config["target_chroms"], "r")
tlist = file.read().split("\n")
file.close()
target_chroms = [i for i in tlist if i]  # remove empty strings  


# read in the query chroms into a space separated string
file = open(config["query_chroms"], "r")
tlist = file.read().split("\n")
file.close()
qlist = [i for i in tlist if i]  # remove empty strings  
query_chrom_string = ' '.join(qlist)


# here is a function to expand names from SCOV or MAF, which we call "trunk"
def agg_func1(wildcards, trunk, tc, ext):
	return expand(
		"results/{trunk}/step{step}_{trans}_inner{inner}_ident{ident}/{tc}.{ext}",
		trunk=trunk,
		step=wildcards.step,
		trans=wildcards.trans,
		inner=wildcards.inner,
		ident=wildcards.ident,
		tc=target_chroms,
		ext=ext
	)


# a function to get the genome URL according to whether we
# are requesting the target or the query
def genome_url_from_torq(wildcards):
	if wildcards.torq == "target":
		return config["target_url"]
	elif wildcards.torq == "query":
		return config["query_url"]
	else:
		return "UNEXPECTED TORQ VALUE"




# For the second mapping
if config["homolog_sets_csv"] != "NULL":
	homologs = pd.read_csv(config["homolog_sets_csv"]).set_index("target", drop=False)


# and here is a function to return the space separated
# string of homologs given a target
def homologs_from_tchrom(wildcards):
	return  homologs.loc[wildcards.tchrom, "homologs"]
