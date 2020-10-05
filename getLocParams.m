function params = getLocParams
% Params function for MT+ localizer
%
% SF 2013

%% Subject-specific inputs
params.subNo = input('Subject # ? ');

%% random dot motion parameters (for vis expt)
% all measurements are in deg vis ang unless specified otherwise
params.apXYD = [0 0 7];   % random dot aperture dimensions
params.speed = 5; % deg/s
params.density = 30; % dots/deg^2/s
params.dotColor = [255 255 255]; % white dots default; need to measure luminance
params.fixdotColor = [255 255 255; 255 0 0];
params.dotSize = 0.12; % moving dot size
params.fixdotSize = 0.2; % fixation dot size
%% task parameters
params.Nblocks = [240 400 800]; %trial numbers [calib task 2 task 3] 
params.Nbreaks = [4 5 9]; %Nbreaks is number of task blocks [task 1 task 2 task 3] should be 9
params.IncrPoints = [1 1 1]; % by how much should points be multiplied [task 1 task 2 task 3]
params.dur = [300];  % dot motion dur in milliseconds
params.textSize = 20;%was 15
params.conditionsC = [0.03 0.08 0.12 0.24 0.48 1]; 
params.wait = [0.1 0.2 0.5];    % 1 = wait before post-decision coherence; 2 = wait after post-decision coherence; 3 = confidence confirmation time
params.resp_deadline = 1.5;
params.confDeadline = 3; % in secs
params.ITI = [0.5 0.5 0.5]; % 1 = out of scanner ITI (i.e. both ITI's are shown for total of 2s)
%% QUEST parameters
params.threshold = [0.6 0.75 0.8]; %set to 0.6 and 0.8 after meeting with Dan 16/12 to assure advice is appealing enough
params.SDguess = [0.05,0.05,0.05]; % input stdev quest
params.Mguess = [0.08 0.16 0.32]; % only used for fmri practice trials!
%% input parameters 
params.keyLeft = KbName('1!');
params.keyRight = KbName('2@');
params.keyConfirm = KbName('3#');
%% confidence scale parameters
params.lineLength = 13; % in degrees, 1/2 linelength
params.lineColor = [0 0 0];
params.VASwidth_inDegrees = 16;
params.VASheight_inDegrees = 1.6;
params.VASoffset_inDegrees = 0;
params.arrowWidth_inDegrees = 0.5;
%% Scanning parameters
params.dummyScans = 5;
params.wait(4) = 1.000;
params.order{1} = [1 2]; 
params.order{2} = [2 1]; 

