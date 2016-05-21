h = PrepNXT(2);
COM_SetDefaultNXT(h);
OpenUltrasonic(0);

%launcher
launchMotor = MOTOR_C;
launchpwr = 100;
launchTime = 0.5;
launcherRunning = 1;
DirectMotorCommand(launchMotor,launchpwr,0,'on','off',0,'off');
t = tic;

%cart/controller parameters
cartMotor = MOTOR_A;
cartpwrMax = 100;
deg2mm = (36/12)*(20/12)*58*pi/360; %mm/deg = gearRat1*geatRat2*D*pi*(1 rev / 360 deg)
mm2deg = 1/deg2mm;
tol = 10; %mm
tolDeg = tol*mm2deg;
Kp = 1;

%initialize setpoint
setPt = 700; %mm
startPt = GetUltrasonic(0); %thow out first one
pause(0.1);
startPt = 10*GetUltrasonic(0);
setPtRel = setPt - startPt;
setPtRelDeg = setPtRel * mm2deg;
err = Inf;
DirectMotorCommand(cartMotor,cartpwrMax,0,'on','off',0,'off')
count = 0;

%run controller
while count < 200
    
    data = NXT_GetOutputState(cartMotor);
    err = setPtRelDeg - data.TachoCount; %deg
    
    pwr_cal = abs(Kp*err);
    cartpwr = min([pwr_cal,cartpwrMax]); %cap max pwr
    cartpwr = max([cartpwr,2]); %cap min pwr    
    
    if abs(err) < tolDeg
        StopMotor(cartMotor,'brake');
    else    
        DirectMotorCommand(cartMotor,sign(err)*cartpwr,0,'on','off',0,'off')
    end
    
    if mod(count,20) == 0
        curPos = 10*GetUltrasonic(0);
        curEst = data.TachoCount*deg2mm + startPt;
        fprintf('US: %i mm, Tacho: %i mm\n',curPos,round(curEst));
    end
    
    if launcherRunning && toc(t) > launchTime
        StopMotor(launchMotor,'brake');
    end
    
    pause(0.01)
    count = count + 1;
    
end

%stop everything and shut down
StopMotor(cartMotor,'brake');
pause(1);
StopMotor(cartMotor,'off');

posUS1 = 10*GetUltrasonic(0);

EndProgram(h);