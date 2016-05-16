
h = PrepNXT(2);
COM_SetDefaultNXT(h);

pause(1);

motor1 = NXTMotor('C');
motor1.Power = 100;
motor1.TachoLimit = 150;

motor = NXTMotor('A');
motor.Power = 100;
motor.TachoLimit = 250;
motor.SmoothStart = true;
motor.ActionAtTachoLimit = 'HoldBrake';

motor1.SendToNXT();
pause(0.3);
motor1.Stop('off');

motor.SendToNXT();
motor.WaitFor();

pause(1);
motor.Stop('off');

pause(1);

EndProgram(h);