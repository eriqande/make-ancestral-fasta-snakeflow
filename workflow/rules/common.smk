
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