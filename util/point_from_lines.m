function [ x0 ] = point_from_lines( l0, l1 )

x0 = cross(l0, l1);

%x0 = imgNorm(x0);
end

