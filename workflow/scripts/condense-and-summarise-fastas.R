#### redirect output and messages/errors to the log ####
log <- file(snakemake@log[[1]], open="wt")
sink(log, type = "output")
sink(log, type = "message")



#### get all the snakemake variables ####
maf2fasta_output <- snakemake@input$maf2fasta

final_fasta <- snakemake@output$anc_fasta
pair_summary_file <- snakemake@output$bp_pairs

# we need the target sequence name for a few things.
# because lastz munges names with dots in them, we just use the output
# file name, which has the {tchrom} on it.
tchrom = snakemake@wildcards$tchrom


#### Do the rest ####

library(tidyverse)


# read the sequences in.  They are on every other line.  The first
# is the target, the following are separate ones for each query chromosome
seqs <- read_lines(maf2fasta_output)

# break those sequences into a list of vectors
seq_vec_list <- str_split(seqs[seq(2, length(seqs), by = 2)], pattern = "")

snames <- seqs[seq(1, length(seqs), by = 2)]
rm(seqs)

# if there were multiple query sequences, condense them into a single one.
# the "-" has the lowest value of any of the possible letters in the aligned
# sequences, so this step takes the base at the aligned query sequence, if there
# is an aligned query sequency. (Remember we did single_cov2 so there will be only
# one aligned query at any point.)
if(length(seq_vec_list) > 2) {
  anc <- do.call(pmax, seq_vec_list[-1])
} else {
  anc <- seq_vec_list[[2]]
}

# now, we count up the number of different types of sites
pair_counts <- table(paste(seq_vec_list[[1]], anc))

# and make a tibble of those numbers
count_summary <- enframe(pair_counts) %>%
  separate(name, into = c("target", "ancestral"), sep = " ") %>%
  rename(n = value) %>%
  mutate(chrom = tchrom, .before = target)

# and write that file out
write_csv(count_summary, pair_summary_file)


# and now, from anc, we subset out the sites that are "-"s in the target.
# That gives us an ancestral sequence that is congruent with the
# original target sequence. And then we replace the "-"'s in the ancestral
# seq with Ns
anc_fasta_seq <- anc[seq_vec_list[[1]] != "-"]
anc_fasta_seq[anc_fasta_seq == "-"] <- "N"


cat(">", tchrom, "\n", sep = "", file = final_fasta)

# now make a matrix out of that to print it in lines.
# we suppress warnings because the sequence length is almost never
# going to be a multiple of 70. We have to extend it with NAs to the
# correct length, first

final_line_bits <- length(anc_fasta_seq) %% 70
if(final_line_bits != 0) {
  length(anc_fasta_seq) <- length(anc_fasta_seq) + (70 - final_line_bits)
}

# now, make a matrix of that and write it out.  NA's are just empty in
# that last line.
suppressWarnings(matrix(anc_fasta_seq, ncol = 70, byrow = TRUE)) %>%
  write.table(
    file = final_fasta,
    sep = "",
    na = "",
    quote = FALSE,
    append = TRUE,
    row.names = FALSE,
    col.names = FALSE
  )
