function [end_time, response, response_time] = collectButtonResponse(params, deadline)

end_time= NaN;
response = NaN;
response_time = NaN;

keys = [params.keyLeft params.keyRight];

end_time = GetSecs;
secs = end_time;

% Collect response
trialCompleted = false;
while ~trialCompleted & (secs - end_time) < deadline
    [keyIsDown,secs,keyCode] = KbCheck(-1);
    if sum(keyCode)==1
        secs = GetSecs;
        if any(keyCode(keys))
            response = find(keyCode(keys));
            response_time = secs - end_time;
            trialCompleted=true;
        elseif strcmp(KbName(keyCode), 'esc')
            Screen('CloseAll');
        end
    end
end
curr_t = GetSecs;
