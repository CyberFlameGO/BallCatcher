function h = PrepNXT(n)
%Close any open NXT channels and open the channels specified in n.
%n may be a matrix or scalar, but can only take on values 1 or 2


%Prepare workspace
COM_CloseNXT('all');

%Nxt MAC addresses
%DONT TOUCH THESE!
nxtMAC(1,:) = '0016530870A3';
nxtMAC(2,:) = '0016530C351D';

%Create nxt handles in array
for i = n
    h(i) = COM_OpenNXTEx('USB', nxtMAC(i,:));
    
    NXT_PlayTone(500, 100, h(i));
end

if isempty(h(1).OSName)
    h = h(2);
end

