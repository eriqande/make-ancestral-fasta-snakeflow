make-ancestral-fasta-snakeflow
================

For a lot of interesting population genomics work today, it is necessary
or useful to know which allele at a SNP is derived, and which is
ancestral in the species under study. For many cases, that information
can be obtained (or at least approximated) by finding the base carried
at each such site in a closely related species.

For both the program [ANGSD](http://www.popgen.dk/angsd/index.php/ANGSD)
and the more recently developed software
[RELATE](https://myersgroup.github.io/relate/) this information about
ancestral alleles/bases can be input to the programs as a fasta file of
the same length as the focal species fasta file, but just having the
sequence of the closely related species.

It seems to me that there are not a lot of really great workflows for
creating such fasta files. That is what I am trying to provide here. My
main goal for it is aligning large chunks of genomes between closely
related salmonid species, and then creating fasta files giving the
ancestral alleles.

For example, if I have a lot of high-quality, whole-genome sequencing
from *O. mykiss* that I want to phase and throw into RELATE, I can align
the Chinook salmon genome to the *O. mykiss* genome and use that to make
the ancestral fasta. In this case, we say that the *O. mykiss* genome is
our *target* genome, and Chinook salmon is our *query* genome. For the
most part, I am most interested in segments that have been assembled
into chromosomes in both species.

In brief, the approach is this:

1.  Choose the target genome and declare which sequences in that you
    want to map align things to. For my purposes this is typically the
    assembled chromosomes.
2.  Choose the query genome and declare which sequences from the query
    you wish to map to the target. Once again, this is typically the
    assembled chromosomes, though one might wish to use all the
    sequences, even those that are not fully assembled into chromosomes.
3.  Break the target genome into a bunch of smaller fastas, each
    containing exactly one of the sequences. We will call these
    “single-chromosome fastas.”
4.  Map all the query sequences against each of the single-chromosome
    fastas.
5.  Run single\_cov2 on each of resulting MAFs, so that we retain only
    the very best alignment for each.
6.  Run maf2fasta (from the multiz package) on each the resulting
    single\_cov outputs.
7.  Use an R-script to condense the resulting fastas into things that
    are congruent with the target genome.
8.  Catenate all the those condensed fastas.

Along the way, we also generate a big faceted dotplot that shows the
alignment across different chromosomes, and we generate some statistics.

This workflow is set up showing the default values used for mapping the
Chinook genome (the query) to the *O. mykiss* genome (our target). You
can change values in the `config/config.yaml` file to work for your own
pair of closely related species.
