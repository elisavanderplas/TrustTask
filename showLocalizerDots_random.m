function showLocalizerDots_random(prepost, theta, dur, s_motion, params, screenInfo)
% function showLocalizerDots_random(prepost, theta, dur, s_motion, params, screenInfo)
%
% RDK function for PTB
%
% Implements "3 frame" routine of Shadlen & Newsome 2001
% In that paper:
%
% Diam - 5-10deg
% Speed - 3-7deg per sec
% Density - 16.7 per deg2 per sec
%
% Parameters set in params; prepost = whether the dots resemble pre or post decision evidence,
% theta = coherence, s_motion = the direction of the moving dots, dur = duration of moving dots
%
% SF 2012

curWindow = screenInfo.curWindow;
ppd = screenInfo.ppd;
dotColor = params.dotColor;
dotSize = params.dotSize*ppd;
fixSize = params.fixdotSize*ppd;
rseed = screenInfo.rseed;
center = screenInfo.center;
center(1) = center(1) + params.apXYD(1)*ppd;
center(2) = center(2) - params.apXYD(2)*ppd;

frames = ceil(dur./screenInfo.frameDur);    % number of video frames per trial
dim = params.apXYD(:,3)*ppd;        % dimensions of holding space in pixels
x = params.apXYD(:,1)*ppd;
y = params.apXYD(:,2)*ppd;
r = ((params.speed./screenInfo.monRefresh).*3) * ppd;         % Displacement of dots in pixels, over 3 frames   (we want ~ 5 deg per second)
dotnumber = ceil((params.density * (params.apXYD(:,3)^2))/screenInfo.monRefresh); % density x area of box divided by number of screens per sec
apRect = floor(createTRect(params.apXYD, screenInfo));
apRange = dim - dotSize;    % dimension of circle outside of which dots are excluded

% SEED THE RANDOM NUMBER GENERATOR ... if "[]" is given, reset
% the seed "randomly"... this is for VAR/NOVAR conditions
if ~isempty(rseed) && length(rseed) == 1
    rand('state', rseed);
elseif ~isempty(rseed) && length(rseed) == 2
    rand('state', rseed(1)*rseed(2));
else
    rseed = sum(100*clock);
    rand('state', rseed);
end

%% Compute motion

% Initialise dot locations for first 3 consecutive frames (see Shadlen &
% Newsome 2001)
for t = 1:3
    cartX(t,:) = [(rand(dotnumber,1) * dim) - (dim/2)]';
    cartY(t,:) = [(rand(dotnumber,1) * dim) - (dim/2)]';
    exc(t,:) = (cartX(t,:).^2 + cartY(t,:).^2) >= (apRange/2)^2;
end

nCoherent = round(theta * dotnumber);  % Define coherent no of dots for that trial drawn from normal dist
randDots = dotnumber-nCoherent;

k = 1;
for f = 1:frames/3;
    for t = 1:3
        changeDots = [zeros(randDots,1); ones(nCoherent,1)];        % define vector for indexing into dot coords
        changeDots = logical(changeDots(randperm(dotnumber)'));     % Randomise which dots are defined as random on this frame
        
        new_cartX = zeros(dotnumber,1);
        new_cartY = zeros(dotnumber,1);

        % Define constant random displacement vector for changedots
        thetaNew = ones(size(cartX(k,changeDots),2),1) * s_motion;
        [newX newY] = pol2cart(thetaNew,r);
        
        % Define random angle of motion for all dots not in coherent selection
        thetaRand = (rand(size(cartX(k,~changeDots),2),1)) * (2*pi);
        [randX randY] = pol2cart(thetaRand,r);      % Convert to cartesian vector displacement
        
        % Add random displacements to current dot locations
        new_cartX(~changeDots) = cartX(k,~changeDots) + randX';
        new_cartY(~changeDots) = cartY(k,~changeDots) + randY';
        new_cartX(changeDots) = cartX(k,changeDots) + newX';
        new_cartY(changeDots) = cartY(k,changeDots) + newY';
        
        % Replot dots that have gone outside of the bounding box on the
        % other side
        outsideDotsX = find(new_cartX > dim/2);
        outsideDotsY = find(new_cartY > dim/2);
        new_cartX(outsideDotsX) = new_cartX(outsideDotsX) - dim;
        new_cartY(outsideDotsY) = new_cartY(outsideDotsY) - dim;
        outsideDotsX = find(new_cartX < -dim/2);
        outsideDotsY = find(new_cartY < -dim/2);
        new_cartX(outsideDotsX) = new_cartX(outsideDotsX) + dim;
        new_cartY(outsideDotsY) = new_cartY(outsideDotsY) + dim;
        
        % Update new dots to plot in three frames time
        cartX(k+3,:) = new_cartX';
        cartY(k+3,:) = new_cartY';
        % Exclude dots outside of circular aperture
        exc(k+3,:) = (cartX(k+3,:).^2 + cartY(k+3,:).^2) >= (apRange/2)^2;
        
        k = k+1;
    end
end
        
%% Display motion for this trial
% Screen('DrawingFinished',curWindow,dontclear);
    
for frame = 1:frames       
    Screen('FrameOval', screenInfo.curWindow, [255 255 255], apRect); 
    
    % now do actual drawing commands, although nothing drawn until next loop
    dotShow = [cartX(frame,~exc(frame,:)); cartY(frame,~exc(frame,:))];
    Screen('DrawDots', curWindow, dotShow, dotSize, dotColor, center);
    Screen('DrawDots', curWindow, [0; 0], fixSize, params.fixdotColor(prepost,:), screenInfo.center, 1);  
    
    % after all computations, flip, this draws dots from previous loop,
    Screen('Flip', curWindow,0);  
end

% present oval and fixation before response
Screen('FrameOval', curWindow, [255 255 255], apRect);
Screen('DrawDots', curWindow, [0; 0], fixSize, params.fixdotColor(prepost,:), screenInfo.center, 1);
Screen('Flip', curWindow,0);
Priority(0);

