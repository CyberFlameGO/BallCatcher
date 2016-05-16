function [ K, RadDist, R, t ] = calibrate2( cal_img, new_pts)
%CALIBRATE Calibrate camera based on single still image

load data/CameraParams.mat
K = cameraParams.IntrinsicMatrix';
RadDist = [ 0 0]; %cameraParams.RadialDistortion;

if nargin < 2
    new_pts = 0;
end


%% Show calibration image 
if new_pts
    h = figure;
    imshow(cal_img);
    title('select 4 horizontal points and then 4 vertical points')
    [x,y] = getpts(h);
    close(h)
    save('data/last_points.mat','x','y');
else
    load data/last_points.mat;
end
  

%% Find Vps

%loop through each direciton
for i = 1:2
    %make homogenous coords
    
    if i == 1
        pts = [x(1:4)'; y(1:4)'];
    else
        pts = [x(5:8)'; y(5:8)'];
    end
    
    for j = 1:4
        ptsH(:,j) = makeHom(pts(:,j));
    end

    %find two lines
    L1 = line_from_points(ptsH(:,1),ptsH(:,2));
    L2 = line_from_points(ptsH(:,3),ptsH(:,4));

    %compute interstection for vanishing point
    Vps(:,i) = imgNorm(point_from_lines(L1,L2));
end


%% Calculate rotation and translation

r1 = K\Vps(:,1)/ norm(K\Vps(:,1));
r2 = -K\Vps(:,2)/ norm(K\Vps(:,2));
r3 = cross(r1,r2);
R = FixR([r1 r2 r3]);


% C = [410; 750; 1470]; %mm - coordinates of camera in world frame (measured)
C = [150; 850; 1470]; %mm - coordinates of camera in world frame (adjusted)
t = -R*C; %coordinates of world origin in camera frame

%test to see if this works
% origin = [0 0 0 1]';
% xdir = [100 0 0 1]';
% ydir = [0 100 0 1]';
% o = World2Image(K,RadDist,R,t,origin);
% x = World2Image(K,RadDist,R,t,xdir);
% y = World2Image(K,RadDist,R,t,ydir);
% Vpx = imgNorm(Vps(:,1));
% Vpy = imgNorm(Vps(:,2));
% 
% figure
% imshow(cal_img);
% hold on
% plot(o(1),o(2),'x','LineWidth',2,'Color','red');
% plot(x(1),x(2),'x','LineWidth',2,'Color','blue');
% plot(y(1),y(2),'x','LineWidth',2,'Color','green');
% % plot(Vpx(1),Vpx(2),'x','LineWidth',2,'Color','blue');
% % plot(Vpy(1),Vpy(2),'x','LineWidth',2,'Color','green');
% axis auto
% hold off



end

