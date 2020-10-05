    import gorilla = require('gorilla')//only if using Gorilla interface

    //prevent participants from pressing their spacebar and going down the webpage
    window.onkeydown = function(e) 
    {
        if(e.keyCode == 32 && e.target == document.body) 
        {
            e.preventDefault();
            return false;
        }
    };

    //check if browser is chrome or firefox mozilla 
    function getBrowserInfo() 
    { 
        var ua = navigator.userAgent, tem, 
        M = ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || []; 
        if(/trident/i.test(M[1])) 
        { 
                tem=  /\brv[ :]+(\d+)/g.exec(ua) || []; 
                return 'IE '+(tem[1] || ''); 
        } 
        if(M[1]=== 'Chrome') 
        { 
                tem= ua.match(/\b(OPR|Edge)\/(\d+)/); 
                if(tem!= null) return tem.slice(1).join(' ').replace('OPR', 'Opera'); 
        } 
        M = M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?']; 
        if((tem= ua.match(/version\/(\d+)/i))!= null) 
                M.splice(1, 1, tem[1]); 
        return { 'browser': M[0], 'version': M[1] }; 
    } 

    gorilla.ready(() => 
    {
        gorilla.populate('#gorilla', 'task');

        var browserInfo = getBrowserInfo();
        if (browserInfo.browser !== 'Chrome' && browserInfo.browser !== 'Firefox') 
        {
            var wrong_browser =
                {
                    type: 'text',
                    text: '<p>This experiment only has support for Google Chrome or Mozilla Firefox.</p>'
                    + '<p>Please reopen the experiment in one of these browsers.</p>',
                };
            jsPsych.init({experiment_structure: [wrong_browser]});
        }
        else //browser is ok, prepare the experiment
        {   
            //get the canvas properties of this participants' specific screen
            var canvas = document.getElementById("myCanvas");//setup web and canvas parameters & get window height and width
            var context = canvas.getContext("2d");
            context.canvas.width = 800;
            context.canvas.height = 600 * 9.0 / 10.0;
            var centerWidth = canvas.width / 2.0;
            var centerHeight = canvas.height / 2.0;

            var innerCanvas = document.getElementById("myInnerCanvas");//Get properties for canvas left box
            var innerContext = innerCanvas.getContext("2d");
            innerContext.canvas.width = 800 / 2.0; // Half the width of the screen
            innerContext.canvas.height = 600 * 9.0 / 10.0; // Leave room for prompts
            var innerCenterWidth = innerCanvas.width / 2.0;
            var innerCenterHeight = innerCanvas.height / 2.0;

            var innerCanvas2 = document.getElementById("myInnerCanvas2");  //Get properties for canvas right box
            var innerContext2 = innerCanvas2.getContext("2d");
            innerContext2.canvas.width = 800 / 2.0; // Half the width of the screen
            innerContext2.canvas.height = 600 * 9.0 / 10.0; // Leave room for prompts
            var innerCenterWidth2 = innerCanvas2.width / 2.0;
            var innerCenterHeight2 = innerCanvas2.height / 2.0;

            var blankstimCanvas = document.getElementById("myBlankstimCanvas"); //Get properties for canvas blank stim
            var blankstimContext = blankstimCanvas.getContext("2d");
            blankstimContext.canvas.width = 800; // Full width of the screen
            blankstimContext.canvas.height = 600 * 9.0 / 10.0; // Leave room for prompts
            var blankstimCenterWidth = blankstimCanvas.width / 2.0;
            var blankstimCenterHeight = blankstimCanvas.height / 2.0;

            var feedbackCanvas = document.getElementById("myFeedbackCanvas");//Canvas for feedback
            var feedbackContext = feedbackCanvas.getContext("2d");
            feedbackContext.canvas.width = 800; // Full width of the screen
            feedbackContext.canvas.height = 600 * 9.0 / 10.0; // Leave room for prompts
            var feedbackCenterWidth = feedbackCanvas.width / 2.0;
            var feedbackCenterHeight = feedbackCanvas.height / 2.0;

            //define how many trials you would like to do 
            var practice = 1; //do you want a calibration phase (yes = 1, no = 0)
            var numPrac = 52; //how many calibration trials? standard = 52
            var numTrials = 60; //how many meta-task trials? standard = 60
            var subject_id = Math.floor(Math.random() * 9000000) + 1000000; //generate a random subject-id for this particular participant

            var numPrac_change = 2; //how much do you want to practise the advice-taking task? standard = 2
            var numTrials_change = 120;//trials for advice-taking Task needs to be 2 times numTrials confidence task
    
            var scale = ["<p>certainly left</p>","","","",  "","","", "<p>certainly right</p>"]; //define what the confidence scale looks like (only outer labels)
        
            ////////////////////////////////
            //START OF EXPERIMENT PLUGINS//
            ///////////////////////////////
    
            var fullscreen = { //make sure that participants are in fullscreen
                type: 'fullscreen',
                showtext: '<p>To take part in the experiment, your browser must be in fullscreen mode. Exiting fullscreen mode will pause the experiment. <br></br>Please click the button below to enable fullscreen mode and continue.</p>',
                buttontext: "Fullscreen"
            };
        
            var welcome_block = {//make them press their spacebar to continue
                type: 'text',
                text: ['<p style = "text-align: center; font-size: 28px; color:gold">Press spacebar to continue.</p>'],
                data: { label: 'welcome' },
                cont_key: 32
            };
            //TO DO: make separate intructions script so that main script stays clean from lots of text

            //(1) load in the calibration task + instructions
            var metacog_prac_task = metaTask_prac(practice, numPrac); //load the practise trials 'numPrac' times (returns an array of practise trials to display)

            var begin_task = //next, participants need to be instructed about the use of the confidence scale
            {
                type:"instructions",
                pages:'<p class="instructions">In the next part of the experiment, you will not be provided accuracy feedback on your judgements, instead, you will be asked to rate your confidence and direction judgment.</p>' +
                '<p class="instructions">You will be asked to rate your direction and confidence judgement on a rating scale after each trial, which will be explained next.</p>',
                data: {label: 'intruct'},
                show_clickable_nav: true,
                allow_keys: false,       
                allow_backward: false,
            };
            //...and get them to play around with the confidence scale a bit
            var confid_prac1 = ['<p class="instructions">A rating scale as shown below is used throughout the task. You will be able to rate your confidence of your judgements by choosing any point along the rating scale with your mouse. <br> </br> Choose any point on the rating scale and click ‘Submit Answer’ to continue the instructions.</p><br>'];
            var confid_prac3 = ['<p class = "instructions"><br> </br> Choose any point on the rating scale and click ‘Submit Answer’ to start the task.</p><br>']
            var confid_prac_ans = [ '<p class = "instructions" > If you think that the <strong>left</strong> box contained more dots, you should click on the <strong>left</strong> side of the scale. </p>' + 
            '<p class = "instructions" > If you think that the <strong>right</strong> box contained more dots, you should click on the <strong>right</strong> side of the scale. </p>'];
            var confid_prac_ans2 = ['<p class="instructions"> Each step away from the centre of the confidence scale indicates higher confidence, the tick marks provide visual guidence in this.</p>' +
            '<p class="instructions">If you are <strong>unsure</strong> whether you are making a correct or incorrect judgement, for example, because you were accidentally not paying attention, you should respond <strong>closer to the centre</strong> of the scale.</p>' + 
            '<p class="instructions">If you are <strong>sure</strong> that you are making a correct judgement, you should respond <strong>closer to the edges</strong> of the scale.</p>'];
            var confrating_prac1 =   //instructions + click to proceed
            { 
                type: "survey-likert",
                questions: [confid_prac1],
                labels: [[scale]],
                intervals: [[8]],
                data:{label: 'confidprac', Task_type: 'practice'}
            };
            var confrating_prac1_ans =  //explanation of confidence scale
            {
                type: "instructions",
                pages: confid_prac_ans,
                data:{label: 'confidprac', Task_type: 'practice'},
                show_clickable_nav: true,
                allow_keys: false,
                allow_backward: false,
            };
            var confrating_prac2 = //more instructions
            {   
                type: "instructions",
                pages: confid_prac_ans2,
                data:{label: 'confidprac', Task_type: 'practice'},
                show_clickable_nav: true,
                allow_keys: false,
                allow_backward: false,
            };
            var confrating_prac3 =       //click to proceed to the meta task
                {      
                    type: "survey-likert",
                    questions: [confid_prac3],
                    labels: [[scale]],
                    intervals: [[8]],
                    data:{label: 'confidprac', Task_type: 'practice'}
                };
        
            //now determine whether the box with highest density should be on the left or right box
            stimdeviset('trial',numTrials); //returns pracpos only (randomise left/right bc i removed the auto option in the pulgin)
         
            // (2) load in the meta task + instructions
            var metacog_task = []; 
            for (var i = 0; i < numTrials; i++)
            { 
                if (i === 20|| i === 40 || i === 60)//if it's a break-trial
                {
                    var block = Math.floor(i/20);//which block nr? 
                    var task_break =
                    {
                        type:"instructions",
                        pages: '<p class="instructions">You can now pause for a break. You have completed '+block+' out of 3 blocks. </p>' +
                        '<p class="instructions">Click <strong>Next</strong> to <strong>continue</strong> the task.</p>',
                        show_clickable_nav: true,
                        allow_keys: false,
                        allow_backward: false
                    }
                    metacog_task.push(task_break)//push the break
                }   
            else
                {
                    metacog_task.push(metaTask(stimpos2[i], i));//if not a break, run the meta-task for each trial (i) and the pre-specified objectively correct box (stimpos[i])
                }
            };

            //Now prepare the practice ('prac') advice-taking stimulus set
            advdeviset('prac', numPrac_change, 2,3); //for n trials, generates stimpos [l/r as 1/2]; advpos [adviser type as 1/2/3]; and advconf [confidence adviser as 1-8]
        
            //load the instructions for the advice-taking task					 
            var instr  = ['<p class="instructions"><strong>Task change!</strong></p>' +
            '<p class="instructions">The task will now change slightly. We will still ask you to judge which of two images contains more dots by asking you to rate your confidence and left/right judgement on a scale.</p>' +
            '<p class="instructions">However, this time you will get some help in making that decision. </p>' +
            '<p class="instructions">We have paired you with <strong>two other participants</strong> and will show you what they decided on the same trial. On every trial you can use their direction and left/right judgment to update a <strong>final </strong>decision. </p>']
            //append more instructions
            instr.push('<p class="instructions"> Trials on this task will look as following: <strong> First</strong>, you will see dots and rate your confidence and left/right judgment (like you did before).</p>' +
            '<p class="instructions"> <strong> Then </strong> you will receive <strong>advice</strong>, consisting of what a previous participant selected as their confidence and left/right judgment on the same trial. </p>' + 
            '<p class="instructions"> <strong> Finally</strong> you will judge a <strong> final time </strong> how confident you are and which box you think had most dots (considering all evidence given to you on that trial) .</p>')
            //append more instructions
            instr.push('<p class = "instructions"> Each of <strong> your two advisers </strong> will have the same silhoutte with a different background colour. These colours can help you distinguish between the two advisers. </p>' + 
            '<p class="instructions">Importantly, we paired you with two persons that have a similar performance. <strong>This means that the participants that you will play with are as good as you are in doing the task </strong>.</p>' +
            '<p class="instructions">Really focus on figuring out wehther the advisers are <strong>reliable</strong> or not. During the breaks you will be asked questions about this.</p>')
            //append more instructions
            instr.push('<p class="instructions">We will now ask you to carry out <strong>two practice trials</strong> of this new task. </p>'+
            '<p class="instructions">This is to help you get familiar with the new task structure.</p>' + 
            '<p class="instructions">Click <strong>Next</strong> to <strong>start</strong>.</p>');

            var instructions =  //show the instructions with the jsPsych plugin
            {
                type:"instructions",
                pages:instr,
                data:{label: 'intruct'},
                show_clickable_nav: true,
                allow_keys: false,
                allow_backward: false
            };
        
            //(3) load change of mind task + instructions and practise 
            var change_of_mind_instr_task = []; //instead of getting the 'experiment' list, concat them for each i'th element of the advisers characteristics
            for (var i=0; i < numPrac_change; i++)
            { 
                change_of_mind_instr_task.push(changeOfMind_instr(pracpos[i], advpos2_prac[i], advconf_prac[i], i));//for each trial (i) with the corresponding obj. correct direction and adv-positions
            };
            //as soon as they've finished the instructions, prompt the start of the real experiment: 
            var after_change_prac_instr =
            {   
                type: "instructions",
                pages: ['<p class = "instructions"><strong>Lets proceed to the final task!</strong> This task will take between 20-30 minutes </p>'+
                '<p class = "instructions">As a reminder, on each trial you will see what a previous participant decided on that trial. You can use their advice to update your judgment if you think that its reliable.</p>'+
                '<p class = "instructions">Click <strong>Next</strong> to <strong>start</strong>.</p>'],
                data:{label: 'confidprac', Task_type: 'practice'},
                show_clickable_nav: true,
                allow_keys: false,
                allow_backward: false
            };
        
            //returns both the stimpos and the perm with which we permutate the stimpos (and later on also the adviser conf levels and position)
            stimdeviset('trial', numTrials_change);
            //load in the actual change of mind task
            var change_of_mind_task = []; 
            for (var it = 0; it < numTrials_change; it++)
            { 
                if (it === 20 || it === 40 || it === 60 || it === 80 || it === 100 || it === 120)//if a block, pause 
                {
                    var block2 = Math.floor(it/20);//get which block they're currently at
                    //TO DO: make the opinion questions code shorter by looping through them 
                    //during each block pause, ask them their current opinion of the advisers 
                    const adviser_scale = ["1<br> Not at all", "2", "3", "4", "5", "6", "7<br>Very much"] //..which answers they give on a scale from "not at all" to "very much"
                    var adviser1_question1 = ['<p style = "font-size: 20px; color:deepskyblue"><b>How <strong>accurate</strong> do you think <strong>Participant O. S. </strong> is?</b>'];
                    var adviser2_question1 = ['<p style = "font-size: 20px; color:gold"><b>How <strong> accurate</strong> do you think <strong>Participant D. M.</strong> is?</b>'];
                    var adviser1_question2 = ['<p style = "font-size: 20px; color:deepskyblue"><b>How <strong> confident </strong> do you think <strong>Participant O. S.</strong> is?</b>'];
                    var adviser2_question2 = ['<p style = "font-size: 20px; color:gold"><b>How <strong> confident</strong> do you think <strong>Participant D. M. </strong> is?</b>'];
                    var adviser1_question3 = ['<p style = "font-size: 20px; color:deepskyblue"><b>How <strong>trustworthy</strong> do you think <strong>Participant O. S. </strong> is?</b>'];
                    var adviser2_question3 = ['<p style = "font-size: 20px; color:gold"><b>How <strong>trustworthy</strong> do you think <strong>Participant D. M. </strong> is?</b>'];
                    var adviser1_question4 = ['<p style = "font-size: 20px; color:deepskyblue"><b>How <strong>influential on your choices</strong> do you think <strong>Participant O. S. </strong> is?</b>'];
                    var adviser2_question4 = ['<p style = "font-size: 20px; color:gold"><b>How <strong>influential on your choices</strong> do you think <strong>Participant D. M. </strong> is?</b>'];
        
                    var adviser_rating1 = //display the first opinion question to them
                    {
                        type: "survey-likert", 
                        preamble: ['<p style = "font-size: 20px"> <strong>Well done!</strong> You have completed '+block2+' out of 6 blocks. </p>'+
                        '<p style = "font-size: 20px"> Now will follow eight short questions about the participants that you played with. Please take these questions seriously.</p>'],
                        questions: [adviser1_question1],
                        labels:[[adviser_scale]],
                        intervals: [[7]],
                        data: function()
                        {
                            var intro_data = jsPsych.data.getLastTrialData(); 
                            var adviser_rating = parseInt(intro_data.responses[6], 10); //extract response from answer
                            jsPsych.data.addDataToLastTrial({label: adviser_rating, block:it, adviser_rating: adviser_rating}),//save response
                            data = jsPsych.data.getLastTrialData(); 
                            gorilla.metric(data)
                        }
                    };
                    change_of_mind_task.push(adviser_rating1) //append the opinion questions to the main experiment array
                    //do the same for all the other questions: 
                    var adviser_rating2 = 
                    {
                        type: "survey-likert", questions: [adviser2_question1],labels:[[adviser_scale]],intervals: [[7]],data: function()
                        {
                            intro_data = jsPsych.data.getLastTrialData(); 
                            var adviser_rating = parseInt(intro_data.responses[6], 10); 
                            jsPsych.data.addDataToLastTrial({label: adviser_rating, block:it, adviser_rating: adviser_rating}),//save response
                            data = jsPsych.data.getLastTrialData(); 
                            gorilla.metric(data)
                        }
                    };
                    change_of_mind_task.push(adviser_rating2)
                    //idem
                    var adviser_rating3 = 
                    {
                        type: "survey-likert", questions: [adviser1_question2],labels:[[adviser_scale]],intervals: [[7]],data: function()
                        {
                        var intro_data = jsPsych.data.getLastTrialData(); 
                        var adviser_rating = parseInt(intro_data.responses[6], 10); 
                        jsPsych.data.addDataToLastTrial({label: adviser_rating, block:it, adviser_rating: adviser_rating}),//save response
                        data = jsPsych.data.getLastTrialData(); 
                        gorilla.metric(data)
                        }
                    };
                    change_of_mind_task.push(adviser_rating3)
                    //idem
                    var adviser_rating4 = 
                    {
                        type: "survey-likert", questions: [adviser2_question2],labels:[[adviser_scale]],intervals: [[7]],data: function()
                        {
                            var intro_data = jsPsych.data.getLastTrialData(); 
                            var adviser_rating = parseInt(intro_data.responses[6], 10); 
                            jsPsych.data.addDataToLastTrial({label: adviser_rating, block:it, adviser_rating: adviser_rating}),//save response
                            data = jsPsych.data.getLastTrialData(); 
                            gorilla.metric(data)
                    }
                };
                change_of_mind_task.push(adviser_rating4)
                //idem
                var adviser_rating5 = 
                {
                    type: "survey-likert", questions: [adviser1_question3],labels:[[adviser_scale]],intervals: [[7]],data: function()
                    {
                        var intro_data = jsPsych.data.getLastTrialData(); 
                        var adviser_rating = parseInt(intro_data.responses[6], 10); 
                        jsPsych.data.addDataToLastTrial({label: adviser_rating, block:it, adviser_rating: adviser_rating}),//save response
                        data = jsPsych.data.getLastTrialData(); 
                        gorilla.metric(data)
                    }
                };
                change_of_mind_task.push(adviser_rating5)
                //idem
                var adviser_rating6 = 
                {
                    type: "survey-likert", questions: [adviser2_question3],labels:[[adviser_scale]],intervals: [[7]],data: function()
                    {
                        var intro_data = jsPsych.data.getLastTrialData(); 
                        var adviser_rating = parseInt(intro_data.responses[6], 10); 
                        jsPsych.data.addDataToLastTrial({label: adviser_rating, block:it, adviser_rating: adviser_rating}),//save response
                        data = jsPsych.data.getLastTrialData(); 
                        gorilla.metric(data)
                    }
                };
                change_of_mind_task.push(adviser_rating6)
                //idem
                var adviser_rating7 = 
                {
                    type: "survey-likert", questions: [adviser1_question4],labels:[[adviser_scale]],intervals: [[7]],data: function()
                    {
                        var intro_data = jsPsych.data.getLastTrialData(); 
                        var adviser_rating = parseInt(intro_data.responses[6], 10); 
                        jsPsych.data.addDataToLastTrial({label:adviser_rating, block:it, adviser_rating: adviser_rating}),//save response
                        data = jsPsych.data.getLastTrialData(); 
                        gorilla.metric(data)
                    }
                };
                change_of_mind_task.push(adviser_rating7)
                //idem
                var adviser_rating8 = 
                {
                    type: "survey-likert", questions: [adviser2_question4],labels:[[adviser_scale]],intervals: [[7]],data: function()
                    {
                        var intro_data = jsPsych.data.getLastTrialData(); 
                        var adviser_rating = parseInt(intro_data.responses[6], 10); 
                        jsPsych.data.addDataToLastTrial({label:adviser_rating, block:it, adviser_rating: adviser_rating}),//save response
                        data = jsPsych.data.getLastTrialData(); 
                        gorilla.metric(data)
                    }
                };
                change_of_mind_task.push(adviser_rating8)
                //after all those opinion questions, proceed to next block
                var task_break2 = 
                {
                    type: "instructions", pages: '<p class= "instructions">Thank you! </p>' + '<p class= "instructions">Click <strong>Next</strong> to <strong>continue</strong> the task. </p>',
                    show_clickable_nav: true, allow_keys: false,allow_backward: false  
                };
                change_of_mind_task.push(task_break2)//as soon as they've finished their break questions...
                change_of_mind_task.push(changeOfMind(numTrials_change,stimpos1, stimpos2, stimpos2[it], perm)); //...let them proceed to the final trial of that block
            }
            else //if it's not a break-trial
            {
                change_of_mind_task.push(changeOfMind(numTrials_change, stimpos1, stimpos2, stimpos2[it], perm)); //..let them proceed to the next trial as usual
            }
        };
                
        //push all those separate elements to generate a timeline of the whole task
        var tasks = [];
        tasks.push(fullscreen);
        tasks.push(welcome_block);
        for (var i = 0; i < metacog_prac_task.length; i++) {
            tasks.push(metacog_prac_task[i]);
        };
        tasks.push(begin_task); 
        tasks.push(confrating_prac1);
        tasks.push(confrating_prac1_ans); 
        tasks.push(confrating_prac2);
        tasks.push(confrating_prac3);
        for (var i = 0; i < metacog_task.length; i++) {
            tasks.push(metacog_task[i]);
        };
        tasks.push(instructions); 
        for (var i = 0; i < change_of_mind_instr_task.length; i++) {
            tasks.push(change_of_mind_instr_task[i]);
        };
        tasks.push(after_change_prac_instr); 
        for (var i = 0; i < change_of_mind_task.length; i++) {
            tasks.push(change_of_mind_task[i]);
        };

        //run and save the experiment
        jsPsych.init({
            experiment_structure: tasks,
            display_element: $('#jspsych-target'),
            show_progress_bar:false,
            on_trial_finish: function () {

                jsPsych.data.addProperties({
                    subject_id: subject_id,
                });
            }, on_finish: function () {
                gorilla.finish();
            }
        });

    }
});