Autonomous Ball Catcher
by Alex Baucom
baucomrobotics.com

This is the code for a project I did where I used MATLAB to track a ball in the air and catch it with a small cart

See my website baucomrobotics.com for more details on the project itself.

Directory structure:
	CameraCalibraionImgs - exactly what it sounds like - the images I used to calibrate my camera, probably not useful for you, but they were in the git folder so I just committed them anyways
	data - random .mat data files I used for saving useful information like calibration parameters and such
	testing - various test scripts I used to try out new features
	util - useful scripts that I acually used in my project
	
Files
	TrackBall.m - the main file that runs everything
	calibrate2.m - a calibration file for determing the extrinsic parameters of my camera
	init.m - all of the initialization and parameters in one file
	CleanUp.m - Script to release the camera object and other image anlysis objects as well as close communication with NXT