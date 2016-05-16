function EndProgram(h)
%Close any open NXT channels and stop the running program

%End program
NXT_StopProgram(h);
COM_CloseNXT('all');

end