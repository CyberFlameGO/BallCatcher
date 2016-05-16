function [ y] = makeHom( x )
%MAKEHOM Make homogenous coords
%   Changes 2D or 3D vector to 3D or 4D

if length(x) == 2
    y = [x(1) x(2) 1]';
elseif length(x) == 3
    y = [x(1) x(2) x(3) 1]';
else
    error('Vector needs to be 2 or 3 elements long')
end
    

end

