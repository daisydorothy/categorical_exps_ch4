function order_trials(current_exp_list) {
  // generate indexes for each twin (ie. each filler trial)
  var twindices = []
  var random_used = twindices
  for (i = 0; i < 12; i ++){
    idx = Math.floor(Math.random() * Math.floor(10000))
    twindices.push(idx)
  }
  // assign index to each twin
  for (i = 0; i < exp.current_exp_list.length; i++){
    if (exp.current_exp_list[i].criticality == 'FILLER'){
      exp.current_exp_list[i].index = twindices.pop();
    }
  }
  // now assign each crit a random index that is lower than that of its twin
  // this is to ensure the twin comes after the crit
  for (crit = 0; crit < exp.current_exp_list.length; crit++){
    if (exp.current_exp_list[crit].criticality == 'CRITICAL'){
      var crit_stim = exp.current_exp_list[crit].audio.split('_').slice(2,-6).join('_');
    }
    for (twin = 0; twin < exp.current_exp_list.length; twin ++){
      if (exp.current_exp_list[twin].criticality == 'FILLER'){
        var twin_stim = exp.current_exp_list[crit].audio.split('_').slice(2,-6).join('_');
        if (twin_stim == crit_stim){
          var twindex = exp.current_exp_list[twin].index
          var crindex = null
          while (random_used.includes(crindex) || crindex == null) {
            crindex = Math.floor(Math.random() * Math.floor(twindex)) + 2
          }
          exp.current_exp_list[crit].index = crindex
          random_used.push(crindex)
        }
      }
    }
  }
  // now ensure no neighbors ! (ie the same stim doesnt twice in a row in crit/filler)
  exp.current_exp_list.sort(function(a, b){return a.index - b.index});
  var same_neighbor_count = 0
  for (i = 0; i < exp.current_exp_list.length-2; i++){
    if (exp.current_exp_list[i].audio == exp.current_exp_list[i+1].audio || exp.current_exp_list[i].audio == exp.current_exp_list[i+2].audio){
      same_neighbor_count += 1
    }
  }
  //// TODO: ADD TWO PRACTICE TRIALS TO START OF LIST (We won't analyze these, just for practice)
  return same_neighbor_count
};
// now add two practice trials, whose index will be 0, 1
function add_practice_trials(){
  var practice_audios = ['dh_AM_basketball_game_p1_CA3_CA48_p3_GA1_NY2.wav', 'hrt_AM_golf_game_p1_GA1_CA45_p3_GA3_CA2.wav']
  practice_audios = _.shuffle(practice_audios)
  var practice_toughs = ['practice_t_h1_b2.png', 'practice_t_h5_b3.png']
  var practice_valleys = ['practice_v_h3_b2.png', 'practice_v_h6_b7.png']
  practice_toughs = _.shuffle(practice_toughs)
  practice_valleys = _.shuffle(practice_valleys)
  var practice_trial_types = ['T', 'V']
  practice_trial_types = _.shuffle(practice_trial_types)

  var p1 = {audio: practice_audios[0], criticality:"INITIAL_TWO_TRIALS", index:0, img_left_type:practice_trial_types[0], img_right_type:practice_trial_types[0]}
  if (practice_trial_types[0] == 'T'){
    p1.img_left = practice_toughs[0]
    p1.img_right = practice_toughs[1]
  } else {
    p1.img_left = practice_valleys[0]
    p1.img_right = practice_valleys[1]
  }

  var p2 = {audio: practice_audios[1], criticality:"INITIAL_TWO_TRIALS", index:1, img_left_type:practice_trial_types[1], img_right_type:practice_trial_types[1]}
  if (practice_trial_types[1] == 'T'){
    p2.img_left = practice_toughs[0]
    p2.img_right = practice_toughs[1]
  } else {
    p2.img_left = practice_valleys[0]
    p2.img_right = practice_valleys[1]
  }

  exp.current_exp_list.push(p1)
  exp.current_exp_list.push(p2)
  exp.current_exp_list.sort(function(a, b){return a.index - b.index});
}
// Initialize the trial_order
while (true) {
  same_neighbor_count = order_trials();
  if (same_neighbor_count == 0){
    break;
  }
}
function assign_imgs_to_trials(){
  var toughs = _.shuffle(img_fnames.toughs)
  var valleys = _.shuffle(img_fnames.valleys)
  complete = true
  for (i = 0; i < exp.current_exp_list.length; i ++){
    var trial = exp.current_exp_list[i]
    if (trial.criticality != 'INITIAL_TWO_TRIALS'){
      // first handle the critical trials
      if (trial.img_left_type == 'T' & trial.img_right_type == 'V'){
        trial.img_left = toughs.pop()
        trial.img_right = valleys.pop()
      }
      else if (trial.img_left_type == 'V' & trial.img_right_type == 'T'){
        trial.img_left = valleys.pop()
        trial.img_right = toughs.pop()
      }
      // now handle the fillers - ensuring that no two of the same heads/bods appear
      else if (trial.img_left_type == 'T' & trial.img_right_type == 'T'){
        trial.img_left = toughs.pop();
        var left_head = trial.img_left.split('_')[1]
        var left_bod = trial.img_left.split('_')[2].split('.')[0]
        for (t = 0; t < toughs.length; t++ ){
          var right_head = toughs[t].split('_')[1]
          var right_bod = toughs[t].split('_')[1].split('.')[0]
          if (right_head != left_head & right_bod != left_bod){
            trial.img_right = toughs.pop(t)
            break;
          } else {
            complete = false
          }
        }
      }
      else if (trial.img_left_type == 'V' & trial.img_right_type == 'V'){
        trial.img_left = valleys.pop();
        var left_head = trial.img_left.split('_')[1]
        var left_bod = trial.img_left.split('_')[2].split('.')[0]
        for (v = 0; v < valleys.length; v++ ){
          var right_head = valleys[v].split('_')[1]
          var right_bod = valleys[v].split('_')[1].split('.')[0]
          if (right_head != left_head & right_bod != left_bod){
            trial.img_right = valleys.pop(v)
            break;
          } else {
            complete = false
          }
        }
      }
    }
  }
  return complete
}
add_practice_trials();
while (true){
  complete = assign_imgs_to_trials()
  if (complete) {
    break;
  }
}
function get_scene_names(){
  exp.scene_names = []
  for (i = 0; i < exp.current_exp_list.length; i ++){
    var scene_name = exp.current_exp_list[i].audio.split('_').slice(2,-6).join(' ').toUpperCase()
    exp.scene_names.push(scene_name)
  }
}
get_scene_names();
