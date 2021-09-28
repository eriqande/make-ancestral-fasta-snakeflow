

library(tidyverse)

al <- read_tsv("misc/example_outputs/aligned_lengths.tsv")

ggplot(al, aes(x = query, y = fraction)) +
  geom_col() +
  facet_wrap(~target)


# try dropping every query chromosome with  <3% of the total mapped
# to the target
num_rem <- al %>%
  filter(fraction > 0.03) %>%
  group_by(target) %>%
  summarise(n = n())

al2 <- left_join(
  al, num_rem
) %>%
  mutate(targ_plus = str_c(target, " (", n, ")"))


ggplot(al2, aes(x = query, y = fraction)) +
  geom_col() +
  facet_wrap(~ targ_plus)
