function showConfidenceScale_adv(params, screenInfo, conf_adv, a_adv, adv_nr)
% function [end_time, m_response, response_time] = showConfidenceScale(params, screenInfo)
%
% function for PTB
%
% Creates continuous scale on which confidence can be reported with a mouse click
% 
% Output parameters are: end time, x location of mouse click and RT

adv_color = {[26, 237, 244], [241, 184, 14], [189, 46, 67]};

curWindow = screenInfo.curWindow;
ppd = screenInfo.ppd;
lineColor = [0.0479,0.2551,0.6359]; 
l = params.lineLength*ppd; 
center1 = screenInfo.center(1);
center2 = screenInfo.center(2);

marker = linspace(-l, l, 6);

if a_adv == 2%chose right
    conf_adv_scaled = 0.5 + conf_adv; 
else
    conf_adv_scaled = 0.5 - conf_adv; 
end

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
DrawFormattedText(curWindow,['Adviser' num2str(adv_nr)], center1-41, center2-250, adv_color{adv_nr}, 1); %horizontal vertical, adv_color{adv_nr}
Screen('Close', texins2); %close picture to prevent memory errors later on!

   percentages = [100 80 60 60 80 100];
    descript = char('LEFT', '', '', '', '', 'RIGHT');
    x = bar_begin + conf_adv_scaled*bar_len; 

% indicate confidence response location
Screen('Drawline', curWindow,adv_color{adv_nr}, x, center2-20, x, center2+20, 6);
Screen('Drawline', curWindow, [0, 0, 0], center1-l, center2, center1+l, center2, 2);

for n = 1:length(marker)
    % now virtually draw all the 6 markers SIZE can be adjusted
    Screen('Drawline', curWindow, lineColor, center1-marker(n), center2-5, center1-marker(n), center2+10)
    DrawFormattedText(curWindow, descript(n,:), center1+marker(n)-30, center2+30, [255 255 255], 1);
    DrawFormattedText(curWindow, num2str(percentages(n)), center1+marker(n)-5, center2-30, [255 255 255], 1);
end

Screen('Drawline', curWindow, lineColor, center1, center2-5, center1, center2+10)
    
HideCursor
