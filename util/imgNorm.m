function [ x_norm ] = imgNorm( x )
%IMGNORM Normalizes last element of vector to 1
%doesn't normlaize is third element is 0

if x(3) ~= 0
    x_norm = [x(1)/x(3); x(2)/x(3); 1];
else
    x_norm = [x(1); x(2); x(3)];
end

end

