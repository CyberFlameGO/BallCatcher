
%close vidop player
release(videoPlayer);
close all

%release camera object
stop(cam);
clear cam;

%stop NXT running
EndProgram(h);