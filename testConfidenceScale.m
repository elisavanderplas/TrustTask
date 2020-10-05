function [end_time, m_response, response_time] = testConfidenceScale(question, params, screenInfo)
% function [end_time, m_response, response_time] = showConfidenceScale(params, screenInfo)
%
% function for PTB
% Offspin of showConfidence scale, specifically for combining the
% confidence scale with instructions and test questions.
%
% Creates continuous scale on which confidence can be reported with a mouse click
% 
% Output parameters are: end time, x location of mouse click (m_response)
% and RT (response_time)
% Parameters set are:

%PROBLEM: Instructions are off the screen


curWindow = screenInfo.curWindow;
ppd = screenInfo.ppd;
lineColor = params.lineColor;
l = params.lineLength*ppd; 
center1 = screenInfo.center(1);
center2 = screenInfo.center(2);

ShowCursor

message1 = ['Imagine that you have just completed one motion judgment and you were sure it was moving to the right. \n',...
'Which confidence rating should you select to maximize your earnings? Click on the scale to select your answer.'];
message2 =['Imagine that you have just completed one motion judgment but you are sure it was moving to the left.  \n',...
'Which confidence rating should you select to maximize your earnings? Click on the scale to select your answer.']; 
message3 = ['Imagine that you have just completed one motion judgment, but you are unsure as to whether \n',...
'dots were moving to the right or left. Which confidence rating should you select to maximize your earnings?'];

if question == 1
    message = message1;
elseif question == 2
    message = message2;
elseif question == 3
    message = message3;
end


% draw horizontal line
Screen('Drawline', curWindow, lineColor, center1-l, center2, center1+l, center2, 2);

% create intervals and descriptions
marker = linspace(-l, l, 6);
percentages = [100 80 60 60 80 100];
descript = char('LEFT', '', '', '', '', 'RIGHT');


for n = 1:length(marker)
    % now virtually draw all the 6 markers SIZE can be adjusted 
        Screen('Drawline', curWindow, lineColor, center1-marker(n), center2-5, center1-marker(n), center2+10)
        DrawFormattedText(curWindow, descript(n,:), center1+marker(n)-30, center2+15, [255 255 255], 1);
       DrawFormattedText(curWindow, num2str(percentages(n)), center1+marker(n)-5, center2-30, [255 255 255], 1);
end

% draw neutral marker, message and flip screen for actual drawing
Screen('Drawline', curWindow, lineColor, center1, center2-5, center1, center2+10)
DrawFormattedText(curWindow, message, 'center', 300, [255 255 255]); %removed -500, SIZE can be adjusted (300)
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
        DrawFormattedText(curWindow, descript(n,:), center1+marker(n)-30, center2+15, [255 255 255], 1);
        DrawFormattedText(curWindow, num2str(percentages(n)), center1+marker(n)-5, center2-30, [255 255 255], 1);
    end
    
    Screen('Drawline', curWindow, lineColor, center1, center2-5, center1, center2+10)
    DrawFormattedText(curWindow, message, 'center', 300, [255 255 255]);
    %DrawFormattedText(curWindow, message, screenInfo.center(2)-500, 300, [255 255 255]); %center(2)-350=center(2)
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
    DrawFormattedText(curWindow, descript(n,:), center1+marker(n)-30, center2+15, [255 255 255], 1);
    DrawFormattedText(curWindow, num2str(percentages(n)), center1+marker(n)-5, center2-30, [255 255 255], 1);
end

Screen('Drawline', curWindow, lineColor, center1, center2-5, center1, center2+10)
%DrawFormattedText(curWindow, message, screenInfo.center(2)-500, 300, [255 255 255]); %center(2)-350=center(2)
DrawFormattedText(curWindow, message, 'center', 300, [255 255 255]);
Screen('Flip', curWindow,0);
WaitSecs(0.5);
    
m_response = ((x-(center1-l))/(2*l));
HideCursor
