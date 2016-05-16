h = PrepNXT(2);
COM_SetDefaultNXT(h);
OpenUltrasonic(0);

for i = 1:100
    disp(10*GetUltrasonic(0));
    pause(0.5)
end

EndProgram(h);