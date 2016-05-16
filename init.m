%% Initialization

close all
clear

%add needed paths
addpath ./util

%initialize camera
cam = videoinput('winvideo', 1);
triggerconfig(cam,'manual');
start(cam);

%calibrate camera
load data/testimg4;
[ K, RadDist, R, t ] = calibrate2(testimg);

% Capture one frame to get its size.
frame = getsnapshot(cam);
frameSize = size(frame);

% Create the video player object.
videoPlayer = vision.VideoPlayer('Position', [100 100 [frameSize(2), frameSize(1)]+30]);

%create blob analyzer
blob = vision.BlobAnalysis(...
       'CentroidOutputPort', true, 'AreaOutputPort', false, ...
       'BoundingBoxOutputPort', true, 'MinorAxisLengthOutputPort', false, ...
       'MinimumBlobAreaSource', 'Property', 'MinimumBlobArea', 150);
   
%init for capture loop
runLoop = true;
frameCount = 0;  
ballDetected = false;
count = 1;
livePreview = false;

%empty matrices
allDetections= [];
allLocations = [];
allLocations3D = [];
detectedImages = [];

%timing params
firstpause = 0.3;
secondpause = 0.2;

%flight params
hitGround = false;
t_blindest = 0.7;
x_blindest = 700;
h_start = 120;
h_end = 120;

%prepNXT
h = PrepNXT(2);
COM_SetDefaultNXT(h);
OpenUltrasonic(0);

%prep cart motor
cart = NXTMotor('A');
cart.SmoothStart = true;
cart.ActionAtTachoLimit = 'HoldBrake';

%cart params
pos = 0;
deg2Dist = 10; %mm/deg
Kp = 1;
Ki = 1;
Kd = 1;
