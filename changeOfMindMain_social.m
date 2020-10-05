 clear all

cwd = pwd;

screenSize = input('screen? 1=full, 2=test, 3=alt ');
task = input('task? 1=calibration, 2=confidence, 3 = post-decision evidence task ');

addpath('psychFit-master/')
% add path to psychtoolbox on the testing mac
addpath(genpath('/Local/Users/Shared/Psychtoolbox'))

params = getLocParams;
rand_no = rem(params.subNo,2)+1;

%% open window, record refresh rate
screenInfo.rseed = [];
rseed = sum(100*clock);
rand('state',rseed);

% set monitor parameters for testing computer and fmri projector
monWidth = 42;
viewDist = 45;
    
screenNum = 0;
if screenSize == 1
    screenDim = [];
elseif screenSize == 2
    screenDim = [0 0 1200 1200];    % set to [] for full screen
else
    screenDim = [];
    screens=Screen('Screens');
    screenNum=max(screens);
end

Screen('Preference','SkipSyncTests', 1); % change to 0 for experiment/1 for debugging
screenInfo.bckgnd = 0;
[screenInfo.curWindow, screenInfo.screenRect] = Screen('OpenWindow', screenNum, [100 100 100], screenDim);

spf =Screen('GetFlipInterval', screenInfo.curWindow);      % seconds per frame
screenInfo.monRefresh = 1/spf;    % frames per second
screenInfo.frameDur = 1000/screenInfo.monRefresh;
screenInfo.center = [screenInfo.screenRect(3) screenInfo.screenRect(4)]/2;   	% coordinates of screen center (pixels)
curWindow = screenInfo.curWindow;
rad= atan((monWidth/2) / viewDist) * 2;
monWidthDeg= (rad/(2*pi)) * 360;
screenInfo.ppd = screenInfo.screenRect(3) / monWidthDeg;    % pixels per degree
ppd = screenInfo.ppd;
apRect = floor(createTRect(params.apXYD, screenInfo));
locDATA = [];
Accuracy = zeros(1,800);

% Ensure portability
Screen('TextFont',screenInfo.curWindow,'Helvetica');
Screen('TextSize', screenInfo.curWindow, params.textSize);
KbName('UnifyKeyNames');

% define saving location
datafile = ['fMRI_pilotData_sub_' num2str(params.subNo) '_' num2str(task) '.mat'];

% Provide experiment instructions
HideCursor
locDATA = showInstruction_adv(task, screenInfo, params, locDATA);

% Start experiment
DrawFormattedText(curWindow, ['Please attend to the white dot in the center of the screen \n \n \n',...
    'The stimuli will appear shortly...'],...
    'center', 'center', [255 255 255]);
Screen('DrawDots', curWindow, [0; 0], (0.2*ppd), [255 255 255], screenInfo.center, 1);
Screen('Flip',curWindow);
WaitSecs(1);

timing.startTime = GetSecs;

%% Create conditions parameters
if task == 1
        Nblocks = params.Nblocks(task);
        % making coherence*direction conditions
        DotsConditions(1,:) = repmat(params.conditionsC, 1, (Nblocks./6));
        DotsConditions(2,:) = repmat([ones(1,6),2*ones(1,6)], 1, (Nblocks./12));       
        % shuffle them for pseudorandom pattern
        randConds = DotsConditions(:,randperm(length(DotsConditions)));
        % determine breaks
        b = linspace(0,Nblocks,params.Nbreaks(task));
        breaks = b(2:end-1);

elseif task == 2
    Nblocks = params.Nblocks(task);
    % load calibration task data and amount of trials
        calibration = ['fMRI_pilotData_sub_' num2str(params.subNo) '_1.mat'];
        cd locfMRIpilot
        load(calibration, 'locDATA');
        cd(cwd);
        % merge coh level and direction into 1 variable
        for i = 1:params.Nblocks(1)
            if locDATA.dots_direction(i) == 180
                percCoherence(i) = locDATA.dots_coherence(i)*-1;
            else
                percCoherence(i) = locDATA.dots_coherence(i);
            end
        end
        % specify conditions for analysis and x axis
        intervals = [-1, -0.48, -0.24, -0.12, -0.08, -0.03, 0.03, 0.08, 0.12, 0.24, 0.48, 1];
        % specify number of responses per condition/bin
        N = repmat(sum(percCoherence==1),1,length(intervals));
        % count occurances of decision=R per coh*direction intervalsca       
        for j = 1:12
            Pright(j) = sum(locDATA.button_response == 2 & percCoherence == intervals(j));
        end
        % do psychometric fitting
        pArray = [0 0.5];
        fitparams = psychFit(intervals, Pright, N, pArray, 'normal');
        % extract coherence values for task 2
        base = linspace(min(intervals), max(intervals), 200);
        pred = cumNormPred(base, fitparams(1), fitparams(2));
        upper_k = dsearchn(pred', params.threshold');
        lower_k = dsearchn(pred', (1-params.threshold)');
        coherence = mean([base(upper_k); -base(lower_k)]); 
        
         % making precoherence*direction*postcoherence conditions
        DotsConditions(1,:) = repmat([coherence(1) coherence(3)], 1, (Nblocks./2));   % Nblocks refers to n trials :)
        DotsConditions(2,:) = repmat([1 1 2 2], 1, (Nblocks./4)); %correct dir (1 = left, 2 = right)
        DotsConditions(10,:) = repmat([1 2], 1, (Nblocks./2)); %new var indicating low or high pre
        
        % shuffle them for pseudorandom pattern
        perm = randperm(length(DotsConditions(1,:))); 
        randConds = DotsConditions(:, perm); 
       
        % determine breaks
        b = linspace(0,Nblocks,params.Nbreaks(task)); %%switched to params.Nbreaks(1) = 10
        breaks = b(2:end-1);   
elseif task == 3
     % load confidence task data and amount of trials
        confidence_task = ['fMRI_pilotData_sub_' num2str(params.subNo) '_2.mat'];
        cd locfMRIpilot
        load(confidence_task, 'locDATA');
        cd(cwd);
        %trial info 
        coherence = locDATA.psychfitting; 
        randConds_pre = locDATA.randConds;
        Nblocks = params.Nblocks(task);

        % making precoherence*direction*postcoherence conditions
        DotsConditions(1,:) = [repmat(coherence(1),1,(Nblocks./4)), repmat(coherence(3), 1, (Nblocks./4)),repmat(coherence(1),1,(Nblocks./4)), repmat(coherence(3), 1, (Nblocks./4))];   % 200 low, 200 high, 200 low etc 4 x; Nblocks refers to n trials :)
        DotsConditions(2,:) = repmat([1 2], 1, (Nblocks./2)); %correct dir (1 = left, 2 = right) 1,2 repeated 400 times
        DotsConditions(3,:) = [repmat(params.order{rand_no}(1),1, (Nblocks./2)), repmat(params.order{rand_no}(2),1, (Nblocks./2))];%order advisers = [1 2] for even, order = [2 1] for uneven each 400 times
        
        %get dist 
        conf_high = locDATA.pre_conf_adv(randConds_pre(10,:) == 2); 
        conf_low = locDATA.pre_conf_adv(randConds_pre(10,:) == 1); 
        conf_temp = [conf_high, conf_low]; 
        acc_high = locDATA.pre_acc_adv(randConds_pre(10,:) == 2); 
        acc_low = locDATA.pre_acc_adv(randConds_pre(10,:) == 1); 
        acc_temp = [acc_high, acc_low]; 
   
        DotsConditions(4,:) = [conf_low'; conf_high'; conf_temp(randperm(length(conf_temp)))'];
        DotsConditions(5,:) = [acc_low'; acc_high'; acc_low'; acc_high']; 
        DotsConditions(6,:) = [repmat(1,1,(Nblocks./4)), repmat(1,1,(Nblocks./4)), repmat(2,1,(Nblocks./4)),repmat(2,1,(Nblocks./4))];  
        
        % shuffle them for pseudorandom pattern
        perm = randperm(length(DotsConditions(1,:))); 
        randConds = DotsConditions(:, perm); 
       
        % determine breaks
        b = linspace(0,Nblocks,params.Nbreaks(task)); 
        breaks = b(2:end-1);      
end

%% Clean up data that has already been loaded
clear locDATA

%% Present blocks
for n = 1:Nblocks
    timing.blockStart(n) = GetSecs;     % start of each trial not blocks :)
    % direction of movement, left (180) or right (360)
    DotsMotion = randConds(2,n) * 180;
    DotsMotion_radians = (DotsMotion/360) * (2*pi);
    % pre-decision moving dots with varying coherence
    showLocalizerDots_random(1, randConds(1,n), params.dur(1), DotsMotion_radians, params, screenInfo);
    timing.endPreDots(n) = GetSecs;
    if task == 1 || task == 3
    % collecting button response
    [end_time, b_response, b_response_time] = collectButtonResponse(params, inf);
    
    % check accuracy of response
    if DotsMotion == 180 && b_response == 1 || DotsMotion == 360 && b_response == 2
        Accuracy(n) = 1;
    end
    end
    
    if task == 1
        % pass accuracy into auditory feedback code
        AuditiveFeedback(Accuracy(n));
    end
    
     % collecting confidence response
     if task == 2 
            [end_time, pre_response_dir, pre_response_time] = showConfidenceScale(params, screenInfo);
            pre_conf_adv = abs(pre_response_dir - 0.5); 
            if pre_response_dir < 0.5
                a_pre = 1;
            else a_pre = 2;
            end
            pre_acc_adv = a_pre == randConds(2,n);

          %reset m_response from m_response_dir (0 = left, 1 = right) to m_response: 0 = wrong, 1 = right
         if a_pre == 2 && pre_response_dir > 0.5
             pre_response = pre_response_dir;
         elseif a_pre == 1 && pre_response_dir < 0.5
             pre_response = 1 - pre_response_dir;
         elseif a_pre == 2 && pre_response_dir < 0.5
             pre_response = pre_response_dir;
         elseif a_pre == 1 &&pre_response_dir > 0.5
             pre_response = 1 - pre_response_dir; 
         end
           
         % compute confidence performance match with QSR
         confPoints_pre(n) = (1-((pre_acc_adv - pre_response + 0.5)^2))*100;
         if isnan(pre_conf_adv)
             confPoints_pre(n) = 0;
         end
     end
     
     if task == 3 && isnan(b_response) == 0
         WaitSecs(params.wait(1));
         adv_nr = randConds(3,n);
         conf_adv = randConds(4,n);
         acc_adv = randConds(5,n);
         if acc_adv == 1
             a_adv = randConds(2,n);
         else
             if randConds(2,n) == 1
                 a_adv = 2;
             else
                 a_adv = 1;
             end
         end
         
         showConfidenceScale_adv(params, screenInfo, conf_adv, a_adv, adv_nr); 
         Screen('Flip',curWindow);
         WaitSecs(params.wait(4));
            
        % collecting confidence response
         [end_time, m_response_dir, m_response_time] = showConfidenceScale(params, screenInfo);
         %reset m_response from m_response_dir (0 = left, 1 = right) to m_response: 0 = wrong, 1 = right
         if b_response == 2 && m_response_dir > 0.5
             m_response = m_response_dir;
         elseif b_response == 1 && m_response_dir < 0.5
             m_response = 1 - m_response_dir;
         elseif b_response == 2 && m_response_dir < 0.5
             m_response = m_response_dir;
         elseif b_response == 1 && m_response_dir > 0.5
             m_response = 1 - m_response_dir;
         end
         
         % compute confidence performance match with QSR
         confPoints(n) = (1-((Accuracy(n) - m_response)^2))*100;
         if isnan(m_response)
             confPoints(n) = 0;
%          else
%              % keep trial lengths the same
%              WaitSecs(params.confDeadline + params.wait(3) - m_response_time)
         end
     end
     
     %% Storing and saving data
     % storing coherence, direction, responses and RT's for every trial
     if task == 1
         locDATA.dots_coherence(n) = randConds(1,n);
         locDATA.dots_direction(n) = DotsMotion;
         locDATA.button_response(n) = b_response;
         locDATA.reaction_time_button(n) = b_response_time;
         locDATA.accuracy(n) = Accuracy(n);
         locDATA.timing = timing;
     elseif task == 2
         locDATA.pre_conf_adv(n) = pre_conf_adv;
         locDATA.pre_acc_adv(n) = pre_acc_adv;
         locDATA.pre_response_dir(n) = pre_response_dir;
         locDATA.randConds = randConds;
         locDATA.psychfitting = coherence;
          locDATA.QSR_score(n) = confPoints_pre(n);
     elseif task == 3
         locDATA.button_response(n) = b_response;
         locDATA.reaction_time_button(n) = b_response_time;
         locDATA.accuracy(n) = Accuracy(n);
         locDATA.timing = timing;
         locDATA.mouse_response_dir(n) = m_response_dir;
         locDATA.mouse_response(n) = m_response;
         locDATA.reaction_time_mouse(n) = m_response_time;
         locDATA.QSR_score(n) = confPoints(n);
         locDATA.psychfitting = coherence;
         locDATA.conf_adv(n) = conf_adv;
         locDATA.acc_adv(n) = acc_adv;
         locDATA.a_adv(n) = a_adv;
         locDATA.task(n) = 1;
         locDATA.adv_type(n) = randConds(6,n);  
         locDATA.randConds = randConds; 
     end
     
     Screen('DrawDots', curWindow, [0; 0], (0.2*ppd), [255 255 255], screenInfo.center, 1);
     Screen('FrameOval', screenInfo.curWindow, [255 255 255], apRect);
     Screen('Flip', curWindow,0);
     WaitSecs(params.ITI(1));
     %toc
     % saving data
     cd locfMRIpilot
     save(datafile,'locDATA','params');
     cd(cwd);
     
    %% Present breaks and feedback
    if sum(n==breaks) == 1
        % show confidence points/points for extra money in task 2 !
        if task == 3
            fin = find(n==breaks);
            DrawFormattedText(screenInfo.curWindow, ['You can take a break from the task now. \n \n \n',...
                'Your results are shown below. \n \n \n',...
                'Press any key when you are ready to answer some questions.'], 'center', screenInfo.center(2), [255 255 255]);
            disp(screenInfo.center(2)-200);
            Screen('DrawText', screenInfo.curWindow, ['You just finished block ' num2str(fin) ' out of  ' num2str(params.Nbreaks(task)-1)], screenInfo.center(1), screenInfo.center(2)-200, [255 255 255]);
            c = breaks(2)-breaks(1)-1;
            blockPoints = round(sum(confPoints(end-c:end))).*params.IncrPoints(task);
            totalPoints = round(sum(confPoints)).*params.IncrPoints(task);
            totalMoney = sprintf('%.2f', (totalPoints/5000)*0.7);
            message1 = ['Number of points for this block:    ' num2str(blockPoints)];
            message2 = ['Number of total points for the experiment:    ' num2str(totalPoints)];
            message3 = ['Current total of extra money earned:    £ ' num2str(totalMoney)];
            Screen('DrawText', screenInfo.curWindow, message1, screenInfo.center(1), screenInfo.center(2)+200, [255 255 255]);
            Screen('DrawText', screenInfo.curWindow, message2, screenInfo.center(1), screenInfo.center(2)+250, [255 255 255]);
            Screen('DrawText', screenInfo.curWindow, message3,screenInfo.center(1), screenInfo.center(2)+300, [255 255 255]);
            Screen('Flip', curWindow,0);
            WaitSecs(1);
            KbWait(-1);
            

            DrawFormattedText(screenInfo.curWindow, ['You have previously played with two advisers. \n \n \n',...
                'Please indicate to what extent you agree with the following statements, use a scale from 0% (not at all) to 50% (extremely) \n \n \n',...
                'Press any key to continue.'], 'center', screenInfo.center(2), [255 255 255]);
            Screen('Flip', curWindow,0);
            WaitSecs(1);
            KbWait(-1);
            
            qs = {'accurate', 'confident', 'trustworthy', 'influential on my choices'}; 
            for q = 1:4
                message = qs{q};
                locDATA.adv1(q,fin) = showquestion_adv(params, screenInfo, 1, message);
                locDATA.adv2(q,fin) = showquestion_adv(params, screenInfo,2, message);
            end
            Screen('Flip', curWindow,0);
            WaitSecs(1);
            KbWait(-1);
            
             DrawFormattedText(screenInfo.curWindow, ['Thank you for answering these questions. \n \n \n',...
                'Press any key to start the next block.'], 'center', screenInfo.center(2), [255 255 255]);
             Screen('Flip', curWindow,0); 
            WaitSecs(1);
            KbWait(-1); 
            
        elseif task == 2
            fin = find(n==breaks);
            DrawFormattedText(screenInfo.curWindow, ['You can take a break from the task now. \n \n \n',...
                'Your results are shown below. \n \n \n',...
                'Press any key when you are ready to start the new block.'], 'center', screenInfo.center(2), [255 255 255]);
            disp(screenInfo.center(2)-200);
            Screen('DrawText', screenInfo.curWindow, ['You just finished block ' num2str(fin) ' out of  ' num2str(params.Nbreaks(task)-1)], screenInfo.center(1), screenInfo.center(2)-200, [255 255 255]);
            c = breaks(2)-breaks(1)-1;
            blockPoints = round(sum(confPoints_pre(end-c:end))).*params.IncrPoints(task);
            totalPoints = round(sum(confPoints_pre)).*params.IncrPoints(task);
            totalMoney = sprintf('%.2f', (totalPoints/5000)*0.7);
            message1 = ['Number of points for this block:    ' num2str(blockPoints)];
            message2 = ['Number of total points for the experiment:    ' num2str(totalPoints)];
            message3 = ['Current total of extra money earned:    £ ' num2str(totalMoney)];
            Screen('DrawText', screenInfo.curWindow, message1, screenInfo.center(1), screenInfo.center(2)+200, [255 255 255]);
            Screen('DrawText', screenInfo.curWindow, message2, screenInfo.center(1), screenInfo.center(2)+250, [255 255 255]);
            Screen('DrawText', screenInfo.curWindow, message3,screenInfo.center(1), screenInfo.center(2)+300, [255 255 255]);
            Screen('Flip', curWindow,0);
            WaitSecs(1);
            KbWait(-1);
        
        elseif task == 1 
            fin = find(n==breaks);
            Screen('DrawText', screenInfo.curWindow, ['You just finished block ' num2str(fin) ' out of  ' num2str(params.Nbreaks(task)-1)], screenInfo.center(1), 200, [255 255 255]);
            DrawFormattedText(screenInfo.curWindow, ['You can take a break from the task now. \n \n \n',...
                'Press any key when you are ready for the next block of trials.'], 'center', 500, [255 255 255]); %Also here, 500 can be adjusted (higher numbers appear lower on the screen)
            Screen('Flip',screenInfo.curWindow);
            WaitSecs(1);
            KbWait(-1)
        end
    end
end

%% Wrap up experiment
DrawFormattedText(screenInfo.curWindow, 'End of the task! \n \n \n \n',...
    'center', 'center', [255 255 255]);

if task == 3
    c = breaks(2)-breaks(1)-1;
    blockPoints = round(sum(confPoints(end-c:end))).*params.IncrPoints(task);
    totalPoints = round(sum(confPoints)).*params.IncrPoints(task);
    totalMoney = sprintf('%.2f', (totalPoints/5000)*0.7);
    message1 = ['Number of points for this block:    ' num2str(blockPoints)];
    message2 = ['Number of total points for the experiment:    ' num2str(totalPoints)];
    message3 = ['Current total of extra money earned:    £ ' num2str(totalMoney)]; 
    Screen('DrawText', screenInfo.curWindow, message1, screenInfo.center(1), screenInfo.center(2)+200, [255 255 255]);%SIZE (+200, +250 and + 300) can be adjusted if the money earned falls outside the screen
    Screen('DrawText', screenInfo.curWindow, message2, screenInfo.center(1), screenInfo.center(2)+250, [255 255 255]);
    Screen('DrawText', screenInfo.curWindow, message3,screenInfo.center(1), screenInfo.center(2)+300, [255 255 255]);
elseif task == 2
   c = breaks(2)-breaks(1)-1;
    blockPoints = round(sum(confPoints_pre(end-c:end))).*params.IncrPoints(task);
    totalPoints = round(sum(confPoints_pre)).*params.IncrPoints(task);
    totalMoney = sprintf('%.2f', (totalPoints/5000)*0.7);
    message1 = ['Number of points for this block:    ' num2str(blockPoints)];
    message2 = ['Number of total points for the experiment:    ' num2str(totalPoints)];
    message3 = ['Current total of extra money earned:    £ ' num2str(totalMoney)]; 
    Screen('DrawText', screenInfo.curWindow, message1, screenInfo.center(1), screenInfo.center(2)+200, [255 255 255]);%SIZE (+200, +250 and + 300) can be adjusted if the money earned falls outside the screen
    Screen('DrawText', screenInfo.curWindow, message2, screenInfo.center(1), screenInfo.center(2)+250, [255 255 255]);
    Screen('DrawText', screenInfo.curWindow, message3,screenInfo.center(1), screenInfo.center(2)+300, [255 255 255]);
end
Screen('Flip',screenInfo.curWindow);

pause(0.5);
while 1
[s key] = KbWait(-1);
    if strcmp(KbName(key),'Return') % press enter to end the task!
        break 
    end
end

Screen('CloseAll');

