
h = PrepNXT(2);
COM_SetDefaultNXT(h);


motor = NXTMotor('A');
motor.Power = 100;
motor.TachoLimit = 150;
motor.SendToNXT();
motor.WaitFor();

% pause(4);
% motor.Stop('off');

% motor.ResetPosition(h);
% motor.Power = 10;
% motor.ActionAtTachoLimit = 'Brake';
% 
% motor.SendToNXT(h);
% pause(2);

EndProgram(h);