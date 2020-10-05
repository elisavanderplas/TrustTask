% localizerWrap2
%
% localizer Wrapper for the scan (and out-of scanner) modified experiment.

clear all

cwd = pwd;

screenSize = input('screen? 1=full, 2=test, 3=alt ');
task = input('task? 1=calibration, 2=full ');
part = input('1= 1st part (behav), 2= 2nd(fMRI)');

if part == 1
    addpath('psychFit-master/')
    % add path to psychtoolbox on the testing mac
    addpath(genpath('/Local/Users/Shared/Psychtoolbox'))
end

params = getLocParams;

%% open window, record refresh rate

screenInfo.rseed = [];
rseed = sum(100*clock);
rand('state',rseed);

% set monitor parameters for testing computer and fmri projector
if part == 1
    monWidth = 42;
    viewDist = 45;
elseif part == 2
    monWidth = 32;
    viewDist = 58;
end

screenNum = 0;
if screenSize == 1
    screenDim = [];
elseif screenSize == 2
    screenDim = [0 0 900 900];    % set to [] for full screen
else
    screenDim = [];
    screens=Screen('Screens');
    screenNum=max(screens);
end

Screen('Preference','SkipSyncTests', 0); % change to 0 for experiment/1 for debugging
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
Accuracy = zeros(1,900);

% Ensure portability
% Screen('TextFont',screenInfo.curWindow,'Helvetica');
Screen('TextSize', screenInfo.curWindow, params.textSize);
KbName('UnifyKeyNames');

% define saving location
datafile = ['fMRI_pilotData_sub_' num2str(params.subNo) '_' num2str(task) '.mat'];

% Provide experiment instructions
HideCursor
locDATA = showInstruction(part, task, screenInfo, params, locDATA);

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
    if part == 1
        Nblocks = params.Nblocks(2);
        % making coherence*direction conditions
        DotsConditions(1,:) = repmat(params.conditionsC, 1, (Nblocks./6));
        DotsConditions(2,:) = repmat([ones(1,6),2*ones(1,6)], 1, (Nblocks./12));       
    elseif part == 2
        Nblocks = params.Nblocks(4);
        % making coherence*direction conditions
        DotsConditions(1,:) = repmat([1,2,3],1,(Nblocks./3));
        DotsConditions(2,:) = repmat([ones(1,3),2*ones(1,3)], 1, (Nblocks./6));
        % retrieve coherence data from day 1
        priors = ['fMRI_pilotData_sub_' num2str(params.subNo) '_2.mat'];
        cd locfMRIpilot
        load(priors, 'locDATA');
        cd(cwd);
        % define priors
        Mguess = locDATA.psychfitting;
        % create three QUEST structs for threshold calibration
        beta=3.5;delta=0.01;gamma=0.5;
        q1 = QuestCreate(Mguess(1),params.SDguess(1),params.threshold(1),beta,delta,gamma);
        q2 = QuestCreate(Mguess(2),params.SDguess(2),params.threshold(2),beta,delta,gamma);
        q3 = QuestCreate(Mguess(3),params.SDguess(3),params.threshold(3),beta,delta,gamma);
    end
    % shuffle them for pseudorandom pattern
    randConds = DotsConditions(:,randperm(length(DotsConditions)));
    % determine breaks
    b = linspace(0,Nblocks,4);
    breaks = b(2:end-1);

elseif task == 2
    % load calibration task data and amount of trials
    if part == 1
        calibration = ['fMRI_pilotData_sub_' num2str(params.subNo) '_1.mat'];
        Nblocks = params.Nblocks(1);
        cd locfMRIpilot
        load(calibration, 'locDATA');
        cd(cwd);
        % merge coh level and direction into 1 variable
        for i = 1:params.Nblocks(2)
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
        % count occurances of decision=R per coh*direction interval
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
    elseif part == 2
        calibration = ['fMRI_pilotData_sub_' num2str(params.subNo) '_fMRI_1.mat'];
        Nblocks = params.Nblocks(3);
        cd locfMRIpilot
        load(calibration, 'locDATA');
        cd(cwd);
        % take 3 mean coherence values from calibration task QUEST procedure
        coherence = locDATA.QUEST_mean;
    end
    
    % making precoherence*direction*postcoherence conditions
    DotsConditions(1,:) = repmat(coherence, 1, (Nblocks./3));   % Nblocks refers to n trials :)
    DotsConditions(2,:) = repmat([1 1 1 2 2 2], 1, (Nblocks./6));
    DotsConditions(3,:) = coherence(repmat([1 1 1 2 2 2 3 3 3], 1, (Nblocks./9)));
    % shuffle them for pseudorandom pattern
    randConds = DotsConditions(:, randperm(length(DotsConditions)));
    % determine breaks
    b = linspace(0,Nblocks,(params.Nbreaks(part)+1));
    breaks = b(2:end-1);
end

% create different files for behavioral/fmri parts 
if part == 2
    datafile = ['fMRI_pilotData_sub_' num2str(params.subNo) '_fMRI_' num2str(task) '.mat'];
end

%% Clean up data that has already been loaded
clear locDATA

% Wait for scanner pulses
if part == 2 & task == 2
    v = 0;
    while v <= params.dummyScans    % first backtick is at volume = 0, so this waits for N=dummy complete volumes
        [keyTime, key] = KbWait(-1);
        if strcmp(KbName(key),'`~')
            v = v+1;
        end
        pause(0.2);   % pause for a short time less than TR before checking again
    end
end

%% Present blocks
for n = 1:Nblocks
    timing.blockStart(n) = GetSecs;     % start of each trial not blocks :)
    % direction of movement, left (180) or right (360)
    DotsMotion = randConds(2,n) * 180;
    DotsMotion_radians = (DotsMotion/360) * (2*pi);
    % pre-decision moving dots with varying coherence
    if task == 1 & part == 2
        if randConds(1,n) == 1
            cohQ=QuestQuantile(q1);
        elseif randConds(1,n) == 2
            cohQ=QuestQuantile(q2);
        elseif randConds(1,n) == 3
            cohQ=QuestQuantile(q3);
        end
        if cohQ < 0
            cohQ_bound = 0;
        elseif cohQ > 1
            cohQ_bound = 1;
        else 
            cohQ_bound = cohQ;
        end
        showLocalizerDots_random(1, cohQ_bound, params.dur(1), DotsMotion_radians, params, screenInfo);
    else
        %tic
        showLocalizerDots_random(1, randConds(1,n), params.dur(1), DotsMotion_radians, params, screenInfo);
    end
    timing.endPreDots(n) = GetSecs;
    % collecting button response
    if part == 2 && task == 2
        [end_time, b_response, b_response_time] = collectButtonResponse(params, params.resp_deadline);
        if isnan(b_response)
            Accuracy(n) = NaN;
        end
    else
        [end_time, b_response, b_response_time] = collectButtonResponse(params, inf);
    end
    
    % check accuracy of response
    if DotsMotion == 180 && b_response == 1 || DotsMotion == 360 && b_response == 2
        Accuracy(n) = 1;
    end
    
    if task == 1
        % pass accuracy into auditory feedback code
        AuditiveFeedback(Accuracy(n));
        if part == 2 % update quest based on Accuracy
            if randConds(1,n) == 1
                q1=QuestUpdate(q1,cohQ_bound,Accuracy(n));
            elseif randConds(1,n) == 2
                q2=QuestUpdate(q2,cohQ_bound,Accuracy(n));
            elseif randConds(1,n) == 3
                q3=QuestUpdate(q3,cohQ_bound,Accuracy(n));
            end
        end
    end
    
    if task == 2 && part == 2
        if isnan(b_response)
            m_response = NaN;
            m_response_time = NaN;
            confPoints(n) = 0;
            DrawFormattedText(curWindow, ['No response to the dot motion received! \n \n \n',...
                'Please wait for the next trial to start.'],...
                'center', 'center', [255 255 255]);
            Screen('Flip', curWindow,0);
            WaitSecs(params.confDeadline + params.dur(1)./1000 + sum(params.wait(1:3)));
        else
        % confirm response + keep trial lengths the same
        Screen('DrawDots', curWindow, [0; 0], (0.2*ppd), [175 175 175], screenInfo.center, 1);
        Screen('FrameOval', screenInfo.curWindow, [175 175 175], apRect);
        Screen('Flip', curWindow,0);
        WaitSecs(params.resp_deadline - b_response_time)
        end
    end
    
    % post-decision information moving dots
    if task == 2 && isnan(b_response) == 0
        WaitSecs(params.wait(1));
        % show post decision evidence
        showLocalizerDots_random(2, randConds(3,n), params.dur(1), DotsMotion_radians, params, screenInfo);
        timing.endPostDots(n) = GetSecs;
        WaitSecs(params.wait(2));
        % collecting confidence response
        if part == 1
            [end_time, m_response, m_response_time] = showConfidenceScale(params, screenInfo);
            % compute confidence performance match with QSR
            confPoints(n) = (1-((Accuracy(n) - m_response)^2))*100;
        elseif part == 2
            [m_response, m_response_time] = collectConfidence(screenInfo, params);
            if isnan(m_response)
                confPoints(n) = 0;
            else
            % keep trial lengths the same
            WaitSecs(params.confDeadline + params.wait(3) - m_response_time)
            % compute confidence performance match with QSR
            confPoints(n) = (1-((Accuracy(n) - m_response)^2))*100;
            end
        end

    end
    
%% Storing and saving data    
    % storing coherence, direction, responses and RT's for every trial
    locDATA.dots_coherence(n) = randConds(1,n);
    locDATA.dots_direction(n) = DotsMotion;
    locDATA.button_response(n) = b_response;
    locDATA.reaction_time_button(n) = b_response_time;
    locDATA.accuracy(n) = Accuracy(n);
    locDATA.timing = timing;
    if task == 1 && part == 2
        locDATA.QUEST_mean = [QuestMean(q1),QuestMean(q2),QuestMean(q3)];
        locDATA.QUEST_sd = [QuestSd(q1),QuestSd(q2),QuestSd(q3)];
        locDATA.dots_coherence(n) = cohQ_bound;
        locDATA.QUEST_low = q1;
        locDATA.QUEST_med = q2;
        locDATA.QUEST_high = q3;
    elseif task == 2 
        locDATA.mouse_response(n) = m_response;
        locDATA.reaction_time_mouse(n) = m_response_time;
        locDATA.post_coherence(n) = randConds(3,n);
        locDATA.QSR_score(n) = confPoints(n);
        if part == 1
            locDATA.psychfitting = coherence;
        end
    end
    
    % ITI
    if part == 2
        Screen('DrawDots', curWindow, [0; 0], (0.2*ppd), [175 175 175], screenInfo.center, 1);
        Screen('FrameOval', screenInfo.curWindow, [175 175 175], apRect);
        Screen('Flip', curWindow,0);
        WaitSecs(params.ITI(2));
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
        if task == 2
            fin = find(n==breaks);
            if part == 2
                DrawFormattedText(screenInfo.curWindow, ['You can take a break from the task now. Your results are shown below.'], 'center', 500, [255 255 255]);
            else
                DrawFormattedText(screenInfo.curWindow, ['You can take a break from the task now. Your results are shown below. Press any key when you are ready for the next block of trials.'], 'center', 500, [255 255 255]);
            end
            Screen('DrawText', screenInfo.curWindow, ['You just finished block ' num2str(fin) ' out of  ' num2str(params.Nbreaks(part))], screenInfo.center(1), 200, [255 255 255]);
            c = breaks(2)-breaks(1)-1;
            blockPoints = round(sum(confPoints(end-c:end))).*params.IncrPoints(part);
            totalPoints = round(sum(confPoints)).*params.IncrPoints(part);
            totalMoney = sprintf('%.2f', (totalPoints/5000)*0.7);
            message1 = ['Number of points for this block:    ' num2str(blockPoints)];
            message2 = ['Number of total points for the experiment:    ' num2str(totalPoints)];
            message3 = ['Current total of extra money earned:    £ ' num2str(totalMoney)]; 
            Screen('DrawText', screenInfo.curWindow, message1, screenInfo.center(1), 500, [255 255 255]);
            Screen('DrawText', screenInfo.curWindow, message2, screenInfo.center(1), 550, [255 255 255]);
            Screen('DrawText', screenInfo.curWindow, message3, screenInfo.center(1), 600, [255 255 255]);
            Screen('Flip', curWindow,0);
            WaitSecs(1);
            
            if part == 2                
                pause(0.5);
                while 1
                    [s, key] = KbWait(-1);
                    if strcmp(KbName(key),'Return'), break, end
                end
                
                % Start experiment
                DrawFormattedText(curWindow, ['Please attend to the white dot in the center of the screen \n \n \n',...
                    'The stimuli will appear shortly...'],...
                    'center', 'center', [255 255 255]);
                Screen('DrawDots', curWindow, [0; 0], (0.2*ppd), [255 255 255], screenInfo.center, 1);
                Screen('Flip',curWindow);
                WaitSecs(1);

                % Wait for scanner pulses
                v = 0;
                while v <= params.dummyScans    % first backtick is at volume = 0, so this waits for N=dummy complete volumes
                    [keyTime, key] = KbWait(-1);
                    if strcmp(KbName(key),'`~')
                        v = v+1;
                    end
                    pause(0.2);   % pause for a short time less than TR before checking again
                end
            else 
                KbWait(-1);
            end
        
        elseif task == 1
            fin = find(n==breaks);
            Screen('DrawText', screenInfo.curWindow, ['You just finished block ' num2str(fin) ' out of  3'], screenInfo.center(1), 200, [255 255 255]);
            DrawFormattedText(screenInfo.curWindow, ['You can take a break from the task now. Press any key when you are ready for the next block of trials.'], 'center', 500, [255 255 255]);
            Screen('Flip',screenInfo.curWindow);
            WaitSecs(1);
            KbWait(-1)
        end
    end
    
end
%% Wrap up experiment

DrawFormattedText(screenInfo.curWindow, 'End of the task! \n \n \n \n ',...
    'center', 'center', [255 255 255]);

if task == 2
    c = breaks(2)-breaks(1)-1;
    blockPoints = round(sum(confPoints(end-c:end))).*params.IncrPoints(part);
    totalPoints = round(sum(confPoints)).*params.IncrPoints(part);
    totalMoney = sprintf('%.2f', (totalPoints/5000)*0.7);
    message1 = ['Number of points for this block:    ' num2str(blockPoints)];
    message2 = ['Number of total points for the experiment:    ' num2str(totalPoints)];
    message3 = ['Current total of extra money earned:    £ ' num2str(totalMoney)]; 
    Screen('DrawText', screenInfo.curWindow, message1, screenInfo.center(1), 500, [255 255 255]);
    Screen('DrawText', screenInfo.curWindow, message2, screenInfo.center(1), 550, [255 255 255]);
    Screen('DrawText', screenInfo.curWindow, message3, screenInfo.center(1), 600, [255 255 255]);
end
Screen('Flip',screenInfo.curWindow);

pause(0.5);
while 1
[s key] = KbWait(-1);
    if strcmp(KbName(key),'Return')
        break 
    end
end

Screen('CloseAll');
% 
% 
% %error
% O: examples in the PDF presentation in PsychDocumentation/Psychtoolbox3-Slides.pdf for more info and timing tips.
% 
% Error using Screen
% Usage:
% 
% textureIndex=Screen('MakeTexture', WindowIndex, imageMatrix [, optimizeForDrawAngle=0] [, specialFlags=0] [,
% floatprecision=0] [, textureOrientation=0] [, textureShader=0]);
% 
% Error in showConfidenceScale_adv (line 25)
% texins2 = Screen('MakeTexture', curWindow, adviser_pic);
% 
% Error in changeOfMindMain_social (line 276)
%             showConfidenceScale_adv(params, screenInfo, coh);
%  
