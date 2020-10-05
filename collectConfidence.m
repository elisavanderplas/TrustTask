function [conf RT] = collectConfidence(window,p)
% function [conf RT] = collectConfidence(window,p)

curWindow = window.curWindow;
center = [window.center(1) window.center(2)];
keys = [p.keyLeft p.keyRight p.keyConfirm;];
lineColor = [0 0 0];
l = p.lineLength*window.ppd;
deadline = 0;

%% Initialise VAS scale
VASwidth=p.VASwidth_inDegrees*window.ppd;
VASheight=p.VASheight_inDegrees*window.ppd;
VASoffset=p.VASoffset_inDegrees*window.ppd;
arrowwidth=p.arrowWidth_inDegrees*window.ppd;
arrowheight=arrowwidth*2;

% Collect rating
start_time = GetSecs;
secs = start_time;
max_x = center(1) + l;
min_x = center(1) - l;
steps_x = linspace(-l, l, 11);
range_x = max_x - min_x;
index = ceil(rand*11);
xpos = center(1) + steps_x(index);
while (secs - start_time) < p.confDeadline;
    WaitSecs(.07);
    [keyIsDown,response_time,keyCode] = KbCheck(-1);
    secs = GetSecs;
    if sum(keyCode)==1
        direction = find(keyCode(keys));
        
        if direction == 1
            xpos = xpos - (range_x./10);
        elseif direction == 2
            xpos = xpos + (range_x./10);
        elseif direction == 3
            deadline = 1;
            break
        end
        
        if xpos > max_x
            xpos = max_x;
        elseif xpos < min_x
            xpos = min_x;
        end
    end
    
    % draw horizontal line
    Screen('Drawline', curWindow, lineColor, center(1)-l, center(2), center(1)+l, center(2), 2);
    
    % create intervals and descriptions
    marker = linspace(-l, l, 6);
    if mod(p.subNo,2) == 1 % subNo is odd
        percentages = [100 80 60 40 20 0];
        descript = char('certainly correct', 'probably correct', 'maybe correct', 'maybe wrong', 'probably wrong', 'certainly wrong');
    elseif mod(p.subNo,2) == 0 % subNo is even
        percentages = [0 20 40 60 80 100];
        descript = char('certainly wrong', 'probably wrong', 'maybe wrong', 'maybe correct', 'probably correct', 'certainly correct');
    end
    
    for n = 1:6
        % now virtually draw all the 6 markers SIZE can be adjusted
        Screen('Drawline', curWindow, lineColor, center(1)-marker(n), center(2)-5, center(1)-marker(n), center(2)+10)
        DrawFormattedText(curWindow, descript(n,:), center(1)+marker(n)-30, center(2)+15, [255 255 255], 1);
        DrawFormattedText(curWindow, num2str(percentages(n)), center(1)+marker(n)-5, center(2)-30, [255 255 255], 1);
    end
        
    % Draw confidence text
    DrawFormattedText(curWindow,'Confidence?','center',center(2)+VASoffset+75,[255 255 255]);
    
    % Update arrow
    arrowPoints = [([-0.5 0 0.5]'.*arrowwidth)+xpos ([1 0 1]'.*arrowheight)+center(2)+VASoffset];
    Screen('FillPoly',curWindow,[255 255 255],arrowPoints);
    Screen('Flip', curWindow);
end

if deadline == 0;
    conf = NaN;
    RT = NaN;
    % Draw confidence text
    DrawFormattedText(curWindow,'Too late!','center',center(2)+VASoffset+75,[255 255 255]);
    Screen('Flip', curWindow);
    %pause(p.wait(3));
elseif deadline == 1;
    % flip confidence response to correspond to scale
    if mod(p.subNo,2) == 1
        conf = 1-((xpos-(center(1)-l))./range_x);
    elseif mod(p.subNo,2) == 0
        conf = ((xpos-(center(1)-l))./range_x);
    end
    RT = secs - start_time;
    
    %% Show confirmation arrow
    
    % draw horizontal line
    Screen('Drawline', curWindow, lineColor, center(1)-l, center(2), center(1)+l, center(2), 2);
    
    % create intervals and descriptions
    marker = linspace(-l, l, 6);
    if mod(p.subNo,2) == 1 % subNo is odd
        percentages = [100 80 60 40 20 0];
        descript = char('certainly correct', 'probably correct', 'maybe correct', 'maybe wrong', 'probably wrong', 'certainly wrong');
    elseif mod(p.subNo,2) == 0 % subNo is even
        percentages = [0 20 40 60 80 100];
        descript = char('certainly wrong', 'probably wrong', 'maybe wrong', 'maybe correct', 'probably correct', 'certainly correct');
    end
    
    for n = 1:6
        % now virtually draw all the 6 markers SIZE can be adjusted
        Screen('Drawline', curWindow, lineColor, center(1)-marker(n), center(2)-5, center(1)-marker(n), center(2)+10)
        DrawFormattedText(curWindow, descript(n,:), center(1)+marker(n)-30, center(2)+15, [255 255 255], 1);
        DrawFormattedText(curWindow, num2str(percentages(n)), center(1)+marker(n)-5, center(2)-30, [255 255 255], 1);
    end
    
    % Draw confidence text
    DrawFormattedText(curWindow,'Confidence?','center',center(2)+VASoffset+75,[255 255 255]);
    
    % Show arrow
    arrowPoints = [([-0.5 0 0.5]'.*arrowwidth)+xpos ([1 0 1]'.*arrowheight)+center(2)+VASoffset];
    Screen('FillPoly',curWindow,[255 0 0],arrowPoints);
    Screen('Flip', curWindow);
    %pause(p.wait(3));
end