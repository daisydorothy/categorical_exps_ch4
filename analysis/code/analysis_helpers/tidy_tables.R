
library(xtable)

# TABLES FOR LATEX
bold <- function(x){
  paste0('\\bf ', x, '\\n')
}


## Make a nice posterior summary table
make_post_summ_table <- function(post_summ) {
  post_summ.df <- as.data.frame(post_summ)
  post_summ.tidy <- post_summ.df  %>%
    select(-"CI", -"ROPE_CI", -"ROPE_low", -"ROPE_high", -"Rhat", -"ESS") %>%
    mutate(MAP = format(round(MAP, 2), nsmall = 2),
           CI_low_temp = format(round(CI_low, 2), nsmall = 2),
           CI_hi_temp =format(round(CI_high, 2), nsmall = 2),
           "95\\% CI" = paste("[",CI_low_temp,", ", CI_hi_temp, "]" ,sep = ""),
           "pd (\\%)" = pd*100,
           "\\% in ROPE" = ROPE_Percentage*100) %>%
    select(Parameter, MAP, "95\\% CI", "pd (\\%)", "\\% in ROPE") %>%
    rename(" " = Parameter)
  
  post_summ.tidy_xtable <- xtable(post_summ.tidy)
  align(post_summ.tidy_xtable) <-  rep("c", 6)
  print(post_summ.tidy_xtable,
        booktabs = TRUE,
        include.rownames=FALSE,
        sanitize.colnames.function = bold)
  #return(post_summ.tidy_xtable)
}

