function [end_time, m_response, response_time] = showConfidenceScale(params, screenInfo)
% function [end_time, m_response, response_time] = showConfidenceScale(params, screenInfo)
%
% function for PTB
%
% Creates continuous scale on which confidence can be reported with a mouse click
% 
% Output parameters are: end time, x location of mouse click and RT
% Parameters set are:
%


curWindow = screenInfo.curWindow;
ppd = screenInfo.ppd;
lineColor = [0 0 0];
l = params.lineLength*ppd; 
center1 = screenInfo.center(1);
center2 = screenInfo.center(2);

ShowCursor

% draw horizontal line
Screen('Drawline', curWindow, lineColor, center1-l, center2, center1+l, center2, 2);

% create intervals and descriptions
marker = linspace(-l, l, 6);
% if mod(params.subNo,2) == 1 % subNo is odd
%     percentages = [100 80 60 60 80 100];
%     descript = char('RIGHT', '', '', '', '', 'LEFT');
%     %x = bar_begin + (1-conf_adv)*bar_len; 
% elseif mod(params.subNo,2) == 0 % subNo is even
   percentages = [100 80 60 60 80 100]; %%EVDP change - scale is always left/right! 25/04/19
    descript = char('LEFT', '', '', '', '', 'RIGHT');
% end

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
    DrawFormattedText(screenInfo.curWindow, ['Please select a location on the confidence scale'], 'center', 40, [255 255 255]); % was 'center', 'center'
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
    
% if mod(params.subNo,2) == 1 % subNo is odd
%     m_response = 1 - ((x-(center1-l))/(2*l));
% elseif mod(params.subNo,2) == 0 % subNo is even
    m_response = ((x-(center1-l))/(2*l)); %EVDP change 25/04/19 subNo always even! L/R
% end
HideCursor
