library(dplyr)
library(tidyr)
library(ggplot2)

toughPalette <- c("#80A0C7","#394165")
valleyPalette <- c("#E7CDC2", "#A65141")
fillerPalette <- c("#DCA258", "#8B9DAF")

personaPalette <- c( "#80A0C7", "#394165", "#E7CDC2","#A65141")
theme_set(theme_minimal())


# TABLES FOR LATEX
bold <- function(x){
  paste0('\\bf ', x, '\\n')
}


## Posterior summary
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











# Categorical selection plots: for plotting, eg., Tough selections after hearing in' vs ing. 

### This function takes an optional argument to facet - so you can facet by e.g. stim-type, or participant, or whatever
# Categorical selection plots
# for plotting, eg., Tough selections after hearing in' vs ing. These plots are easier to understand.
plot_categorical_selections <- function(data, chosenPalette, arg){
  #data$condition <- factor(data$condition, levels = c("-in", "-ing", "HRT", "Decl.")) 
  data <- data %>%
    filter(criticality == 'CRITICAL') 
  if (!missing(arg)) {
    arg <- ensym(arg)
    data <- data %>% 
      group_by(condition, !!arg)%>%
      select(participant, trial, condition, target_selection, arg) %>%
      unique()
  } else {
    data <- data %>% 
      group_by(condition) %>%
      select(participant, trial, condition, target_selection) %>%
      unique() 
  }
  data <- data %>%
    summarize(mean_cat_selection = mean(target_selection),
              CI.Low = ci.low(target_selection), 
              CI.High = ci.high(target_selection))%>%
    mutate(YMin = mean_cat_selection - CI.Low, 
           YMax = mean_cat_selection + CI.High)
  
  plot <- data %>%
    ggplot(aes(x=condition, y=mean_cat_selection))+
    geom_bar(stat = "identity", aes(fill = condition)) +
    geom_errorbar(aes(ymin=YMin,ymax=YMax), width=.25) +
    scale_fill_manual(values=chosenPalette) +
    labs(fill = "Condition") +
    ylab("Proportion of Tough Selections") +
    ylim(0, 1) +
    theme(axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          #axis.text.x = element_text(color="black", size=16),
          axis.text.y = element_text(size = 16),
          axis.title.y = element_text(color="black", size=18),
          strip.text.x = element_text(size=16, face="bold"),
          legend.title = element_text(color="black", size=16),
          legend.position = "top",
          legend.text = element_text(color="black", size=16))
  if (!missing(arg)) {
    arg <- enquo(arg)
    plot <- plot + facet_wrap(arg)
  } 
  return(plot)
}




plot_categorical_selections_presentations <- function(data, chosenPalette, arg){
  #data$condition <- factor(data$condition, levels = c("-in", "-ing", "HRT", "Decl.")) 
  data <- data %>%
    filter(criticality == 'CRITICAL') 
  if (!missing(arg)) {
    arg <- ensym(arg)
    data <- data %>% 
      group_by(condition, !!arg)%>%
      select(participant, trial, condition, target_selection, arg) %>%
      unique()
  } else {
    data <- data %>% 
      group_by(condition) %>%
      select(participant, trial, condition, target_selection) %>%
      unique() 
  }
  data <- data %>%
    summarize(mean_cat_selection = mean(target_selection),
              CI.Low = ci.low(target_selection), 
              CI.High = ci.high(target_selection))%>%
    mutate(YMin = mean_cat_selection - CI.Low, 
           YMax = mean_cat_selection + CI.High)
  
  plot <- data %>%
    ggplot(aes(x=condition, y=mean_cat_selection))+
    geom_bar(stat = "identity", aes(fill = condition)) +
    geom_errorbar(aes(ymin=YMin,ymax=YMax), width=.25) +
    scale_fill_manual(values=chosenPalette) +
    labs(fill = "Condition") +
    ylab("Proportion of Tough Selections") +
    ylim(0, 1) +
    theme(legend.position = "none",
          #legend.title = element_text(size = 16),
          #legend.text = element_text(size = 14),
          plot.title = element_text(size = 20, face="bold"),
          axis.title.x = element_blank(),
          #axis.text.x = element_blank(),
          axis.text.x = element_text(color="black", size=20),
          strip.text.x = element_text(size = 20, face="bold"),
          axis.text.y = element_text(size = 14),
          axis.title.y =  element_text(size = 20))
  if (!missing(arg)) {
    arg <- enquo(arg)
    plot <- plot + facet_wrap(arg)
  } 
  return(plot)
}



plot_categorical_selections_by_item <- function(data, palette){
  #data$condition <- factor(data$condition, levels = c("-in", "-ing", "HRT", "Decl.")) 
  data <- data %>%
    filter(criticality == 'CRITICAL') %>%
    group_by(condition, stim_type) %>%
    summarize(mean_cat_selection = mean(target_selection),
              CI.Low = ci.low(target_selection), 
              CI.High = ci.high(target_selection))%>%
    mutate(YMin = mean_cat_selection - CI.Low, 
           YMax = mean_cat_selection + CI.High) #%>%
  
  plot <- data %>%
    ggplot( aes(x=condition, y=mean_cat_selection, fill = condition))+
    geom_bar(position=position_dodge(), stat = "identity") +
    geom_errorbar(aes(ymin=YMin,ymax=YMax), width=.25, position=position_dodge(.9)) +
    scale_fill_manual(values=palette) + 
    ylab("Proportion of Tough Selections") +
    labs(fill = "Condition") +
    ylim(0, 1) +
    facet_grid(~stim_type)
}


plot_categorical_selections_both_styles <- function(data, palette, arg){
  #data$condition <- factor(data$condition, levels = c("-in", "-ing", "HRT", "Decl.")) 
  data <- data %>%
    filter(criticality == 'CRITICAL') 
  if (!missing(arg)) {
    arg <- ensym(arg)
    data <- data %>% 
      group_by(condition, exptype, styletype, !!arg)
  } else {
    data <- data %>% 
      group_by(condition, exptype, styletype) 
  }
  data <- data %>%
    #group_by(condition, exptype, styletype) %>%
    summarize(mean_cat_selection = mean(target_selection),
              CI.Low = ci.low(target_selection), 
              CI.High = ci.high(target_selection))%>%
    mutate(YMin = mean_cat_selection - CI.Low, 
           YMax = mean_cat_selection + CI.High) #%>%
  
  plot <- data %>%
    ggplot( aes(x=styletype, y=mean_cat_selection, fill = condition))+
    geom_bar(position=position_dodge(), stat = "identity") +
    geom_errorbar(aes(ymin=YMin,ymax=YMax), width=.25, position=position_dodge(.9)) +
    scale_fill_manual(values=palette) + 
    ylab("Proportion of Tough Selections") +
    labs(fill = "Condition") +
    ylim(0, 1) +
    theme(axis.title.x = element_blank(),
          axis.text.x = element_text(color="black", size=16),
          axis.text.y = element_text(size = 14),
          axis.title.y = element_text(color="black", size=18),
          strip.text.x = element_text(size=16, face="bold"),
          legend.position = "top",
          legend.title = element_text(color="black", size=16),
          legend.text = element_text(color="black", size=16))
    
  if (!missing(arg)) {
    arg <- enquo(arg)
    plot <- plot + facet_wrap(arg)
  } 
  return(plot)
}

plot_categorical_selections_multiple_exps <- function(data, palette){
  #data$condition <- factor(data$condition, levels = c("-in", "-ing", "HRT", "Decl.")) 
  plot <- data %>%
    filter(criticality == 'CRITICAL') %>%
    group_by(condition, exptype, styletype) %>%
    summarize(mean_cat_selection = mean(target_selection),
              CI.Low = ci.low(target_selection), 
              CI.High = ci.high(target_selection))%>%
    mutate(YMin = mean_cat_selection - CI.Low, 
           YMax = mean_cat_selection + CI.High) %>%
    ggplot( aes(x=exptype, y=mean_cat_selection, fill = condition))+
    geom_bar(position=position_dodge(), stat = "identity") +
    geom_errorbar(aes(ymin=YMin,ymax=YMax), width=.25, position=position_dodge(.9)) +
    scale_fill_manual(values=palette) + 
    ylab("Proportion of Tough Selections") +
    labs(fill = "Condition") +
    ylim(0, 1) +
    theme(axis.title.x = element_blank(),
          axis.text.x = element_text(color="black", size=16),
          axis.text.y = element_text(size = 14),
          axis.title.y = element_text(color="black", size=16),
          legend.title = element_text(color="black", size=16),
          legend.text = element_text(color="black", size=14),
    )
  return(plot)
}


# Categorical selections over time - i.e., trial order
plot_categorical_selections_by_trial_n <- function(data, chosenPalette){
  data$condition <- factor(data$condition, levels = c("-in", "-ing", "HRT", "Decl.")) 
  cat_trial.plot <- data %>%
    filter(criticality == 'CRITICAL') %>%
    select(participant, trial, target_selection, trial_no, condition ) %>%
    unique() %>%
    group_by(trial_no, condition) %>%
    summarize(mean_cat_selection = mean(target_selection),
              CI.Low = ci.low(target_selection), 
              CI.High = ci.high(target_selection))%>%
    mutate(YMin = mean_cat_selection - CI.Low, 
           YMax = mean_cat_selection + CI.High) %>%
    ggplot( aes(x=trial_no, y=mean_cat_selection, fill = condition, color = condition))+
    geom_bar(position=position_dodge(), stat = "identity") +
    geom_errorbar(aes(ymin=YMin,ymax=YMax), width=.25, position=position_dodge(.9)) +
    #geom_point(aes(y = mean_cat_selection, fill = condition)) +
    geom_smooth(size = 0.5) +
    scale_fill_manual(values=chosenPalette) +
    scale_color_manual(values=chosenPalette) +
    ylab("Proportion of Tough Selections") +
    labs(fill = "Condition") +
    xlab('Trial number') +
    ylim(0, 1) +
    scale_x_discrete('Trial number', limits=c(3:26))
  return(cat_trial.plot)
}



#Bin looks for plotting

### This function takes an optional argument to bin by - e.g., whether the ultimate selection was cue-congurent or not. 
binsize = 200
bin_looks <- function(data, CRITICALITY, cue, arg){
  binned <- data %>%
    filter(criticality == {{CRITICALITY}})%>%
    ungroup() %>%
    group_by(condition) %>%
    mutate(mean_audio_end = mean(aud_duration-mean({{cue}}))) %>%
    ungroup ()%>%
    group_by(participant, trial) %>%
    mutate(zeropoint = (audio_start+{{cue}}),
           zeroscaled_time = time-zeropoint) %>%
    ungroup() %>%
    group_by(condition) %>%
    mutate(bin_max_ms= (floor(zeroscaled_time/binsize))*binsize) %>%
    filter(bin_max_ms >= -1000, bin_max_ms <= 2500) %>%
    ungroup() 
  
  if (!missing(arg)) {
    binned <- binned %>%
      group_by(condition, bin_max_ms, {{arg}}) %>%
      mutate(mean_prop = mean(target_look), CI.Low = ci.low(target_look), CI.High = ci.high(target_look)) %>%
      mutate(YMin = mean_prop - CI.Low, YMax = mean_prop + CI.High ) 
  } else {
    binned <- binned %>%
      group_by(condition, bin_max_ms) %>%
      mutate(mean_prop = mean(target_look), CI.Low = ci.low(target_look), CI.High = ci.high(target_look)) %>%
      mutate(YMin = mean_prop - CI.Low, YMax = mean_prop + CI.High ) 
  }
  return(binned)
}


### This function takes an optional argument to facet - so you can facet by e.g. first/second half of trials.
plot_looks <- function(binned_data, chosenPalette, arg){
  #data$condition <- factor(data$condition, levels = c("-in", "-ing", "HRT", "Decl.")) 
criticality <- as.character(binned_data$criticality)[1]
  if (criticality == 'CRITICAL') {
    ylab_title = "Proportion of looks to Toughs"
  } else {
    ylab_title = "Proportion of looks to Females"
  } 
  plot <- binned_data %>%
    filter(bin_max_ms >= -400, bin_max_ms <= 2000) %>%
    ggplot(aes(x=bin_max_ms, y = mean_prop))+  
    geom_line(size = 1, aes(color = condition)) +
    geom_ribbon(aes(ymin=YMin,ymax=YMax,fill=condition),alpha=.5) +
    geom_vline(xintercept = -200, color= 'grey', linetype='dashed') +
    geom_vline(xintercept = 200, color= 'grey', linetype='dashed') +
    geom_vline(aes(xintercept = mean_audio_end, color = condition)) +
    scale_color_manual(values=chosenPalette) +
    scale_fill_manual(values=chosenPalette) +
    labs(fill = "Condition") +
    labs(color = "Condition")+
    xlab('Time (ms)') +
    ylab(ylab_title)+
    ylim(0, 1) +
    theme(plot.title = element_text(size = 22, face="bold"),
          strip.text.x = element_text(size = 16, face="bold"),
          legend.position = "top",
          legend.text = element_text(size = 16),
          legend.title =  element_text(size = 16),
          #legend.title = element_blank(),
          axis.text.x = element_text(size = 14, angle = 90),
          axis.title.x =  element_text(size = 14),
          axis.text.y = element_text(size = 14),
          axis.title.y =  element_text(size = 18)) +
    scale_x_continuous(breaks = seq(from = -400, to = 2000, by = 100))
  if (!missing(arg)) {
    arg <- enquo(arg)
    plot <- plot + facet_grid(cols = vars(!!arg))
  }
  return(plot)
}


plot_looks_presentations <- function(binned_data, chosenPalette, arg){
  #data$condition <- factor(data$condition, levels = c("-in", "-ing", "HRT", "Decl.")) 
  criticality <- as.character(binned_data$criticality)[1]
  if (criticality == 'CRITICAL') {
    ylab_title = "Looks to Toughs"
  } else {
    ylab_title = "Looks to Female"
  } 
  plot <- binned_data %>%
    filter(bin_max_ms >= -400, bin_max_ms <= 2000) %>%
    ggplot(aes(x=bin_max_ms, y = mean_prop))+  
    geom_line(size = 1, aes(color = condition)) +
    geom_ribbon(aes(ymin=YMin,ymax=YMax,fill=condition),alpha=.5) +
    geom_vline(xintercept = 0, color= 'black') +
    geom_vline(xintercept = 200, color= 'black', linetype='dashed') +
    geom_vline(aes(xintercept = mean_audio_end, color = condition), alpha = 0.5) +
    scale_color_manual(values=chosenPalette) +
    scale_fill_manual(values=chosenPalette) +
    xlab('Time (ms)') +
    ylab(ylab_title)+
    ylim(0, 1) +
    theme(axis.text.x = element_text(angle = 90))+
    theme(plot.title = element_text(size = 22, face="bold"),
          strip.text.x = element_text(size = 20, face="bold"),
          legend.position = "top",
          legend.text = element_text(size = 22),
          #legend.title =  element_text(size = 16),
          legend.title = element_blank(),
          axis.text.x = element_text(size = 16, angle = 90),
          axis.title.x =  element_text(size = 14),
          axis.text.y = element_text(size = 16),
          axis.title.y =  element_text(size = 20)) +
    scale_x_continuous(breaks = seq(from = -400, to = 2000, by = 200))
  if (!missing(arg)) {
    arg <- enquo(arg)
    plot <- plot + facet_grid(cols = vars(!!arg))
  }
  return(plot)
}



