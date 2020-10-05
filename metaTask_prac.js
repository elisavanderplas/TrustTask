import gorilla = require('gorilla') //only if using Gorilla interface

export function meta_task_prac(practice, numPrac)
{

var experiment = []; 

if(numPrac > 0)
{
    	//GENERAL INSTRUCTIONS							 
 	    var instr  = ['<p class="instructions">In this task we will ask you to judge which of two images contains more dots, and will ask you to rate your confidence in your judgement.</p>' + 	'<p class="instructions">At the beginning of each trial, you will be presented with a black cross in the middle of the screen. Focus your attention on it. Then, two black boxes with a number of flickering white dots will be shown and you will be asked to judge which box had a higher number of dots.</p>' +
 	    '<p class="instructions">If the box on the <strong>left</strong> had more dots, <strong>press W</strong>.<br> If the box on the <strong>right</strong> had more dots, <strong> press E</strong>.</p>' +
 	    '<p class="instructions">Please respond quickly and to the best of your ability.</p>' +
	    '<p class="instructions">You will then rate your confidence in your judgement on a scale with the mouse.</p>' +
 	    '<p class="instructions">Please do your best to rate your confidence accurately and do take advantage of the whole rating scale.</p>' +
 	    '<p class="instructions">Try to be as accurate as possible.</p>'];
 	    
//IF NO PRACTICE, GO STRAIGHT TO EXPERIMENTAL INSTRUCTIONS
 if (practice == 0) 
 {
 	instr.push('<p class="instructions">You will now continue directly to the experiment. The dots will presented only for a short period of time.</p>' +
 	'<p class="instructions">You will be asked to rate your confidence in your judgement after each trial.</p>' +
 	'<p class="instructions">Press spacebar to continue.</p>');
 }

 //IF GOT PRACTICE, GO TO PRACTICE INSTRUCTIONS
 else 
 {
 	    instr.push('<p class="instructions">First, you will start with the task of just judging which box contains more dots. Please respond only when the dots have disappeared.</p>' +  
    	'<p class="instructions">In this phase we will tell you whether your judgements are right or wrong. <br></br>If you are <strong>correct</strong>, the box that you selected will be outlined in <font color="green"><strong>green</strong></font>. <br>If you are <strong>incorrect</strong>, the box that you selected will be outlined in <font color="red"><strong>red</strong></font>.</p>' +
 	    '<p class="instructions">In this part of the experiment you will <strong>not</strong> need to rate your confidence. Please perform to the best of your ability.</p>'+
 		'<p class="instructions">Click <strong>Next</strong> to <strong>start</strong> the task.</p>');
 }
        //INSTRUCTIONS PLUGIN + PUSH IT
 	    var instructions = 
 	    {
 	    type:"instructions",
 	    pages:instr,
 	    data:function(){ 
 	        jsPsych.data.addProperties({trialNum: 0});
 	        return {label: 'intruct' };
 	        },
 		    show_clickable_nav: true,
            allow_keys: false,
            allow_backward: false,
    	};

        experiment.push(instructions); 


//EXPERIMENT PARAMETERS 
    // Create variables for timing
	var fixation_time = 1000;
	var feedback_trial_time = 500;
	// originally 1000
	var prac_stim_time= 300;
	var stim_time= 150; //same as Max'  
	var max_CR_RT = -1;
	var inter_trial_interval = 500;
		
	// Initialize staircase variables
	var responseMatrix_s2 = [true, true];
	var reversals = 0; 
	var s2_dir = ["up", "up"];//Evdp
	var reversals2 = 0;
	var difficulty_staircase_index=0;
	var numDots1 = 4.8;  //in log space; this is about 104 dots which is 70 dots shown for the first one
	var numDots2 = 0;
	var tNum=0;
	var difficulty_first_trials=5;
    var difficulty_start_staircase=4.8;
    var NumDots_use=4.8;
    var numDots_average=0;
	var trial_staircase=0;
	var difficulty_distribution=[1,1.3]
	var number_repetition=(numPrac-23)/2
    var tempDiff = [];
    var difficulty_staircase = [0];
    var difficulty_staircase_use=1;
    var repetition_limit=1;
    
  for (var i=0; i<number_repetition; i++) {
    tempDiff = tempDiff.concat(difficulty_distribution);
  };


while(repetition_limit==1){
	repetition_limit=2;
	tempDiff = shuffle(tempDiff);

	for(var i=0; i<tempDiff.length; i++)
	if (i<tempDiff.length+2){
    if (tempDiff[i]==tempDiff[i+1])
    {
        if (tempDiff[i]==tempDiff[i+2]){
                    if (tempDiff[i]==tempDiff[i+3]){

   repetition_limit=1; 
                    };
    };
    };
    };
    };
	difficulty_staircase = difficulty_staircase.concat(tempDiff);
console.log(difficulty_staircase)

jsPsych.data.addProperties({difficulty_staircase: difficulty_staircase});
jsPsych.data.addProperties({difficulty_staircase_use: difficulty_staircase_use});
jsPsych.data.addProperties({difficulty_staircase_index: difficulty_staircase_index});	

if (practice != 0)
{
    
//the stim deviation
stimdeviset('prac',numPrac); //returns pracpos only (randomise left/right bc i removed the auto option in the pulgin)

//PRACTICE TRIAL LOOP
for(var i = 0;i < numPrac;i++)
{

//FULLSCREEN PLUGIN
		var check_fullscreen = 
		{type: 'fullscreen',    
		showtext: '<p>You need to be in fullscreen mode to continue the experiment! <br></br> Please click the button below to enter fullscreen mode.<br></br><p>',    
		buttontext: "Continue"
		};		
		
		var blankstim1 = draw_stimulus("myInnerCanvas");
		var blankstim2 = draw_stimulus("myInnerCanvas2");
		
		var stimpos = pracpos[i];
        
//FIXATION AND DOTS PLUGIN  
	var practice_trial_xabpos = 
	{type: 'xabpos',
	stimuli: [function() // Note the specifics of how the stimuli function is wrapped in brackets like so: [function(){}]
	{
					++tNum;
					s2 = staircase2edit(numDots1, responseMatrix_s2, s2_dir,tNum); 
					
				    numDots1 = s2.diff;
				    NumDots_use=numDots1;
					s2_dir = s2.direction;
					responseMatrix_s2 = s2.stepcount;
					if (s2.reversal) // Check for reversal. If true, add one to reversals variable
			    	{
					reversals2 += 1;
			    	}
                    jsPsych.data.addProperties({numDots: numDots1});
                    jsPsych.data.addProperties({reversals2: reversals2});
                    jsPsych.data.addProperties({tNum:tNum}); 
                    
        			var stim1 = draw_stimulus("myInnerCanvas", Math.round(Math.exp(NumDots_use))); // Create stimulus 1
				    var stim2 = draw_stimulus("myInnerCanvas2", numDots2); // Create stimulus 2 //stim 2 is the one with the LESS dots

					var stimulus = [gorilla.resourceURL('fixation5.png'), stim1, stim2];
					return stimulus;
				}],
	pos: stimpos,
	timing_x: fixation_time,
	timing_xab_gap: -1,
	timing_ab: stim_time, // Stimulus presentation = max_RT
	timing_response: stim_time,
	data: function() 
	{var data = jsPsych.data.getLastTrialData();
	 return {trialType: 'practice', label: 'dottedstim', numDots:numDots1, NumDots_use:NumDots_use, tNum:tNum};
	},
	timing_post_trial: 0,
	};
	
	var practice_trial_doublestim = 
	{type: 'doublestim',
	stimuli: [function() // Note the specifics of how the stimuli function is wrapped in brackets like so: [function(){}]
				{   if (tNum<3){
                    NumDots_use=difficulty_first_trials;
                    };
					var stim1 = draw_stimulus("myInnerCanvas", Math.round(Math.exp(NumDots_use))); // Create stimulus 1
				    var stim2 = draw_stimulus("myInnerCanvas2", numDots2); // Create stimulus 2 //stim 2 is the one with the LESS dots
					var stimulus = [stim1, stim2];
					return stimulus;
					if (tNum<3){
                    NumDots_use=difficulty_start_staircase;
                    };
				}],
	left_key: [],
	right_key: [],
	timing_ab: stim_time, // Stimulus presentation = max_RT
	timing_response: stim_time,
	data: {trialType: 'practice', label: 'dottedstim', NumDots_use:NumDots_use},
	timing_post_trial: 0,
	};

//RESPONSE PLUGIN
	var practice_trial_answer = 
	{
	type: 'doublestim',
	stimuli: [[blankstim1,  blankstim2]],
	left_key: 87,
	right_key: 69,
	timing_ab: -1, // Stimulus presentation = max_RT
	prompt: '<p style="text-align:center; font-size: 24px">Press W if the box on the left had more dots. Press E if the box on the right had more dots.</p>',
	timing_response: -1,
	data: function() 
	{
	    var data = jsPsych.data.getLastTrialData();
    	return {blankstim1: blankstim1, blankstim2: blankstim2, Task_type: 'practice',  label: 'responsePerceptual_practice',NumDots_use:NumDots_use};
	},//need this for feedback
	timing_post_trial: 0,
	on_finish: function() // This part is crucial
				{
					var data = jsPsych.data.getLastTrialData(); // Get data from the response block (on_finish evaluates getLastTrialData() as the trial that is currently being coded under)
					var correct = JSON.parse(data.correct); // Get boolean True/False if correct
					if (data.difficulty_staircase_use==1){
					responseMatrix_s2 = responseMatrix_s2.concat(correct);
					};
					var response = JSON.parse(data.key_press);
					var reactiontime = JSON.parse(data.rt);
					var dir = stimpos;
					gorilla.metric(data);
				}
			};

//FEEDBACK PLUGIN
	var practice_feedback = 
	{
	type: 'single-stim',
	stimuli: function() // Draw feedback as a function relative to which stimulus they responded to and whether their response was correct 
	{
	var data = jsPsych.data.getLastTrialData();
	var response = JSON.parse(data.key_press);
	var correct = JSON.parse(data.correct);
	
	var blankstim1 = data.blankstim1; //this is just to show the boxes in feedback
	var blankstim2 = data.blankstim2; 

	// Save which stimulus will be used for feedback
	var feedbackStim = "";
	if (correct)
	feedbackStim = blankstim1; 
	else
	feedbackStim = blankstim2;

	var responseSide = "none";
	if(response === 87) // Pressed W
	responseSide = "left";
	else if (response === 69) // Pressed E
	responseSide = "right";
	else // If they didn't respond
	feedbackStim = ""; // Display no stimulus during feedback

	return draw_feedback(responseSide, feedbackStim, correct);
	},
	timing_stim: feedback_trial_time,
	timing_response: feedback_trial_time,
	data: {trialType: 'practice', label: 'feedback'},
	prompt: function() // Give feedback on correctness of trial in words as well
	{
	var data = jsPsych.data.getLastTrialData();
	var correct = JSON.parse(data.correct);
	if(correct)
	return '<p style = "text-align:center; font-size: 24px">Correct</p>';
	else
	return '<p style = "text-align:center; font-size: 24px">Incorrect</p>';
	},
	choices: ['none'],
	timing_post_trial: inter_trial_interval		
	};

//PUSH THE WHOLE TRIAL
	var practchunk= {
	chunk_type:'linear',
	timeline: [check_fullscreen, practice_trial_xabpos, practice_trial_doublestim, 
	practice_trial_doublestim, practice_trial_doublestim, practice_trial_doublestim, 
	practice_trial_answer, practice_feedback]
	};
	
	experiment.push(practchunk); 
	
}
};
};

 	return experiment; 


};

