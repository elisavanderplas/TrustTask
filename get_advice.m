function [a_adv, conf_adv, acc_adv] = get_advice(s, d)

%%input
% s = strength post-decision evidence (1:3)
% d = direction of the dots (1 = left, 2 = right)

% accuracy levels
P_adv = [0.6 0.75 0.9]; 

% pre-calculated d' adviser one sided - assuming no bias
d_prime = 2*norminv(P_adv(s));

% d = 1 (right), or -1 (left)
dir = d*2-3;

% internal evidence adviser
x = normrnd(dir*(d_prime/2), 1);

    % adviser action
    if x > 0
        a_adv = 2;
    else
        a_adv = 1;
    end
    
    % adviser accuracy
    acc_adv = d == a_adv;
    
    % mu and sigma adviser
    muT = sum(d_prime)/3; 
    varT = (sum((d_prime - muT).^2)/3) + 1;
    
    loglikdir = (2*muT*x)/varT; %LO odds adviser that d = 1 
    
    conf_adv = 1/(1+exp(-loglikdir)); %confidence adviser that d = 1
end

    
