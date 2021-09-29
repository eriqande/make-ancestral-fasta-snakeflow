
library(tidyverse)
library(RcppRoll)

segs <- read_tsv("misc/example_outputs/plotable_segments.tsv")

segs2 <- segs %>%
  mutate(
    slope = (qend - qstart) / (tend - tstart),
    wonky = abs(slope) > 1.5 | abs(slope) < 0.5,
    strand = str_c(tstrand, "/", qstrand)
  )


g2 <- ggplot(segs2) +
  geom_point(
    aes(x = (tstart + tend) / 2, y = (qstart + qend) / 2, colour = strand),
    alpha = 0.02
  ) +
  facet_grid(target ~ query)

ggsave(g2, filename = "misc/example_outputs/homology-grid.pdf", width = 40, height = 40)


# I want to do some rolling average of the fraction of
# all bases from the target that are aligned.
roll_window <- 400
segs3 <- segs2 %>%
  arrange(target, query, tstart, qstart) %>%
  group_by(target, query) %>%
  mutate(
    talign_roll = roll_sum(abs(tend - tstart), n = roll_window, fill = NA),
    tabs_roll = roll_max(tend, n = roll_window, fill = NA) - roll_min(tstart, n = roll_window, fill = NA),
    fract10 = talign_roll / tabs_roll
  )

# and now, record for each target chromosome, the names of the
# chromosomes that have any windows that exceed 0.50, and also the
# total target length in those alignments in those windows
maps_gt_50 <- segs3 %>%
  filter(fract10 > 0.5) %>%
  group_by(target, query) %>%
  summarise(
    num_align = n(),
    tot_targ_len = sum(abs(tend - tstart))
  )

ggplot(maps_gt_50, aes(x = tstart, y = fract10, colour = query)) +
  geom_line() +
  facet_wrap(~ target, scales = "free_x")

ggsave(g3, filename = "misc/example_outputs/rolling-fract-aligned.pdf", height = 20, width = 20)


# and now for visualization, let's limit the big homology grid to only those
segs_filt <- segs2 %>%
  semi_join(maps_gt_50, by = c("target", "query"))




g_filt <- ggplot(segs_filt) +
  geom_point(
    aes(x = (tstart + tend) / 2, y = (qstart + qend) / 2, colour = strand),
    alpha = 0.02
  ) +
  facet_grid(query ~ target) +
  theme_bw()

ggsave(g_filt, filename = "misc/example_outputs/homology-grid-filt.pdf", width = 40, height = 40)
ggsave(g_filt, filename = "figs/homology-grid-filt.png", width = 20, height = 20)


## So, I made that plot and from it realized that I need to toss out just a few rows from
## maps_gt_50, namely
toss_em <- c(6, 16, 18, 22, 23, 33)

## and then we can make our homolog sets to put in the config for the
## second half of this procedure
homolog_sets <- maps_gt_50[-toss_em, ] %>%
  group_by(target) %>%
  summarise(homologs = paste(query, collapse = " "))

# write it as a CSV with no header
write_csv(homolog_sets, file = "config/homolog_sets.csv")
