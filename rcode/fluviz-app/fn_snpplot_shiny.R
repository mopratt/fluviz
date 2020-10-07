library(plotly)

snpplot_shiny <- function(tree, line_list, metadata, clade_def) {
  line_list_raw <- read_csv(line_list)
  line_list <- line_list_raw %>%  distinct() %>% select(-2, -4) %>% 
    rename(label = X1, clade = X3) %>%
    slice(-2)
  tree_plot <- tree %>% as.phylo() %>% ggtree(branch.length = "none")
  tip_data <- tree_plot$data %>% arrange(desc(y)) %>% filter(isTip == TRUE)
  tip_labs <- tip_data %>% select(label, y)
  ref_align <- line_list %>% 
    dplyr::select(-'clade') %>%
    dplyr::semi_join(tip_data, by = "label")
  ref_align_fix <- t(ref_align)
  aa_rows <- ref_align_fix[1,]
  ref_align_fix <- ref_align_fix[-1,]
  colnames(ref_align_fix) <- aa_rows
  gapChar <- "."
  align_pos <- t(ref_align_fix)
  lalign_pos <- apply(align_pos, 1, function(x) {
    x != gapChar
  })
  lalign_pos <- as.data.frame(lalign_pos)
  lalign_pos$pos <- as.numeric(rownames(lalign_pos))
  lalign <- tidyr::gather(lalign_pos, label, value, -pos)
  aa_snp_data <- lalign[lalign$value, c("label", "pos")]
  ref <- line_list[1,] %>% 
    select(3:length(line_list)) %>%
    t() %>% 
    as.data.frame() %>%
    rownames_to_column(var = "pos") %>% 
    rename(ref.ID = V1)
  ref$pos <- as.numeric(as.character(ref$pos))
  aa_snps <- ref_align %>%
    gather(key = pos, value = snp.ID, -label) %>%
    mutate(pos = as.numeric(pos)) %>%
    right_join(aa_snp_data, by = c('label', 'pos')) %>%
    left_join(ref, by = "pos")
  clades <- read_csv(clade_def, col_names = FALSE)
  sites <- (length(clades) -2) / 2
  cnames <- rep(c("pos", "aa"), times = sites)
  cindex <- rep(c(1:sites), each = 2) 
  conames <- paste(cnames, cindex, sep = "-")
  conames <- c("clade", "depth", conames)
  colnames(clades) <- conames
  clades_long <- clades %>% pivot_longer(3:length(clades), names_to = c(".value", "set"),
                                         names_sep = "-",
                                         values_drop_na = TRUE) %>%
    dplyr::select(-3)
  clade_assign <- line_list %>% select('label', 'clade')
  aa_clades <- aa_snps %>% left_join(clade_assign, by = 'label') %>% 
    left_join(clades_long, by = c('clade', 'pos')) %>% 
    mutate(clade.def.pos = if_else(is.na(match(paste0(.$clade, .$pos),
                                               paste0(clades_long$clade, clades_long$pos))), FALSE, TRUE)) %>%
    rename(expected.aa = 'aa') %>%
    select(-'depth') %>% left_join(tip_labs, by = "label")
  aacols1 <-data.frame(aa = c("G", "A", "V", "L", "I", "P"), group = "nonpolar")
  aacols2 <-data.frame(aa = c("S", "T", "C", "M", "N", "Q"), group = "polar")
  aacols3 <-data.frame(aa = c("F", "W", "Y"), group = "aromatic")
  aacols4 <-data.frame(aa = c("K", "R", "H"), group = "basic")
  aacols5 <-data.frame(aa = c("D", "E"), group = "acidic")
  aacols6 <-data.frame(aa = c("X"), group = "unknown aa or clade")
  aacols <- aacols1 %>% bind_rows(aacols2, aacols3, aacols4, aacols5, aacols6)
  aa_clades_cols <- aa_clades %>% left_join(aacols, by = c("snp.ID" = "aa")) %>%
    rename(snp.group = group) %>%
    left_join(aacols, by = c("expected.aa" = "aa")) %>%
    rename(exp.group = group) %>%
    mutate(flag = if_else(snp.group == exp.group, "none", "aa.class.change")) %>%
    mutate(flag = if_else(clade == "No_Match", "no.clade", flag)) %>%
    mutate(flag = if_else(ref.ID == "X", "unknown.ref", flag)) %>%
    mutate(flag = if_else(is.na(flag), "none", flag)) %>%
    mutate(flag = factor(flag, levels = c("aa.class.change", "no.clade", "unknown.ref", "none")))
  aa_clades_cols
}
