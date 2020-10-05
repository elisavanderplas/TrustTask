import gorilla = require('gorilla')//not needed when not used on Gorilla

export function metaTask(stimpos, i)
{

//EXPERIMENT PARAMETERS 
	// Create variables for timing
	var fixation_time = 1000;
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
	var numDots2 = 0;
	var numDots1;
    var error_count=0;
    var difficulty_index=0;

//CHECK FULLSCREEN PLUGIN 
	var check_fullscreen2 = 
	{    
		type: 'fullscreen',    
		showtext: '<p>You need to be in fullscreen mode to continue the experiment! <br></br> Please click the button below to enter fullscreen mode.<br></br><p>',    
		buttontext: "Continue",
		data: function() 
		{var data = jsPsych.data.getLastTrialData();
		var tNum = data.tNum + 1;
		jsPsych.data.addProperties({tNum: tNum});
		console.log(tNum)
		}
	};		

		
    var blankstim1 = draw_blankstimulus("myInnerCanvas");
    var blankstim2 = draw_blankstimulus("myInnerCanvas2");


//FIXATION AND DOTS PLUGIN
	var trial_presentation_xabpos = 
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
	data: {Task_type: 'simpleperceptual', label: 'dottedstim', numDots:numDots1},
	timing_post_trial: 0
	};
	
	var trial_presentation_doublestim = 
	{
	type: 'doublestim',
	stimuli: [function() // Note the specifics of how the stimuli function is wrapped in brackets like so: [function(){}]
				{
					 //var data = jsPsych.data.getLastTrialData();
                    //var numDots1 = data.numDots;
                    
                    var stim1 = draw_stimulus("myInnerCanvas", Math.round(Math.exp(numDots1))); // Create stimulus 1
				    var stim2 = draw_stimulus("myInnerCanvas2", numDots2); // Create stimulus 2 //stim 2 is the one with the LESS dots
					var stimulus = [stim1, stim2];
					return stimulus;
				}],
	left_key: [],
	right_key: [],
	timing_ab: stim_time, // Stimulus presentation = max_RT
	timing_response: stim_time,
	data: {Task_type: 'simpleperceptual', label: 'dottedstim', numDots:numDots2},//to safe also numdots_use in main task
	timing_post_trial: 0,
	};
	
	var scale = ["<p>certainly left</p>","","","", "","","", "<p>certainly right</p>"];

	//CONFIDENCE RATING PLUGIN
	var confratingscale = 
	{ 
	    type: "survey-likert",
		questions: [['<p style = "text-align: center; font-size: 28px">Make your judgment:<br></br></p>']],
		labels: [[scale]],
		intervals: [[8]],
		data:function()
		{var data = jsPsych.data.getLastTrialData();
		return {tNum:data.tNum, label: 'confidence_rating', Task_type: 'conftask'};
		},
		on_finish: function()// This part is crucial
		{
		var data = jsPsych.data.getLastTrialData(); // Get data from the response block (on_finish evaluates getLastTrialData() as the trial that is currently being coded under)
        var confidence_rating = parseInt(data.responses[6], 16);
       
        if (confidence_rating > 4 && stimpos == 2){ // chose right, correct
        data.correct = Boolean(true); 
        }else if (confidence_rating < 4 && stimpos == 1){ //chose left, correct
        data.correct = Boolean(true); 
        }else if (confidence_rating > 4 && stimpos == 1){
        data.correct = Boolean(false); 
        }else {
        data.correct = Boolean(false); 
		};
		var new_data = {confidence_rating: confidence_rating, 
		correct: data.correct, 
		dir:stimpos}
		gorilla.metric(new_data)
        jsPsych.data.addDataToLastTrial(new_data);
        data = jsPsych.data.getLastTrialData();
		gorilla.metric(data);
		}
	};
		
//GROUPT EXPERIMENTAL TRIAL INTO ONE CHUNK + PUSH IT
	var exptchunk= {
	chunk_type:'linear',
	timeline: [check_fullscreen2, trial_presentation_xabpos, 
	trial_presentation_doublestim,  trial_presentation_doublestim, 
	trial_presentation_doublestim, trial_presentation_doublestim, confratingscale]
	};

////////////////////////////
//END OF EXPERIMENTAL TASK//
////////////////////////////

return exptchunk;

};