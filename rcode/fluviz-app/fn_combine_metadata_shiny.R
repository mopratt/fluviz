library(tidyverse)
library(readxl)
library(readr)

combine_metadata_shiny <- function(metadata, line_list, label_col) {
  metadata_raw <- read_excel(metadata)
  metadata <- metadata_raw %>% select(label = all_of(label_col), Subtype, Location,
                                      Host, Host_Age, Host_Gender, Human_Specimen_Source,
                                      Animal_Specimen_Source, Collection_Date,
                                      Adamantanes_Resistance_geno,
                                      Oseltamivir_Resistance_geno, Zanamivir_Resistance_geno, 
                                      Peramivir_Resistance_geno, Other_Resistance_geno, 
                                      Adamantanes_Resistance_pheno, Oseltamivir_Resistance_pheno,
                                      Zanamivir_Resistance_pheno, Peramivir_Resistance_pheno, Other_Resistance_pheno, 
                                      Patient_Status, Outbreak)
  metadata <- metadata %>% mutate(label = str_replace_all(label, " ", "_")) %>% arrange(label)
  linelist_raw <- read_csv(line_list, skip = 3, col_types = cols())
  linelist <- linelist_raw %>% select(label = `Sequence Name`, 
                                      `Clade`, 
                                      Num.aa.sub = `Number of Amino Acid Substitutions in Antigenic Sites`, 
                                      Percent.id = `% Identity of Antigenic Site Residues`)
  metadata_combined <- left_join(metadata, linelist, by = "label") %>% distinct()
  metadata_combined
}
