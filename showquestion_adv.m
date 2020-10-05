
 function [m_response] = showquestion_adv(params, screenInfo, adv_nr, message)
%
% function for PTB
%
% Asks questions about each advisers after every block with scale from 0 (not
% at all) to 50 (very much)

% params = getLocParams;
% screenInfo = Screen('Preference','SkipSyncTests', 0); 
% adv_nr = 1/2 *please enter the adv_color (the advisers' background colour) in the same order
% message = what needs to be rated about the adviser in a string array e.g.
% {'trustworthy', 'accurate', etc}

adv_color = {[26, 237, 244], [241, 184, 14], [189, 46, 67]};

curWindow = screenInfo.curWindow;
ppd = screenInfo.ppd;
lineColor = [0.0479,0.2551,0.6359]; 
l = params.lineLength*ppd; 
center1 = screenInfo.center(1);
center2 = screenInfo.center(2);

ShowCursor;

marker = linspace(-l, l, 6);

% confidence adviser as a function of coherence level
bar_len = marker(6)-marker(1);
bar_begin = center1+marker(1);
bar_half_len = bar_len/2;

fs = filesep; 
[adviser_pic, ~, alpha] = imread([cd  fs 'advisers' fs 'sil' num2str(adv_nr) '.png']);

coor = CenterRectOnPoint([0,0,screenInfo.screenRect(3)/8, screenInfo.screenRect(4)/4], screenInfo.center(1), (screenInfo.center(2)-200));
Screen('FillRect', curWindow, adv_color{adv_nr}, coor);
Screen('BlendFunction', curWindow, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
adviser_pic(:,:, 4) = alpha;
texins2 = Screen('MakeTexture', curWindow, adviser_pic);
Screen('DrawTexture', curWindow, texins2,[], coor);
DrawFormattedText(curWindow,['Adviser' num2str(adv_nr) ' was ' message],center1-250, center2-250, adv_color{adv_nr}, 1);%%+70 to -70,  vertical and horizontal
DrawFormattedText(curWindow,['Adviser' num2str(adv_nr)], center1-41, center2-250, adv_color{adv_nr}, 1);
Screen('Close', texins2); %close picture to prevent memory errors later on!

percentages = [0 10 20 30 40 50];
descript = char('Not at all', '', '', '', '', 'Extremely');

Screen('Drawline', curWindow, [0, 0, 0], center1-l, center2, center1+l, center2, 2);

for n = 1:length(marker)
    % now virtually draw all the 6 markers SIZE can be adjusted
    Screen('Drawline', curWindow, lineColor, center1-marker(n), center2-5, center1-marker(n), center2+10)
    DrawFormattedText(curWindow, descript(n,:), center1+marker(n)-30, center2+30, [255 255 255], 1);
    DrawFormattedText(curWindow, num2str(percentages(n)), center1+marker(n)-5, center2-30, [255 255 255], 1);
end

% draw neutral marker and flip screen for actual drawing
Screen('Drawline', curWindow, lineColor, center1, center2-5, center1, center2+10)
Screen('Flip', curWindow,0);

% collect confidence response input
[end_time, x, y, response_time] = collectMouseResponse(screenInfo, params);

% allow for a little overshoot when aiming for 100% or 0%
if x < center1+l+25 && x > center1+l
    x = center1+l;
elseif x < center1-l && x > center1-l-25
    x = center1-l;
end

% check whether response was on confidence scale (in test mode TOO MUCH TO THE LEFT!)
while x > center1+l || x < center1-l || y > (center2+50) || y < (center2-50)
    DrawFormattedText(screenInfo.curWindow, ['Please select a location on the scale'], 'center', 40, [255 255 255]); % was 'center', 'center'
    Screen('Drawline', curWindow, lineColor, center1-l, center2, center1+l, center2, 2);
    for n = 1:length(marker)
        % now virtually draw all the 6 markers SIZE can be adjusted
        Screen('Drawline', curWindow, lineColor, center1-marker(n), center2-5, center1-marker(n), center2+10)
        DrawFormattedText(curWindow, descript(n,:), center1+marker(n)-30, center2+30, [255 255 255], 1);
        DrawFormattedText(curWindow, num2str(percentages(n)), center1+marker(n)-5, center2-30, [255 255 255], 1);
    end
    Screen('Drawline', curWindow, lineColor, center1, center2-5, center1, center2+10)
    Screen('Flip', curWindow,0);
    
    % collect mouse click on confidence scale
    [end_time, x, y, response_time] = collectMouseResponse(screenInfo, params);
end

% indicate confidence response location
Screen('Drawline', curWindow, [255 0 0], x, center2-10, x, center2+10, 3);
Screen('Drawline', curWindow, lineColor, center1-l, center2, center1+l, center2, 2);
for n = 1:length(marker)
    % now virtually draw all the 6 markers SIZE can be adjusted
    Screen('Drawline', curWindow, lineColor, center1-marker(n), center2-5, center1-marker(n), center2+10)
    DrawFormattedText(curWindow, descript(n,:), center1+marker(n)-30, center2+30, [255 255 255], 1);
    DrawFormattedText(curWindow, num2str(percentages(n)), center1+marker(n)-5, center2-30, [255 255 255], 1);
end
Screen('Drawline', curWindow, lineColor, center1, center2-5, center1, center2+10)
Screen('Flip', curWindow,0);
WaitSecs(0.5);

m_response = ((x-(center1-l))/(2*l)); %subNo always even on L/R scale

HideCursor

