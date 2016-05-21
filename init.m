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

%launcher params
launchMotor = MOTOR_C;
launchpwr = 100;
launchTime = 0.5;

%flight params
hitGround = false;
t_blindest = 0.7;
x_blindest = 700;
h_start = 120;
h_end = 120;
defaultLandingPt = 700; %mm
x_est = defaultLandingPt;

%prepNXT
h = PrepNXT(2);
COM_SetDefaultNXT(h);
OpenUltrasonic(0);

%cart params
cartMotor = MOTOR_A;
cartpwrMax = 100;
deg2mm = (36/12)*(20/12)*58*pi/360; %mm/deg = gearRat1*geatRat2*D*pi*(1 rev / 360 deg)
mm2deg = 1/deg2mm;
tol = 10; %mm
tolDeg = tol*mm2deg;
Kp = 2;
basketOffset = 130; %mm


