%% practice_fMRItask
%
% allows participants to try out 10 trials from the full task they will perform in 
% the fMRI scanner, including: motion, motion judgement, post-decision
% evidence and confidence rating using a confidence slider.

clear all


params = getLocParams;

% Ensure portability
KbName('UnifyKeyNames');

screenInfo.rseed = [];
rseed = sum(100*clock);
rand('state',rseed);

%% Open window and record refresh rates

% set screen dimensions
monWidth = 42;
viewDist = 45;
screenDim = [];
screenNum = 0;

% set screen info parameters
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
Screen('TextSize', screenInfo.curWindow, params.textSize);

% Start experiment
DrawFormattedText(curWindow, ['Please attend to the white dot in the center of the screen \n \n \n',...
    'The stimuli will appear shortly...'],...
    'center', 'center', [255 255 255]);
Screen('DrawDots', curWindow, [0; 0], (0.2*ppd), [255 255 255], screenInfo.center, 1);
Screen('Flip',curWindow);
WaitSecs(1);

% making precoherence*direction*postcoherence conditions
DotsConditions(1,:) = repmat(params.Mguess, 1, 4);
DotsConditions(2,:) = repmat([1 1 1 2 2 2], 1, 2);
DotsConditions(3,:) = params.Mguess([1 1 1 2 2 2 3 3 3 3 2 1]);
% shuffle them for pseudorandom pattern
randConds = DotsConditions(:, randperm(length(DotsConditions)));


%% Show moving and static dots

for n = 1:12
    DotsMotion = randConds(2,n).*180;
    DotsMotion_radians = (DotsMotion/360).*(2.*pi);
    
    % show first moving dots presentation
    showLocalizerDots_random(1, randConds(1,n), params.dur(1), DotsMotion_radians, params, screenInfo);
    % ask for motion judgment
    [end_time, b_response, b_response_time] = collectButtonResponse(params, 1.5);
    % keeping trial lengths constant when reponse too late|in time
    if isnan(b_response)
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
        
        WaitSecs(params.wait(1));
        % show post decision evidence
        showLocalizerDots_random(2, randConds(3,n), params.dur(1), DotsMotion_radians, params, screenInfo);
        WaitSecs(params.wait(2));
        % collecting confidence response
        [m_response, m_response_time] = collectConfidence(screenInfo, params);
        % keep trial lengths the same
        if ~isnan(m_response)    
        WaitSecs(params.confDeadline - m_response_time)
        end
    end
    
    %ITI
    Screen('DrawDots', curWindow, [0; 0], (0.2*ppd), [175 175 175], screenInfo.center, 1);
    Screen('FrameOval', screenInfo.curWindow, [175 175 175], apRect);
    Screen('Flip', curWindow,0);
    WaitSecs(1.5);
    Screen('DrawDots', curWindow, [0; 0], (0.2*ppd), [255 255 255], screenInfo.center, 1);
    Screen('FrameOval', screenInfo.curWindow, [255 255 255], apRect);
    Screen('Flip', curWindow,0);
    WaitSecs(0.5);
end
            
DrawFormattedText(screenInfo.curWindow, 'End of the practice task!', 'center', 'center', [255 255 255]);    
Screen('Flip', curWindow,0);
WaitSecs(0.5)
pause(0.5);
while 1
    [s key] = KbWait(-1);
    if strcmp(KbName(key),'Return')
        break
    end
end

Screen('CloseAll');
