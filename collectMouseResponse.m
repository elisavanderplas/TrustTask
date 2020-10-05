function [end_time, x, y, response_time] = collectMouseResponse(screenInfo, params)


curWindow = screenInfo.curWindow;
end_time= NaN;
%response = NaN;
response_time = NaN;
ppd = screenInfo.ppd;
l = params.lineLength*ppd; 

keys = [params.keyLeft params.keyRight];

end_time = GetSecs;

% Collect response, currently unlimited time
trialCompleted = false;
while ~trialCompleted
    curr_t = GetSecs;
    [x y buttons] = GetMouse(curWindow);
    if buttons(1) == 1 
        response_time = GetSecs - end_time;
        trialCompleted=true;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
