function [R] = FixR( Q )
%FIXR Fix rotation matrix to actually be rotation matrix

[U,~,V] = svd(Q);
B = eye(3);
B(3,3) = det(U*V');
R = U*B*V';

end

