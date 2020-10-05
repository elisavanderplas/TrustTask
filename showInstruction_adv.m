
function [locDATA] = showInstruction_adv(task, screenInfo, params, locDATA)
% [locDATA] = function showInstruction(part, task, screenInfo, params, locDATA)
%
% Shows instructions and examples for a random dot motion task.
%
% Instructions for buttonpress, coherence and reactions for task 1.
% Instructions for confidence rating, the Quadratic Scoring Rule and
% post-decision evidence for task 2.


curWindow = screenInfo.curWindow;
L_motion = (180/360) * (2*pi);
R_motion = (360/360) * (2*pi);

    if task == 1
        % present first instructions
        DrawFormattedText(curWindow, ['Welcome to this experiment. You will be asked to perform a motion judgment task. \n \n \n',...
            'For this first task you will perform 240 trials divided over 4 blocks. We do this to identify how many dots you need to see to reach a specific performance-level. \n \n \n',...
            'Please keep your eyes fixated on the white fixation dot during the trials. Moving dots will appear around it. \n \n \n',...
            'Press any key when you are ready to an example of the moving dots.'],...
            'center', 'center', [255 255 255]);
        Screen('Flip', curWindow,0);
        WaitSecs(2);
        KbWait(-1);
        
        % show 100% leftward motion example
        showLocalizerDots_random(1, 1, 2000, L_motion, params, screenInfo);
        
        
        DrawFormattedText(curWindow, ['In this example, all dots moved to the left. \n \n \n',...
            'Now press any key again to see an example in which all dots move to the right.'],...
            'center', 'center', [255 255 255]);
        Screen('Flip', curWindow,0);
        WaitSecs(1);
        KbWait(-1);
        
        % show 100% rightward motion example
        showLocalizerDots_random(1, 1, 2000, R_motion, params, screenInfo);
        
        
        DrawFormattedText(curWindow, ['These examples were both pretty easy because all dots moved in one direction. \n \n \n',...
            'In the experiment, some of the dots will behave randomly, whereas others move to the right or left of the screen. \n \n \n',...
            'Your task is to guess the overall direction of the dots. \n \n \n',...
            'To see what this random motion looks like, press any key again.'],...
            'center', 'center', [255 255 255]);
        Screen('Flip', curWindow,0);
        WaitSecs(1);
        KbWait(-1);
        
        % show 20% leftward motion
        showLocalizerDots_random(1, 0.20, 2000, L_motion, params, screenInfo);
        
        DrawFormattedText(curWindow, ['During the experiment you will have less time to look at the dots. \n \n \n',...
            'Press any key to see what an actual trial will look like.'],...
            'center', 'center', [255 255 255]);
        Screen('Flip', curWindow,0);
        WaitSecs(1);
        KbWait(-1);
        
        % show 30% leftward motion
        showLocalizerDots_random(1, 0.30, 300, L_motion, params, screenInfo);
        WaitSecs(0.2);
        
        DrawFormattedText(curWindow, ['When the dots disappear it is time to respond. You can put your fingers on the 1 and 2 buttons. \n \n \n',...
            'If you think the dots moved to the left, press "1". If you think the dots moved to the right, press "2". \n \n \n',...
            'We will now show you the moving dots again. Look carefully, and decide whether they are \n \n \n',...
            'moving to the right or to the left. After the dots disappear, press 1 for left or 2 for right. \n \n \n',...
            'Make sure to not respond before the dots disappear \n \n \n. Press any key when you are ready to try out this example.'],...
            'center', 'center', [255 255 255]);
        Screen('Flip', curWindow,0);
        WaitSecs(2);
        KbWait(-1)
        
        % do an example exercise with 30% rightward motion
        showLocalizerDots_random(1, 0.3, 300, R_motion, params, screenInfo);
        [end_time, b_response, b_response_time] = collectButtonResponse(params, inf);
        
        % give chance to ask questions.
        DrawFormattedText(curWindow, ['The correct answer was 2, the dots were moving to the right. When you start the task, you will \n \n \n',...
            'hear a high tone if you choose the correct response and a low tone if you choose the wrong response. \n \n \n',...
            'If you have any questions before beginning the experiment, please ask the experimenter now. \n \n \n',...
            'If you are ready to start the experiment, press any key to begin.'],...
            'center', 'center', [255 255 255]);
        Screen('Flip', curWindow,0);
        WaitSecs(2);
        KbWait(-1)
        
    elseif task == 2
        
        DrawFormattedText(curWindow, ['We will now explain the second task of this expeirment. \n \n \n', ...
            'The second task consists of 400 trials devided over 5 blocks. There is an important change compared to the first task: \n \n \n', ...
            'You will no longer hear a tone and you are not required to press 1 or 2 anymore. \n \n \n',...
            'Instead of hearing a tone, you will be asked to rate confidence in the direction judgment. \n \n \n',...
            'On each trial, you will be asked: How sure are you that the dots moved to the left or right? \n \n \n',...
            'You can rate your confidence by left-clicking with the mouse on the confidence scale. \n \n \n',...
            'You can rate higher confidence by choosing positions further away from the centre of the confidence scale. \n \n \n',...
            'Press any key to see the confidence scale, and click on it to continue the instructions.'],...
            'center', 'center', [255 255 255]);
        Screen('Flip', curWindow,0);
        WaitSecs(2);
        KbWait(-1)
        
        [end_time, m_response_dir, m_response_time] = showConfidenceScale(params, screenInfo);
        
        DrawFormattedText(curWindow, ['There are percentages for each confidence level. \n \n \n',...
            'These percentages are: 100% left, 80% left, 60% left, \n \n \n',...
            '60% right, 80% right, 100% right. They correspond to your left or righward judgment, \n \n \n' ...
            'in addition to how certain you might be about your leftward or rightward choice. \n \n \n',...
            'You can click anywhere on the confidence scale. \n \n \n',...
            'Press any key to see the confidence scale and practice clicking on it.'],...
            'center', 'center', [255 255 255]);
        Screen('Flip', curWindow,0);
        WaitSecs(2);
        KbWait(-1);
        
        [end_time, m_response_dir, m_response_time] = showConfidenceScale(params, screenInfo);
        
        
       DrawFormattedText(curWindow, ['Another important change compared to the second tasks is that during this task you can earn extra money! \n \n \n', ...
            'You can win points by matching your confidence to your performance. \n \n \n',...
            'Specifically, the number of points you earn is based on a rule that \n \n \n',...
            'calculates how closely your confidence tracks your performance: \n \n \n',...
            'points = 100 * (1- (accuracy - confidence)^2) \n \n \n',...
            'This formula may appear complicated, but what it means for you is very simple: \n \n \n',...
            'You will get paid the most if you honestly report your best guess about the direction of the dots \n \n \n',...
            'for each decision. \n \n \n',...
            'We will now ask you some questions about how you earn money in this experiment. \n \n \n',...
            'Press any key when you are ready to answer these questions.'],...
            'center', 'center', [255 255 255]);
        Screen('Flip', curWindow,0);
        WaitSecs(2);
        KbWait(-1);
        
        [end_time, m_response_dir, m_response_time] = testConfidenceScale(1, params, screenInfo);
        % save m_response to check whether they understand the QSR
        locDATA.qsr_test(1) = m_response_dir;
        
        Screen('Flip', curWindow,0);
        WaitSecs(0.5);
        
        [end_time, m_response_dir, m_response_time] = testConfidenceScale(2, params, screenInfo);
        % save m_response to check whether they understand the QSR
        locDATA.qsr_test(2) = m_response_dir;
        
        Screen('Flip', curWindow,0);
        WaitSecs(0.5);
        
        
        % explaining test answers
        DrawFormattedText(curWindow, ['The correct answers were:  \n \n \n',...
            'If you are sure that the dots moved to the right, you should select the most extreme right position on the scale. \n \n \n',...
            'If you are sure that the dots moved to the left, you should select the most extreme left position on the scale. \n \n \n',...
            'If you are not sure about being correct or incorrect you should select a location in between. \n \n \n'],...
            'center', 'center', [255 255 255]);
        Screen('Flip', curWindow,0);
        WaitSecs(3);
        KbWait(-1)
        
        
        %% add some practise trials
        DrawFormattedText(curWindow, ['In this second task, you will see the same dot stimuli as in the first task. \n\n\n',...
            'Remember that in this second task you do not have to press 1 or 2. \n \n \n', ...
            'Instead, you have to indicate your answer by selecting a location on the confidence scale. \n \n \n',...
            'You will now do ten practise trials to familiarize yourself with using the confidence scale.'],...
             'center', 'center', [255 255 255]);
            Screen('Flip', curWindow, 0); 
        WaitSecs(1); 
        KbWait(-1); 
        
         apRect = floor(createTRect(params.apXYD, screenInfo));
        % making precoherence*direction*postcoherence conditions
        DotsConditions(1,:) = repmat(params.Mguess, 1, 4);
        DotsConditions(2,:) = [1 2 1 2 1 2 1 2 1 2 1 2];
        DotsConditions(3,:) = params.Mguess([3 3 1 1 1 1 2 2 3 3 2 2]); 
        % shuffle them for pseudorandom pattern
        randConds = DotsConditions(:, randperm(length(DotsConditions)));
        
        for n = 1:10
            DotsMotion = randConds(2,n).*180;
            DotsMotion_radians = (DotsMotion/360).*(2.*pi);
            
            Screen('DrawDots', curWindow, [0; 0], (0.2*screenInfo.ppd), [255 255 255], screenInfo.center, 1);
            Screen('FrameOval', curWindow, [255 255 255], apRect);
            Screen('Flip', curWindow,0);
            WaitSecs(0.5);
            showLocalizerDots_random(1, randConds(1,n), params.dur(1), DotsMotion_radians, params, screenInfo);
            [end_time, m_response_dir, m_response_time] = showConfidenceScale(params, screenInfo);
        end
        
       DrawFormattedText(curWindow, ['Well done! \n\n\n', ....
           'In the second part of the task you have to do this once again. \n \n \n ',...
           'If you have any questions, please call the experimenter now. \n \n \n', ...
           'Otherwise, please press any key to start the second task. \n \n \n'], ...
            'center', 'center', [255 255 255]);
            Screen('Flip', curWindow, 0); 
        WaitSecs(1); 
        KbWait(-1); 

        
    elseif task == 3
        DrawFormattedText(curWindow, ['We will now explain the third task in this experiment. \n \n \n',...
            'The third task consists of 800 trials divided over 9 blocks. \n \n \n', ... 
            'The main difference with the previous task is that you will get to see bonus evidence after each decision! \n \n',...
            'This can help you know whether you were right or wrong. \n \n \n',...
            'You can use bonus evidence to help you make your second judgment. \n \n \n',...
            'Press any key to continue the instructions.'],...
            'center', 'center', [255 255 255]);
        Screen('Flip', curWindow, 0); 
        WaitSecs(params.wait(4)); 
        KbWait(-1); 
        
        DrawFormattedText(curWindow, ['We recorded the responses of two other participants on the previous task.  \n \n \n',...
            'You can use that information as advice to adjust your initial response \n \n \n',...
            'The decision of these two previous participants are shown on the same confidence scale \n \n \n',...
            'For anonymity purposes, we use the same silouette for every participant. \n \n \n',...
            'Every adviser has a different background colour. \n \n\n',...
            'Press any key when you are ready to see what advice looks like.'],...
            'center', 'center', [255 255 255]);
        Screen('Flip', curWindow,0);
        WaitSecs(params.wait(4));
        KbWait(-1);
        
        showConfidenceScale_adv(params, screenInfo, 0.2,1,3);
        Screen('Flip', curWindow,0);
        WaitSecs(3);
        
        DrawFormattedText(curWindow, ['In the first task of this experiment we sought to find the right difficulty level for you. \n \n \n', ...
            'We did the same for every participant, also for the participants that will now be your advisers. \n \n \n',...
            'This means that all advisers are as accurate as you are in determining the direction of the dots. \n \n \n'...
            'Also the amount of evidence that you and the deciders see on every trial is the same. \n \n \n',...
            'But because everyone perceives the world differently, your advisers can have varying confidence levels. \n \n \n' ...
            'Press any key to see an example of a relatively confident adviser.'],...
            'center', 'center', [255 255 255]);
            Screen('Flip', curWindow,0);
        WaitSecs(2);
        KbWait(-1);
        
        showConfidenceScale_adv(params, screenInfo, 0.45,2,3);
        Screen('Flip', curWindow,0);
        WaitSecs(3);
        
        
        DrawFormattedText(curWindow, ['During the experiment you will have less time to look at the advice. \n \n \n',...
            'Press any key to see what actual advice will look like.'],...
            'center', 'center', [255 255 255]);
        Screen('Flip', curWindow,0);
        WaitSecs(2);
        KbWait(-1);
        
        showConfidenceScale_adv(params, screenInfo, 0.45, 2,3);
        Screen('Flip', curWindow,0);
        WaitSecs(params.wait(4));
        
        DrawFormattedText(curWindow, ['The previous advisers were both quite confident that the dots moved to the right. \n \n \n',...
            'Can you imagine what an adviser that is confident that dots moved to the left looks like? \n \n \n', ...
            'Press any key to see the answer.'],...
            'center', 'center', [255 255 255]);
        Screen('Flip', curWindow,0);
        WaitSecs(2);
        KbWait(-1);
        
        showConfidenceScale_adv(params, screenInfo, 0.45,1,3);
        Screen('Flip', curWindow,0);
        WaitSecs(params.wait(4));
        
        
        
        %% Practise advice
         DrawFormattedText(curWindow, ['Based on what your advisers decided on the same trial, you can revise your initial judgment. \n \n \n',...
            'You do this by using the confidence scale that you used in task 2. \n \n \n',...
            'So one trial in task three looks like this: \n \n \n', ...
            ' 1) You and your advisers see the same stimulus strength. \n \n \n',...
            ' 2) You make a decision between left or right by pressing 1 or 2. \n \n \n',...
            ' 3) You will see the confidence level of one of your advisers. \n \n \n',... 
            ' 4) Based on all evidence that has been presented to you on that trial, you will rate your confidence level.'],...
             'center', 'center', [255 255 255]);
        Screen('Flip', curWindow,0);
        WaitSecs(1);
        KbWait(-1);
        
         DrawFormattedText(curWindow, ['So remember that in this experiment, you need to first make a binary decision by pressing either 1 or 2. \n \n \n',...
             'Then you are presented with the advice and rate your confidence using the scale.'],...
            'center', 'center', [255 255 255]);
        Screen('Flip', curWindow,0);
        WaitSecs(1);
        KbWait(-1);
       
        DrawFormattedText(curWindow, ['To help you to get used to the changes \n \n \n',...
            'you will now do 6 practice trials. \n \n \n',...
            'Press any key to begin the practise trials when you are ready.'],...
            'center', 'center', [255 255 255]);
        Screen('Flip', curWindow,0);
        WaitSecs(1);
        KbWait(-1); 

        
        apRect = floor(createTRect(params.apXYD, screenInfo));
        % making precoherence*direction*postcoherence conditions
        DotsConditions(1,:) = repmat(params.Mguess, 1, 4);
        DotsConditions(2,:) = [1 2 1 2 1 2 1 2 1 2 1 2];
        DotsConditions(3,:) = [0.2 0.33 0.1 0.01 0.45 0.33 0.25 0.1 0.08 0.4 0.2 0.1];
        DotsConditions(4,:) = [2 1 1 1 2 1 1 2 1 1 2 2]; 
        DotsConditions(5,:) = [3 3 3 3 3 3 3 3 3 3 3 3];
        % shuffle them for pseudorandom pattern
        randConds = DotsConditions(:, randperm(length(DotsConditions)));
        
        for n = 1:6
            DotsMotion = randConds(2,n).*180;
            DotsMotion_radians = (DotsMotion/360).*(2.*pi);
            
            Screen('DrawDots', curWindow, [0; 0], (0.2*screenInfo.ppd), [255 255 255], screenInfo.center, 1);
            Screen('FrameOval', curWindow, [255 255 255], apRect);
            Screen('Flip', curWindow,0);
            WaitSecs(0.5);
            showLocalizerDots_random(1, randConds(1,n), params.dur(1), DotsMotion_radians, params, screenInfo);
            [end_time, b_response, b_response_time] = collectButtonResponse(params, inf);
            WaitSecs(params.wait(1));
            showConfidenceScale_adv(params, screenInfo, randConds(3,n), randConds(4,n), randConds(5,n));
            Screen('Flip',curWindow);
            WaitSecs(params.wait(4));
            [end_time, m_response_dir, m_response_time] = showConfidenceScale(params, screenInfo);
        end

       DrawFormattedText(curWindow, ['Press any key when you you are ready for the last ten practise trials. \n \n \n'], ...
            'center', 'center', [255 255 255]);
            Screen('Flip', curWindow, 0); 
        WaitSecs(1); 
        KbWait(-1); 
        
        
        apRect = floor(createTRect(params.apXYD, screenInfo));
        % making precoherence*direction*postcoherence conditions
        DotsConditions(1,:) = repmat(params.Mguess, 1, 4);
        DotsConditions(2,:) = [1 2 1 2 1 2 1 2 1 2 1 2];
        DotsConditions(3,:) = [0.2 0.33 0.1 0.01 0.45 0.33 0.25 0.1 0.08 0.4 0.2 0.1];
        DotsConditions(4,:) = [2 1 1 1 2 1 1 2 1 2 1 2]; 
        DotsConditions(5,:) = [3 3 3 3 3 3 3 3 3 3 3 3]; 
        % shuffle them for pseudorandom pattern
        randConds = DotsConditions(:, randperm(length(DotsConditions)));
        
        for n = 1:10
            DotsMotion = randConds(2,n).*180;
            DotsMotion_radians = (DotsMotion/360).*(2.*pi);
            
            Screen('DrawDots', curWindow, [0; 0], (0.2*screenInfo.ppd), [255 255 255], screenInfo.center, 1);
            Screen('FrameOval', curWindow, [255 255 255], apRect);
            Screen('Flip', curWindow,0);
            WaitSecs(0.5);
            showLocalizerDots_random(1, randConds(1,n), params.dur(1), DotsMotion_radians, params, screenInfo);
            [end_time, b_response, b_response_time] = collectButtonResponse(params, inf);
            WaitSecs(params.wait(1));
            showConfidenceScale_adv(params, screenInfo, randConds(3,n), randConds(4,n), randConds(5,n));
            Screen('Flip',curWindow);
            WaitSecs(params.wait(4));
            
            [end_time, m_response_dir, m_response_time] = showConfidenceScale(params, screenInfo);
        end
        
        
        % give chance to ask questions
       DrawFormattedText(curWindow, ['This was the last practise trial. \n \n \n',...
           'If you have any questions before beginning this part of the experiment, please ask the experimenter now. \n \n \n',...
            'If you are ready to start the experiment, press any key to begin.'],...
            'center', 'center', [255 255 255]);
        Screen('Flip', curWindow,0);
        WaitSecs(1);
        KbWait(-1);

    end
end

