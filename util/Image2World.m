function [ X ] = Image2World( K,R,t,x,z_est )
%IMAGE2WORLD 

xbar = [x 1]';

x_img = z_est*(K\xbar);

X = R'*(x_img-t);

end

