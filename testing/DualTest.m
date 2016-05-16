h = PrepNXT(2);
COM_SetDefaultNXT(h);

pause(1);

launchMotor = MOTOR_C;
cartMotor = MOTOR_A;
launchpwr = 100;
cartpwr = 100;

launchTime = 0.4;
driveTime = 0.8;

DirectMotorCommand(launchMotor,launchpwr,0,'on','off',0,'off')
DirectMotorCommand(cartMotor,cartpwr,0,'on','off',0,'off')

pause(launchTime);
StopMotor(launchMotor,'brake');

pause(driveTime-launchTime);
StopMotor(cartMotor,'brake');

pause(1);
StopMotor(launchMotor,'off');
StopMotor(cartMotor,'off');

EndProgram(h);