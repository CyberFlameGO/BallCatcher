function [ x ] = World2Image( K,k,R,t,X )
%WORLD2IMAGE Convert world point to image point

%compute lens distortion
ab = imgNorm([R t]*X);
r2 = ab(1)^2 + ab(2)^2;
newL = k(1)*r2+k(2)*r2^2;        

%compute estimate
x_ideal = imgNorm(K*[R t]*X);
x(1,1) = (x_ideal(1) - K(1,3))*newL + x_ideal(1);
x(2,1) = (x_ideal(2) - K(2,3))*newL + x_ideal(2);
x(3,1) = 1;

end

