

function make_slides(f) {
  var slides = {};

  slides.i0 = slide({
    name : "i0",
    exp_start: function() {
      $("#first_trial_instructions").hide();
      $("#scene_instructions").hide();
      $("#sound_test_err").hide();
      // exp.startT = Date.now();
    }
  });

  // slides.training_and_calibration = slide({
  //   name: "training_and_calibration",
  //   start_camera : function(e) {
  //     $("#start_camera").hide();
  //     $("#start_calibration").show();
  //     init_webgazer();
  //   },
  //   finish_calibration_start_task : function(e){
  //     if (precision_measurement > PRECISION_CUTOFF) {
  //       $("#plotting_canvas").hide();
  //       $("#webgazerVideoFeed").hide();
  //       $("#webgazerFaceOverlay").hide();
  //       $("#webgazerFaceFeedbackBox").hide();
  //       webgazer.pause();
  //       exp.go();
  //     }
  //     else {
  //       exp.accuracy_attempts.push(precision_measurement);
  //       swal({
  //         title:"Calibration Fail",
  //         text: "Either you haven't performed the calibration yet, or your calibration score is too low. Your calibration score must be 50% to begin the task. Please click Recalibrate to try calibrating again.",
  //         buttons:{
  //           cancel: false,
  //           confirm: true
  //         }
  //       })
  //     }
  //   }
  // });

  slides.sound_test = slide({
    name: "sound_test",
    soundtest_verification : function(e){
      // check word
      sound_entry = $("#sound_test_entry").val().toUpperCase().trim();
      console.log(sound_entry)
      if (sound_entry == 'APPLE'){
        exp.trial_no = 0;
        exp.go();
      } else{
        $("#sound_test_entry").val(""); // clear text box
        $("#sound_test_err").show();
      }
    }
  });


  slides.single_trial = slide({
    name: "single_trial",
    present: exp.current_exp_list,
    present_handle: function(trial) {
      this.trial_start = Date.now();
      exp.trial_no += 1;
      $("#first_trial_instructions").hide();
      if (exp.trial_no == 1 || exp.trial_no == 2){
        $("#first_trial_instructions").show();
      }
      $("#aud").hide();
      exp.trial_name = trial.audio.split('.')[0]
      exp.current_trial = trial

      exp.display_imgs(exp.current_trial); // get imgs, show them
      // webgazer.resume();
      // webgazer.setGazeListener(function(data, elapsedTime) {
      //   if (data == null) {
      //     return;
      //   }
      //   var xprediction = data.x; //these x coordinates are relative to the viewport
      //   var yprediction = data.y; //these y coordinates are relative to the viewport
      //   exp.tlist.push(elapsedTime);
      //   exp.xlist.push(xprediction);
      //   exp.ylist.push(yprediction);
      // });

      $("#imgwrapper").show();
      $("#continue_button").hide();
      $("#next_button").hide();
      $(".err").hide();
      $(".err_part2").hide();
      $("#scene_instructions").hide();

    },

    next_trial : function(e){
      if (exp.clicked == null ) {
        $(".err").show();
      } else {
        $(".err").hide();
        exp.keep_going = false;
        this.log_responses();
        _stream.apply(this);
        // exp.tlist = [];
        // exp.xlist = [];
        // exp.ylist = [];
        exp.clicked = null;
        exp.endPreview = false;
      }
    },

    continue : function(e){
      exp.endPreview = true
      exp.endPreviewTime = Date.now()
      $("#img_table tr").show();
      $("#continue_button").hide();
      var aud = $("#aud").attr("src", "static/audio/"+exp.trial_name+".wav")[0]; //must use .wavs to get accurate duration
      aud.onloadedmetadata = function() {
        aud_dur = aud.duration;
      };
    },


    log_responses : function (){
      exp.data_trials.push({
        "trial" : exp.trial_name,
        "selected_img" : exp.clicked,
        'left_choice' : exp.current_trial.img_left,
        'right_choice' : exp.current_trial.img_right,
        'left_choice_type' : exp.current_trial.img_left_type,
        'right_choice_type' : exp.current_trial.img_right_type,
        'condition': exp.current_trial.condition,
        'current_scene' : exp.current_scene,
        'alt_scene': exp.alt_scene,
        'selected_scene': exp.scene_clicked,
        'criticality' : exp.current_trial.criticality,
        'exp_list' : exp.exp_list_no,
        "start_time" : _s.trial_start,
        "rt" : Date.now() - _s.trial_start,
        "img_selection_rt" :exp.img_selection_rt,
        "current_windowW" : window.innerWidth,
        "current_windowH" : window.innerHeight,
        "endPreviewTime" : exp.endPreviewTime,
        "aud_duration" : aud_dur,
        "trial_no" : exp.trial_no
        // 'time' : exp.tlist,
        // 'x' : exp.xlist,
        // 'y': exp.ylist
      });
    }

  });

  slides.subj_info =  slide({
    name : "subj_info",
    submit : function(e){
      lg = $("#language").val();
      age = $("#participantage").val();
      gend = $("#gender").val();
      headphones = $("#headphones").val();
      // eyesight = $("#eyesight").val();
      // eyesight_task = $("#eyesight_task").val();
      if(lg == '' || age == '' || gend == '' || headphones == ''){
        // if(lg == '' || age == '' || gend == '' || eyesight == '-1' || eyesight_task == '-1'){
        $(".err_part2").show();
      } else {
        $(".err_part2").hide();
        exp.subj_data = {
          language : $("#language").val(),
          age : $("#participantage").val(),
          gender : $("#gender").val(),
          headphones : $("#headphones").val(),
          // eyesight : $("#eyesight").val(),
          // eyesight_task : $("#eyesight_task").val(),
          comments : $("#comments").val(),
          // accuracy : precision_measurement,
          // previous_accuracy_attempts : exp.accuracy_attempts,
          time_in_minutes : (Date.now() - exp.startT)/60000
        };
        exp.go(); //use exp.go() if and only if there is no "present" data.
      }
    }
  });

  slides.thanks = slide({
    name : "thanks",
    start : function() {
      // webgazer.stopVideo();
      exp.data= {
        "trials" : exp.data_trials,
        "system" : exp.system,
        "subject_information" : exp.subj_data,
      };
      console.log(turk);
      setTimeout(function() {turk.submit(exp.data);}, 1000);
    }
  });

  return slides;
}


/// init ///
function init_explogic() {

  //Experiment constants
  exp.N_TRIALS= 26
  exp.NUM_COLS = 2
  PRECISION_CUTOFF = 50;

  exp.system = {
    Browser : BrowserDetect.browser,
    OS : BrowserDetect.OS,
    screenH: screen.height,
    screenW: screen.width,
    windowH: window.innerHeight,
    windowW: window.innerWidth,
    imageH: exp.imageHeight,
    imageW: exp.imageWidth
  };


  exp.minWindowWidth = 1280
  exp.imageHeight = 500 // make this a constant
  exp.imageWidth = 167 // make this a constant
  exp.windowW = window.innerWidth
  exp.windowH = window.innerHeight

  //Initializing data frames
  exp.tlist = []; //TESTING
  exp.xlist = [];
  exp.ylist = [];

  exp.clicked = null
  //exp.descriptors = _.shuffle(descriptors)
  exp.accuracy_attempts = []

  // INITIALIZE EXP LIST
  // ATM, set up s.t. ppt is randomly assigned a list at init.
  var exp_list_nos = ['1','2','3','4','5','6', '7', '8']
  exp.exp_list_no = _.shuffle(exp_list_nos).pop();
  var unorganized_exp_list = exp_lists.filter(a=>a.exp_list==exp.exp_list_no);

  function order_experiment_blocks(explist){
    var ts = []
    var vs = []
    var fs_1 = []
    var fs_2 = []
    var ms_1 = []
    var ms_2 = []
    var fcounter = 0
    var mcounter = 0
    for (i = 0; i < explist.length; i ++){
      if (explist[i].condition == 'TM' || explist[i].condition == 'TU'){
        ts.push(explist[i])
      }
      else if (explist[i].condition == 'VM' || explist[i].condition == 'VU'){
        vs.push(explist[i])
      }
      else if (explist[i].condition == 'F'){
        if (fcounter < 3){
          fs_1.push(explist[i])
          fcounter += 1
        } else {
          fs_2.push(explist[i])
        }
      }
      else if (explist[i].condition == 'M') {
        if (mcounter < 3){
          ms_1.push(explist[i])
          mcounter += 1
        } else {
          ms_2.push(explist[i])
        }
      }
    }

    var block1 = vs.concat(fs_1).concat(ms_1)
    var block2 = ts.concat(fs_2).concat(ms_2)
    block1 = _.shuffle(block1)
    block2 = _.shuffle(block2)
    exp.current_exp_list = block1.concat(block2)
    console.log(exp.current_exp_list)
  }

  function assign_imgs_to_trials (){
    var toughs = _.shuffle(img_fnames.toughs)
    var valleys = _.shuffle(img_fnames.valleys)
    var males = _.shuffle(img_fnames.males)
    var females = _.shuffle(img_fnames.females)
    for (i = 0; i < exp.current_exp_list.length; i ++){
      var trial = exp.current_exp_list[i]
      if (trial.criticality == 'CRITICAL') {
        if (trial.img_left_type == 'T' & trial.img_right_type == 'V'){
          trial.img_left = toughs.pop()
          trial.img_right = valleys.pop()
        }
        if (trial.img_left_type == 'V' & trial.img_right_type == 'T'){
          trial.img_left = valleys.pop()
          trial.img_right = toughs.pop()
        }
      }
      else if (trial.criticality == 'FILLER') {
        if (trial.img_left_type == 'M' & trial.img_right_type == 'F'){
          trial.img_left = males.pop()
          trial.img_right = females.pop()
        }
        if (trial.img_left_type == 'F' & trial.img_right_type == 'M'){
          trial.img_left = females.pop()
          trial.img_right = males.pop()
        }
      }
    }
  };

  // now add two practice trials, whose index will be 0, 1
  function add_practice_trials(){
    var practice_trial_types = ['CRIT', 'FILLER']
    practice_trial_types = _.shuffle(practice_trial_types)

    var practice_filler_audio = 'PRACTICE_people_are_lookING_ing_1_ing_3.wav'
    var practice_crit_audio = 'PRACTICE_people_are_laughing_M.wav'

    var practice_crit_imgs = ['PRACTICE_v_h6_b7.png', 'PRACTICE_t_h5_b3.png']
    var practice_filler_imgs = ['PRACTICE_f_h5_b2.png', 'PRACTICE_m_h1_b3.png']
    practice_crit_imgs = _.shuffle(practice_crit_imgs)
    practice_filler_imgs = _.shuffle(practice_filler_imgs)

    var crit_practice_trial  = {
      audio: 'PRACTICE_people_are_lookING_ing_1_ing_3.wav',
      criticality:"PRACTICE_TRIALS",
      img_left_type:practice_crit_imgs[0].split('_')[1],
      img_right_type:practice_crit_imgs[1].split('_')[1],
      img_left:practice_crit_imgs[0],
      img_right:practice_crit_imgs[1]}

      var filler_practice_trial = {
        audio: 'PRACTICE_people_are_laughing_M.wav',
        criticality:"PRACTICE_TRIALS",
        img_left_type:practice_filler_imgs[0].split('_')[1],
        img_right_type:practice_filler_imgs[1].split('_')[1],
        img_left:practice_filler_imgs[0],
        img_right:practice_filler_imgs[1]}

        if (practice_trial_types[0] == 'CRIT'){
          var p1 = crit_practice_trial
          var p2 = filler_practice_trial
        } else {
          var p1 = filler_practice_trial
          var p2 = crit_practice_trial
        }
        // exp.current_exp_list.push(p1)
        // exp.current_exp_list.push(p2)
        // exp.current_exp_list.sort(function(a, b){return a.index - b.index});
        exp.current_exp_list.unshift(p1)
        exp.current_exp_list.unshift(p2)
      }

      order_experiment_blocks(unorganized_exp_list)
      assign_imgs_to_trials();
      add_practice_trials();

      function display_scenes(trial){
        for (i = 0; i < scene_names.length; i ++){
          if (scene_names[i].audio == trial.audio){
            exp.current_scene = scene_names[i].actual
            exp.alt_scene = scene_names[i].alt
          }
        }
        scene_choices = [exp.current_scene, exp.alt_scene]
        scene_choices = _.shuffle(scene_choices)

        $("#first_trial_instructions").hide();
        if (exp.trial_no == 1 || exp.trial_no == 2){
          $("#scene_instructions").show();
        }

        $("#scenewrapper").show();
        var cellwidth = exp.minWindowWidth/exp.NUM_COLS
        if (document.getElementById("randomized_scenes") != null){
          $("#randomized_scenes tr").remove();
        }
        var table = document.createElement("table");
        var tr = document.createElement('tr');
        // $("#next_button").offset({top: (window.innerHeight/2)-(30/2), left: (window.innerWidth/2)-(100/2)})
        for (i = 0; i < exp.NUM_COLS; i++) {
          console.log(scene_choices[0])
          //Create table elements, set width
          var txt_td = document.createElement('td');
          txt_td.style.width = exp.minWindowWidth/exp.NUM_COLS+'px';

          //Now we create the text
          var txt = document.createElement("P");
          txt.innerHTML = scene_choices[i];
          txt.id = scene_choices[i];

          // //HANDLING SELECTION -- only once chance to click
          txt.onclick = function(){
            var id = $(this).attr("id");
            exp.scene_clicked = id;
            $(this).css("border","2px solid red");
            setTimeout(function(){
              $("#scene_instructions").hide();
              $("#scenewrapper").hide();
              $("#next_button").show()}, 1000); // show selection for 1s before clearing

            };
            txt.style.textAlign = "center";
            txt.style.fontSize = "xx-large";
            txt_td.appendChild(txt);
            tr.appendChild(txt_td);
          }
          table.appendChild(tr);
          table.setAttribute('id', 'randomized_scenes')
          document.getElementById("scenewrapper").appendChild(table);
        }






        exp.display_imgs = function(trial){
          var img_fnames = [trial.img_left, trial.img_right]
          if (document.getElementById("img_table") != null){
            $("#img_table tr").remove();
          }
          var table = document.createElement("table");
          var tr = document.createElement('tr');
          // var cellwidth = exp.minWindowWidth/exp.NUM_COLS - 20 // (-20 to allow for body padding on L (10px) and R (10px))
          var cellwidth = exp.minWindowWidth/exp.NUM_COLS
          //$("#continue_button").offset({top: (window.innerHeight/2)-(30/2), left: (window.innerWidth/2)-(100/2)})

          for (i = 0; i < exp.NUM_COLS; i++) {   //Create table elements, set width
            var img_td = document.createElement('td');
            img_td.style.width = cellwidth+'px';

            var img_fname = img_fnames[i]
            var img = document.createElement('img');
            img.src = 'static/imgs/'+img_fname;
            img.id = img_fname;

            // place images at L and R
            if (img.id == img_fnames[0]){
              img.style.marginRight = (cellwidth - exp.imageWidth )  + 'px';
            } else {
              img.style.marginLeft = (cellwidth - exp.imageWidth )  + 'px';
            }

            //HANDLING SELECTION
            img.onclick = function(){
              var id = $(this).attr("id");
              if (document.getElementById("aud").ended & exp.endPreview == true){
                exp.clicked = id;
                $(this).css("border","2px solid red");
                exp.img_selection_rt = Date.now() - _s.trial_start,
                // webgazer.pause();
                setTimeout(function(){
                  $("#img_table tr").remove();
                  display_scenes(trial) }, 1000); // show selection for 1s before clearing
                }
              };
              img_td.appendChild(img);
              tr.appendChild(img_td);
            }
            table.setAttribute('id', 'img_table')
            table.appendChild(tr);
            document.getElementById("imgwrapper").appendChild(table);


            // if you want to give preveiw time (a delay before showing the play audio button, use below)
            setTimeout(function(){
              $("#continue_button").show();
              $("#trial_buttons").offset({top: (window.innerHeight/2)-(30/2), left: (exp.innerWidth/2)-(100/2)})
            }, 3000); // preview imgs for 3 secs (this is greater than prev versions which were 2 secs)
          };



          //blocks of the experiment:
          exp.structure=["i0",  "sound_test", "single_trial",  "subj_info", "thanks"];
          exp.data_trials = [];
          exp.data_trials = [];
          exp.slides = make_slides(exp);
          exp.nQs = utils.get_exp_length();

          // EXPERIMENT RUN
          $('.slide').hide(); //hide everything

          //make sure turkers have accepted HIT (or you're not in mturk)
          $("#windowsize_err").hide();
          $("#sound_test_err").hide();
          $("#start_button").click(function() {
            if (turk.previewMode) {
              $("#mustaccept").show();
            } else {
              $("#start_button").click(function() {$("#mustaccept").show();});
              if (window.innerWidth >=  exp.minWindowWidth){
                exp.startT = Date.now();
                exp.go();
                // ClearCanvas();
                // helpModalShow();
                // $("#start_calibration").hide();
                // $("#begin_task").hide();
              }
              else {
                $("#windowsize_err").show();
              }
            }
          });

          $(".response_button").click(function(){
            var val = $(this).val();
            _s.continue_button(val);
          });

          exp.go(); //show first slide
        }
