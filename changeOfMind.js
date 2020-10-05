    import gorilla = require('gorilla')//only if using Gorilla interface

    export function changeOfMind(numTrials_change, stimpos1, stimpos2, trialpos, perm)
    {
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
        var count = 0;
        var error_count=0;

    //CHECK FULLSCREEN PLUGIN 
        var check_fullscreen2 = 
        {    
            type: 'fullscreen',    
            showtext: '<p>You need to be in fullscreen mode to continue the experiment! <br></br> Please click the button below to enter fullscreen mode.<br></br><p>',    
            buttontext: "Continue",
            data:function()
            {var data = jsPsych.data.getLastTrialData();
            var tNum = data.tNum + 1; 
            jsPsych.data.addProperties({tNum:tNum});
            },
            on_finish: function()
                {
                data = jsPsych.data.getLastTrialData(); 
                var current_count = data.tNum; 
                if (current_count === 115) //181
                {
                    confidencerating_data_final = [];
                    correct_data_final = [];
                    temp_data = jsPsych.data.getData(); //get the data for the advisers - correct
                    for (var j = 0; j < temp_data.length; j++) 
                        {
                            n = j.toString();
                            if (temp_data[n]['Task_type'] === "conftask" && temp_data[n]['confidence_rating'] !== undefined) 
                            {
                                correct_data_final.push(temp_data[n]['correct']);
                                confidencerating_data_final.push(temp_data[n]['confidence_rating']);
                            }
                        }
                    confidencerating_data_final2 = []; 
                    for(var t = 0; t < confidencerating_data_final.length; t++)
                    {
                        ta = t.toString(); 
                        if (confidencerating_data_final[ta] > 4)
                        {
                            confidencerating_data_final2.push(confidencerating_data_final[ta] - 4)
                        } else 
                        {
                            confidencerating_data_final2.push(5 - confidencerating_data_final[ta])
                        }
                    }
                    //get the advisers' characteristics for the main task
                    advdeviset('trial', numTrials_change, stimpos1, correct_data_final, confidencerating_data_final2, perm); //returns a numtrials-change length array of the advisers confidence (1-8 acc. to accuracy and stimpos) and counterbalanced adviser type (1/2)
                    data = jsPsych.data.getLastTrialData();
                    var new_data4 = { advpos_arr: advpos2, advconf_arr: advconf2, tNum: current_count };
                    jsPsych.data.addDataToLastTrial(new_data4);
                    data = jsPsych.data.getLastTrialData();
                    gorilla.metric(data);
                    console.log(data);
                }
                else 
                {
                    var new_data5 = {tNum: current_count}
                    console.log(current_count)
                    jsPsych.data.addDataToLastTrial(new_data5)
                    data = jsPsych.data.getLastTrialData()
                    gorilla.metric(data)
                }
            }
        }; 
        
        //STIMULI PARAMETERS FOR PARTICULAR TRIAL	
        var blankstim1 = draw_blankstimulus("myInnerCanvas");
        var blankstim2 = draw_blankstimulus("myInnerCanvas2");
        
    //FIXATION AND DOTS PLUGIN
        var trial_presentation_xabpos = 
        {
        type: 'xabpos',
        stimuli: [function() // Note the specifics of how the stimuli function is wrapped in brackets like so: [function(){}]
                    {
                        data = jsPsych.data.getLastTrialData();
                        numDots1 = data.numDots;
                
                        var stim1 = draw_stimulus("myInnerCanvas", Math.round(Math.exp(numDots1))); // Create stimulus 1
                        var stim2 = draw_stimulus("myInnerCanvas2", numDots2); // Create stimulus 2 //stim 2 is the one with the LESS dots

                        var stimulus = [gorilla.resourceURL('fixation5.png'), stim1, stim2]
                        return stimulus;
                    }],
                    pos: trialpos, 
                    timing_x: fixation_time,
                    timing_xab_gap: 1,
                    timing_ab: stim_time, // Stimulus presentation = max_RT
                    timing_response: stim_time,
                    data: {Task_type: 'Change_of_mind', label: 'dottedstim', numDots: numDots1},
                    timing_post_trial: 0,
        };

        var trial_presentation_doublestim = 
        {type: 'doublestim',
        stimuli: [function() // Note the specifics of how the stimuli function is wrapped in brackets like so: [function(){}]
                {
                    stim1 = draw_stimulus("myInnerCanvas", Math.round(Math.exp(numDots1))); // Create stimulus 1
                    stim2 = draw_stimulus("myInnerCanvas2", numDots2); // Create stimulus 2 //stim 2 is the one with the LESS dots
                    var stimulus = [stim1, stim2];
                    return stimulus;
                    
                }],
        left_key: [],
        right_key: [],
        timing_ab: stim_time, // Stimulus presentation = max_RT
        timing_response: stim_time,
        data: {Task_type: 'Change_of_mind', label: 'dottedstim', numDots:numDots1},
        timing_post_trial: 0,
        };

        //CONFIDENCE RATING PLUGIN
        var scale = ["<p>certainly left</p>","","","",   "","","", "<p>certainly right</p>"];
        var confratingscale = 
        { type: "survey-likert",
        questions: [['<p style = "text-align: center; font-size: 28px">Make your <strong>first</strong> judgment:<br></br></p>']],
        labels: [[scale]],
        intervals: [[8]],
        data: function () {
            data = jsPsych.data.getLastTrialData();
            tNum = data.tNum + 1; 
            return {tNum:tNum, label: 'confidencerating1', Task_type: 'Change_of_mind'};
                    },
                    on_finish: function () {
                        data = jsPsych.data.getLastTrialData(); // Get data from the response block (on_finish evaluates getLastTrialData() as the trial that is currently being coded under)
                        current_count = data.tNum; 
                        console.log(current_count)
                        var confidence_rating1 = parseInt(data.responses[6], 16);
                        
                        if (confidence_rating1 > 4 && trialpos == 2) {
                            data.correct = Boolean(true);
                        }
                        else if (confidence_rating1 < 4 && trialpos == 1) {
                            data.correct = Boolean(true);
                        }
                        else if (confidence_rating1 > 4 && trialpos == 1) {
                            data.correct = Boolean(false);
                        }
                        else {
                            data.correct = Boolean(false);
                        }
                        
                        alldata = jsPsych.data.getData(); //now find the saved adviser positions 
                        var alladv_pos = [];
                        var alladv_conf = [];
                        for (var j = 0; j < alldata.length; j++) 
                        { 
                            n = j.toString();
                            if (alldata[n]['advpos_arr'] !== undefined) 
                            {
                                alladv_pos.push(alldata[n]['advpos_arr']);
                                alladv_conf.push(alldata[n]['advconf_arr']);
                            }
                        }
                        console.log(alladv_conf);
                        console.log(current_count)
                        var adv_pos = alladv_pos[0][current_count - 115]; // to start from 1 again in the array where each row represents a trial - those trials associated with practice etc.
                        var adv_conf = alladv_conf[0][current_count - 115];
                        console.log(adv_pos);
                        console.log(alladv_conf)
                        new_data1 = {confidence_rating1: confidence_rating1, dir:trialpos, correct:data.correct, adv_type:adv_pos, adv_conf:adv_conf};  
                        jsPsych.data.addDataToLastTrial(new_data1);
                        data = jsPsych.data.getLastTrialData();
                        gorilla.metric(data);
                    }
                };
                
        //ADVISER PRESENTATION
        var adviser_presentation = 
        {
        type: 'xabpos',
        stimuli: [function() // Note the specifics of how the stimuli function is wrapped in brackets like so: [function(){}]
                    { 
                        singledata = jsPsych.data.getLastTrialData();
                        current_count = data.tNum;
                        
                        console.log(current_count);
                        alldata = jsPsych.data.getData(); //now find the saved adviser positions 
                        var alladv_pos = [];
                        var alladv_conf = [];
                        for (var j = 0; j < alldata.length; j++) 
                        { 
                            n = j.toString();
                            if (alldata[n]['advpos_arr'] !== undefined) 
                            {
                                alladv_pos.push(alldata[n]['advpos_arr']);
                                alladv_conf.push(alldata[n]['advconf_arr']);
                            }
                        }
                        console.log(alladv_conf);
                        console.log(current_count)
                        var adv_pos = alladv_pos[0][current_count - 115]; // to start from 1 again in the array where each row represents a trial - those trials associated with practice etc.
                        var adv_conf = alladv_conf[0][current_count - 115];
                        console.log(adv_pos);
                        console.log(alladv_conf)
                    
                        var img = ['adv' + adv_pos + '_' + adv_conf + '.png'];
                        var stimulus = [gorilla.resourceURL(img)];
                        return stimulus;
                        
                        new_data = {adv_type: adv_pos, adv_conf:adv_conf, tNum:current_count};
                        jsPsych.data.addDataToLastTrial(new_data); 
                        data = jsPsych.data.getLastTrialData();
                        gorilla.metric(data);
                    }],
                    pos: trialpos,
                    timing_x: 2000, //2 sec presentation - just as in Psych Science paper
                    timing_xab_gap: 1,
                    timing_ab: stim_time, // Stimulus presentation = max_RT
                    timing_response: stim_time,
                    data: {Task_type: 'Change_of_mind', label: 'dottedstim'},
                    timing_post_trial: 0,
        };

    //CONFIDENCE RATING PLUGIN
        var confratingscale2 = 
        { type: "survey-likert",
        questions: [['<p style = "text-align: center; font-size: 28px">Make your <strong>second</strong> judgment:<br></br></p>']],
        labels: [[scale]],
        intervals: [[8]],
        data: function () 
        {
            data = jsPsych.data.getLastTrialData();
            return {tNum:data.tNum, label: 'confidencerating2', Task_type: 'Change_of_mind'};
        },
        on_finish: function()
            {
            data = jsPsych.data.getLastTrialData(); // Get data from the response block (on_finish evaluates getLastTrialData() as the trial that is currently being coded under)
            var confidence_rating2 = parseInt(data.responses[6], 16);
            var count_2add = data.tNum +1;
            console.log(count_2add)
            
            if (confidence_rating2 > 4 && trialpos == 2) {
                data.correct = Boolean(true);
            }
            else if (confidence_rating2 < 4 && trialpos == 1) {
                data.correct = Boolean(true);
            }
            else if (confidence_rating2 > 4 && trialpos == 1) {
                data.correct = Boolean(false);
            }
            else 
            {
                data.correct = Boolean(false);
            }
            var new_data2 = {confidence_rating2: confidence_rating2,
                correct:data.correct,
                dir:trialpos
            };
            jsPsych.data.addDataToLastTrial(new_data2);
            data = jsPsych.data.getLastTrialData();
            gorilla.metric(data);
            }
        };

        //GROUPT EXPERIMENTAL TRIAL INTO ONE CHUNK + PUSH IT
        var exptchunk= 
        {
        chunk_type:'linear',
        timeline: [check_fullscreen2, trial_presentation_xabpos, trial_presentation_doublestim, trial_presentation_doublestim, trial_presentation_doublestim, trial_presentation_doublestim,confratingscale, adviser_presentation,  confratingscale2]
        // timeline: [adviser_presentation]
        };

        ////////////////////////////
        //END OF EXPERIMENTAL TASK//
        ////////////////////////////

        return exptchunk;

    };