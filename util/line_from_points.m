function [ L ] = line_from_points( x,y )

if length(x) == 2
    x = makeHom(x);
    y = makeHom(y);
end

L = cross(x, y);

%L = imgNorm(L);

end

