make-ancestral-fasta-snakeflow
================

For a lot of interesting population genomics work today, it is necessary
or useful to know which allele at a SNP is derived, and which is
ancestral in the species under study. For many cases, that information
can be obtained (or at least approximated) by finding the base carried
at each such site in a closely related species. I imagine that there are
some purists that would recommend getting as many closely related
species as possible, putting them all on a phylogenetic tree, along with
the focal species, and the doing a gigantic, genome-wide multiple
alignment and then infer the ancestral states at each position from all
that information, and then use that. That sounds like a lot of work when
you are trying to get a whole genome’s worth of ancestral states, and in
many cases you might not have a whole lot of genomes to work with,
anyway. So, here, I will take a cue from an ANGSD website example
[here](http://www.popgen.dk/angsd/index.php/Thetas,Tajima,Neutrality_tests)
where they use chimpanzee to designate ancestral states so as to
polarize the site frequency spectrum.

For both the program [ANGSD](http://www.popgen.dk/angsd/index.php/ANGSD)
and the more recently developed software
[RELATE](https://myersgroup.github.io/relate/) this information about
ancestral alleles/bases can be input to the programs as a fasta file of
the same length as the focal species fasta file, but just including the
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
    want to align things to. For my purposes this is typically the
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
    the very best alignment of any overlapping alignments.
6.  Summarize how many base pairs are aligned onto each
    single-chromosome fasta from each of the different target query
    sequences (i.e. chromosomes). This is accomplished by running the
    workflow to this point with a command like:

``` bash
snakemake --cores 20   --use-conda  results/report/step20_notransition_inner1000_ident92/aligned_lengths.tsv
```

Note that the above command, by way of its directory name, is requesting
the following options be passed to `lastz`:
`--steps=20 --notransition --inner=1000 --identity=92.` Users wanting
different values of those parameters can simply request the output file
in a different directory, like `step15_notransition_inner950_ident97`.

At this point, there needs to be some user interaction. The user can
look at the output of the last step above and identify obvious homology
relationships between the chromosomes in the two species, according to
what fraction of the total length of aligned bases on each target
chromosome come from each of the different query sequences. Probably the
easiest way to do that is to read
`results/report/step20_notransition_inner1000_ident92/aligned_lengths.tsv`
into R and inspect it. The important thing to do here is to determine a
mapping fraction below which a query sequence will be considered to not
have any homology with the target chromosome. Those sequences will be
discarded as possible matches. My thinking on this is that little bits
of mapping to the chromosome are most likely repetitive elements and so
it is not worth considering those for inferring ancestral states anyway.
By tossing them, we won’t have ancestral states called for places that
we probably should try to call ancestral states. (The output fasta will
ultimately have an N there so that site should not be considered by, for
example, RELATE).

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
