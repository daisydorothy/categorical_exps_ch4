library(dplyr)
library(tidyverse)
library(ggplot2)

# colorschemes 
tomato <- "#D55E00"
forest <-  "#009E73"
grey <- "#999999"
orange <- "#E69F00"
timePlotPalette <- c(orange, tomato, forest, grey)
toughPalette <- c("#E69F00",  "#ffdf98")
valleyPalette<- c("#56B4E9","#9bd3f2")

theme_set(theme_minimal())


#Check distribution of participants across explists

plot_explist <- function(data) {
  explist.plot <- data %>%
    select(participant, exp_list) %>%
    unique() %>%
    ggplot(aes(exp_list)) +
    geom_histogram()
  return(explist.plot)
} 

get_explist_df <- function(data) {
  explist.df <- data %>%
    select(participant, exp_list) %>%
    unique() %>%
    group_by(exp_list) %>%
    summarize(n = n())
  return(explist.df)
}


# Tidy-up functions (separate functions for purely categorical data vs eyetracking)

tidy_categorical_data <- function(data){
  data$current_scene <- as.character(data$current_scene)
  data$selected_scene <- as.character(data$selected_scene)
  data$trial <- as.character(data$trial)
  data.tidy <- data %>%
    rename(participant = workerid) %>%
    filter(criticality != 'PRACTICE_TRIALS') %>%
    mutate(selected_img_type = toupper(str_extract(selected_img, '^\\w')),
           stim_type = tolower(gsub("_\\w{2,4}_\\d{1}_\\w{2,4}_\\d{1}", '', trial)),
           frame_type = gsub("(ing|ING)_", '', str_extract(trial, "(ing|ING)_[[:alpha:]]{2,4}")),
           stim_type_short = str_extract(stim_type, "[[:alpha:]]+$"),
           scene_correct = ifelse(current_scene == selected_scene, 1, 0),
           filler_correct = ifelse(criticality == 'FILLER' & condition == selected_img_type, 1,0),
           cat_selection = ifelse(condition == 'VM'  & selected_img_type == 'V' | condition == 'VU' & selected_img_type == 'V' | condition == 'TM' & selected_img_type == 'T' | condition == 'TU' & selected_img_type == 'T', 1, 0),
           cue_congruent = ifelse(condition == 'F' & selected_img_type == 'F' | condition == 'M' & selected_img_type == 'M'|
                                    condition == 'VM' & selected_img_type == 'V' | condition == 'TM' & selected_img_type == 'T'|
                                    condition == 'VU' & selected_img_type == 'T' | condition == 'TU' & selected_img_type == 'V', 1, 0),
           condition = recode_factor(condition, TM = "in", TU = "ing",  VM ="HRT", VU = "Declarative"))%>%
    group_by(participant) %>%
    mutate(participant_scene_score = sum(scene_correct),
            participant_filler_score = sum(filler_correct))
  return(data.tidy)
}


tidy_eyeball_data <- function(data){
  data$current_scene <- as.character(data$current_scene)
  data$selected_scene <- as.character(data$selected_scene)
  data$trial <- as.character(data$trial)
  data$condition <- as.character(data$condition)
  data.tidy <- data %>%
    filter(criticality != 'PRACTICE_TRIALS') %>%
    filter(!is.na(audio_loaded_time)) %>% # i ran a pilot which didnt have audio_loaded_time, so exclude those ppts
    rename(participant = workerid, language = subject_information.language) %>%
    mutate(selected_img_type = toupper(str_extract(selected_img, '^\\w')),
           stim_type = tolower(gsub("_\\w{2,4}_\\d{1}_\\w{2,4}_\\d{1}", '', trial)),
           scene_correct = ifelse(current_scene == selected_scene, 1, 0), 
           filler_correct = ifelse(criticality == 'FILLER' & condition == selected_img_type, 1,0),
           condition = recode_factor(condition, TM = "in", TU = "ing",  VM ="HRT", VU = "Declarative"),
           target = ifelse(criticality == 'CRITICAL', 'T', 'F'), #tough if critical, F if not 
           # target = ifelse(condition == 'VM', 'V', 
           #                 ifelse(condition == 'VU', 'T', 
           #                        ifelse(condition == 'TM', 'T',
           #                               ifelse(condition == 'TU','V', condition)))),
           # target_pos = ifelse(target == left_choice_type, 'L', 'R'),
           # comp_pos = ifelse(target == left_choice_type, 'R', 'L'),
           target_pos = ifelse(target == left_choice_type, 'L', 'R'),
           comp_pos = ifelse(target_pos == 'L', 'R', 'L'),
           # cat_selection = ifelse(condition == 'VM'  & selected_img_type == 'V' | 
           #                          condition == 'VU' & selected_img_type == 'V' | 
           #                          condition == 'TM'  & selected_img_type == 'T' | 
           #                          condition == 'TU' & selected_img_type == 'T', 1, 0),
           target_selection = ifelse(selected_img_type == target, 1, 0), # for crit trials, target = T; for fillers, F
           # cue_congruent = ifelse(target == selected_img_type, 1, 0), 
           cue_congruent_selection = ifelse(condition == "HRT" & selected_img_type == 'V' | condition == 'in' & selected_img_type == 'T'
                                            | condition == 'Declarative' & selected_img_type == 'T' | condition == 'ing' & selected_img_type == 'V', 1, 0)) %>%
    group_by(participant) %>%
    mutate(participant_scene_score = sum(scene_correct),
           participant_filler_score = sum(filler_correct))
  return(data.tidy)
}


# Unnest x, y, and t measurements and "stage" eyetracking data - ie figure out what stage of the trial each time measurement corresponds to
unnest_and_stage_data <- function(data){
  data$time <- as.character(data$time)
  data$x <- as.character(data$x)
  data$y <- as.character(data$y)
  data.staged <- data %>%
    separate_rows(time,x,y,convert=TRUE) %>%
    filter(!is.na(time)) %>%
    mutate(aud_duration = aud_duration*1000, # time is in s not ms
           total_preview_time = audio_loaded_time - start_time) %>%
    group_by(participant, trial) %>%
    #calculate start/end times of diff stages
    mutate(audio_start = min(time)+(total_preview_time), audio_end = audio_start+aud_duration, img_selection_time =
             min(time)+img_selection_rt) %>%
    #calculate which stage time measurement falls into
    mutate(stage = ifelse(time < audio_start, 'previewtime',
                          ifelse(time > audio_start & time < audio_end, 'audiotime',
                                 ifelse(time > audio_end & time < img_selection_time, 'decisiontime', 'post_imgselection')))) %>%
    filter(stage != 'post_imgselection') # don't care about anything post-selection
  return(data.staged)
}




# calculate AOIs
imgwidth = 167
imgheight = 500
next_width = 50
next_height = 29

imgpadding = 200 
nextpadding = 100
scene_width = 1280 # everything takes place in a central 'scene' of  1280 pixels 
frameheight = 650


calculate_AOI <- function (data){
  data.unnest_AOI <- data %>%
    group_by(participant) %>%
    #filter(x > -1 & x < current_windowW & y > -1 & y < current_windowH) %>% 
    mutate(x_center = (current_windowW/2),
           y_center = (current_windowH/2),
           AOI_left_x_min = x_center - (scene_width/2),
           AOI_left_x_max = x_center - (scene_width/2) +imgwidth + imgpadding,
           AOI_right_x_min = x_center + (scene_width/2) - imgwidth - imgpadding,
           AOI_right_x_max = x_center + (scene_width/2),
           AOI_y_min = y_center-(frameheight/2), 
           AOI_y_max = y_center+(frameheight/2),
           next_x_min = x_center - (next_width/2) - nextpadding, 
           next_x_max = x_center + (next_width/2) + nextpadding,
           next_y_min =  y_center - (next_height/2) - nextpadding, 
           next_y_max =  y_center + (next_height/2) + nextpadding) %>%
    mutate(looking_dir = as.factor(ifelse(x > AOI_left_x_min & x < AOI_left_x_max & y > AOI_y_min & y < AOI_y_max, 'L', 
                                          ifelse(x > AOI_right_x_min & x < AOI_right_x_max & y > AOI_y_min & y < AOI_y_max, 'R', 
                                                 ifelse(x > next_x_min & x < next_x_max & y > next_y_min & y < next_y_max, 'nextbutton', 'other')))))
  return(data.unnest_AOI)
}


# Vizualize AOIS
viz_AOIs <- function(data) {
  aoi.plot <- data %>%
    filter(x > -1 & x < current_windowW & y > -1 & y < current_windowH) %>% 
    ggplot(aes(x=x, y=y, color = looking_dir)) +
    geom_jitter(alpha=0.5) + 
    scale_color_manual(values = timePlotPalette)+
    facet_wrap(~participant) +
    scale_y_reverse()
  return(aoi.plot)
}



# calculate looks
calculate_looks <- function(data) {
  data$left_choice <- as.character(data$left_choice)
  data$right_choice <- as.character(data$right_choice)
  data$selelected_img <- as.character(data$selected_img)
  data.lookscalc <- data %>%
    mutate(target_look = ifelse(looking_dir == target_pos, 1, 0),
           comp_look = ifelse(looking_dir == comp_pos, 1, 0),
           otherlook = ifelse(looking_dir == 'other', 1, 0), 
           nextbutton = ifelse(looking_dir == 'nextbutton', 1, 0),
           selected_img_look = ifelse(looking_dir == 'L' & left_choice == selected_img | looking_dir== 'R' & right_choice ==selected_img, 1, 0),
           nonselected_img_look = ifelse(looking_dir == 'L' & left_choice != selected_img | looking_dir == 'R' & right_choice != selected_img, 1, 0))
  return(data.lookscalc)
}

# check audio looding times (ie latencies between when audio SHOULD have played and when it actually did.)
check_loadtimes <- function(data){
  load.df <- data %>%
    filter(!is.na(audio_loaded_time)) %>%
    select(participant, trial, endPreviewTime, audio_loaded_time) %>%
    unique() %>%
    mutate(load_t = audio_loaded_time-endPreviewTime) 
  load.plot <- load.df %>%
  ggplot() +
    geom_histogram(aes(x=load_t))
  
  return(load.plot)
}
