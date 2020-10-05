    import gorilla = require('gorilla')//only if using Gorilla interface

    export function change_of_mind_instr(stimpos, adv_pos, adv_conf, i)
    {
    //EMPTY ARRAY FOR TIMELINE OF EXPERIMENT
    var scale = ["<p>certainly left</p>","","","",  "","","", "<p>certainly right</p>"];

    //EXPERIMENT PARAMETERS 
    var fixation_time = 1000;	// Create variables for timing
    var fixation_time_post = 550;
    var feedback_trial_time = 600;// originally 1000
    var prac_stim_time= 300;
    var stim_time= 150; 
    var prep_time_postchoice=450;
    var max_CR_RT = -1;
    var inter_trial_interval = 500;

    // Initialize staircase variables
    var responseMatrix= [true, true];
    var reversals;
    var	s2_dir = ["up", "up"];
    var numDots1 = 4.8;
    var numDots2 = 0;
    var error_count=0;
    let count1 = null; 

        //FULLSCREEN PLUGIN
    var check_fullscreen = 
    {    
    type: 'fullscreen',    
    showtext: '<p>You need to be in fullscreen mode to continue the experiment! <br></br> Please click the button below to enter fullscreen mode.<br></br><p>',    
    buttontext: "Continue",
        data: function() 
        {var data = jsPsych.data.getLastTrialData();
        var tNum = data.tNum + 1;
        jsPsych.data.addProperties({tNum: tNum});
        console.log(tNum);
        }
    };
        
    var blankstim1 = draw_stimulus("myInnerCanvas");
    var blankstim2 = draw_stimulus("myInnerCanvas2");
        
    //FIXATION AND DOTS PLUGIN 
        var practice_trial_xabpos = 
        {
            type: 'xabpos',
            stimuli: [function() // Note the specifics of how the stimuli function is wrapped in brackets like so: [function(){}]
            {
                var data = jsPsych.data.getLastTrialData();
                numDots1=data.numDots;
                var stim1 = draw_stimulus("myInnerCanvas", Math.round(Math.exp(numDots1))); // Create stimulus 1
                var stim2 = draw_stimulus("myInnerCanvas2", numDots2); // Create stimulus 2 //stim 2 is the one with the LESS dots
                var stimulus = [gorilla.resourceURL('fixation5.png'), stim1, stim2];
                return stimulus;
            }],
            pos: stimpos,
            timing_x: fixation_time,
            timing_xab_gap: 1,
            timing_ab: stim_time, // Stimulus presentation = max_RT
            timing_response: stim_time,
            data: {Task_type: 'practice_change', label: 'dottedstim', numDots:numDots1},
            timing_post_trial: 0,
        };


        var practice_trial_doublestim = 
        {
            type: 'doublestim',
            stimuli: [function() // Note the specifics of how the stimuli function is wrapped in brackets like so: [function(){}]
            {
                var stim1 = draw_stimulus("myInnerCanvas", Math.round(Math.exp(numDots1))); // Create stimulus 1
                var stim2 = draw_stimulus("myInnerCanvas2", numDots2); // Create stimulus 2 //stim 2 is the one with the LESS dots
                var stimulus = [stim1, stim2];
                return stimulus;
            }],
            left_key: [],
            right_key: [],
            timing_ab: stim_time, // Stimulus presentation = max_RT
            timing_response: stim_time,
            data: {Task_type: 'practice_change', label: 'dottedstim', numDots:numDots1},
            timing_post_trial: 0,
        };


        //CONFIDENCE RATING PLUGIN
        var confratingscale = 
        {
            type: "survey-likert",
            questions: [['<p style = "text-align: center; font-size: 28px">Make your <strong>first</strong> judgment: <br></br></p>']],
            labels: [[scale]],
            intervals: [[8]],
            data:function()
            {
                var data =  jsPsych.data.getLastTrialData();
                return {tNum:data.tNum, label: 'confidencerating1', Task_type: 'practise_change'};
            },
            on_finish: function() // This part is crucial
            {
                var data = jsPsych.data.getLastTrialData(); // Get data from the response block (on_finish evaluates getLastTrialData() as the trial that is currently being coded under)
                var confidence_rating1 = parseInt(data.responses[6], 16);
        
                if (confidence_rating1 > 4 && stimpos == 2){ // chose right, correct
                    data.correct = Boolean(true); 
                }else if (confidence_rating1 < 4 && stimpos == 1){ //chose left, correct
                    data.correct = Boolean(true); 
                }else if (confidence_rating1 > 4 && stimpos == 1){
                    data.correct = Boolean(false); 
                }else {
                    data.correct = Boolean(false); 
            };
        
            var new_data1 = {confidence_rating1: confidence_rating1, dir: stimpos, correct: data.correct};
            jsPsych.data.addDataToLastTrial(new_data1);
            data = jsPsych.data.getLastTrialData();
            gorilla.metric(data);
            }
        };
        
        //ADVISER PRESENTATION
        var practice_adviser_presentation = 
        {
            type: 'xabpos',
            stimuli: [function() // Note the specifics of how the stimuli function is wrapped in brackets like so: [function(){}]
                {var img = ['adv' + adv_pos + '_' + adv_conf + '.png']
                    
                var stimulus = [gorilla.resourceURL(img)];
                return stimulus;
                }],
            pos: stimpos,
            timing_x: 2000, //2 sec presentation - just as PKU paper
            timing_xab_gap: 1,
            timing_ab: stim_time, // Stimulus presentation = max_RT
            timing_response: stim_time,
            data: {Task_type: 'practise_change', label: 'adviser_presentation'},
            timing_post_trial: 0    
        };
        
        var confratingscale2 = 
        { 
            type: "survey-likert",
            questions: [['<p style = "text-align: center; font-size: 28px">Make your <strong>second</strong> judgment:<br></br></p>']],
            labels: [[scale]],
            intervals: [[8]],
            data: function () 
            {
                var data = jsPsych.data.getLastTrialData();
                return {tNum: data.tNum, label: 'confidencerating2', Task_type: 'practise_change'};
            },
            on_finish: function () 
            {
                var data = jsPsych.data.getLastTrialData(); // Get data from the response block (on_finish evaluates getLastTrialData() as the trial that is currently being coded under)
                var confidence_rating2 = parseInt(data.responses[6], 16);

                if (confidence_rating2 > 4 && stimpos == 2) {
                    data.correct = Boolean(true);
                }else if (confidence_rating2 < 4 && stimpos == 1) {
                    data.correct = Boolean(true);
                }else if (confidence_rating2 > 4 && stimpos == 1) {
                    data.correct = Boolean(false);
                }else {data.correct = Boolean(false)
                }
                var new_data2 = {confidence_rating2: confidence_rating2, correct: data.correct};
                jsPsych.data.addDataToLastTrial(new_data2);
                gorilla.metric(new_data2);
            
            }
        }; 

        //PUSH THE WHOLE TRIAL
        var practchunk= {
        chunk_type:'linear',
        timeline: [check_fullscreen, practice_trial_xabpos, practice_trial_doublestim,  practice_trial_doublestim, practice_trial_doublestim,practice_trial_doublestim, confratingscale,practice_adviser_presentation, confratingscale2]
        };
        return practchunk;
    };
