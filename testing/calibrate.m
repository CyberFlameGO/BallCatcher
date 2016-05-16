function [ K, RadDist, R, t ] = calibrate( cal_img, show )
%CALIBRATE Calibrate camera based on single still image

load CameraParams.mat
K = cameraParams.IntrinsicMatrix';
RadDist = cameraParams.RadialDistortion;

%% Find edges

bw_hz = edge(rgb2gray(cal_img),'Prewitt',[],'horizontal');
bw_vt = edge(rgb2gray(cal_img),'Sobel',[],'vertical');

%Find horizontal lines
[H,theta,rho] = hough(bw_hz,'RhoResolution',0.5,'ThetaResolution',0.5);
P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
lines_hz = houghlines(bw_hz,theta,rho,P,'FillGap',5,'MinLength',7);

%find vertical lines
[H,theta,rho] = hough(bw_vt,'RhoResolution',0.5,'ThetaResolution',0.5);
P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
lines = houghlines(bw_vt,theta,rho,P,'FillGap',5,'MinLength',7);

%extract z direction lines
count1 = 1;
count2 = 1;
for i = 1:length(lines)
    if abs(lines(i).theta) > 2
        lines_in(count1) = lines(i);
        count1 = count1 + 1;
    else
        lines_vt(count2) = lines(i);
        count2 = count2 +1;
    end       
end

%% Show calibration image

if show == 1
    
   imshow(cal_img);
   hold on
   for k = 1:length(lines_hz)
       xy = [lines_hz(k).point1; lines_hz(k).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

       % Plot beginnings and ends of lines
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
   end
   for k = 1:length(lines_vt)
       xy = [lines_vt(k).point1; lines_vt(k).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','blue');

       % Plot beginnings and ends of lines
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
   end
   if exist('lines_in','var')
       for k = 1:length(lines_in)
           xy = [lines_in(k).point1; lines_in(k).point2];
           plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');

           % Plot beginnings and ends of lines
           plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
           plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
       end
   end
end

%% Find best lines

%horizontal

for i = 1:length(lines_hz)
    if abs(lines_hz(i).theta) > 89 
        rhos(i) = lines_hz(i).rho;
    end
end
rhos = unique(rhos);
start_points = ones(length(rhos),2)*Inf;
end_points = zeros(length(rhos),2);
for i = 1:length(lines_hz)    
    %find which rho this is
    idx = find(lines_hz(i).rho == rhos);
    
    %check if either point is greater or smaller than our end points 
    if lines_hz(i).point1(1) < start_points(idx,1)
        start_points(idx,:) = lines_hz(i).point1;
    end
    if lines_hz(i).point2(1) < start_points(idx,1)
        start_points(idx,:) = lines_hz(i).point2;
    end
    if lines_hz(i).point1(1) > end_points(idx,1)
        end_points(idx,:) = lines_hz(i).point1;
    end
    if lines_hz(i).point2(1) < end_points(idx,1)
        end_points(idx,:) = lines_hz(i).point2;
    end
end
for i = 1:length(rhos)
    newLines_hz(i).start_point = start_points(i,:);
    newLines_hz(i).end_point = end_points(i,:); 
end

%vertical lines
clear rhos start_points end_points
for i = 1:length(lines_vt)
    rhos(i)  = lines_vt(i).rho;
end
rhos = unique(rhos);
start_points = ones(length(rhos),2)*Inf;
end_points = zeros(length(rhos),2);
for i = 1:length(lines_vt)    
    %find which rho this is
    idx = find(lines_vt(i).rho == rhos);
    
    %check if either point is greater or smaller than our end points 
    if lines_vt(i).point1(2) < start_points(idx,2)
        start_points(idx,:) = lines_vt(i).point1;
    end
    if lines_vt(i).point2(2) < start_points(idx,2)
        start_points(idx,:) = lines_vt(i).point2;
    end
    if lines_vt(i).point1(2) > end_points(idx,2)
        end_points(idx,:) = lines_vt(i).point1;
    end
    if lines_vt(i).point2(2) < end_points(idx,2)
        end_points(idx,:) = lines_vt(i).point2;
    end
end
for i = 1:length(rhos)
    newLines_vt(i).start_point = start_points(i,:);
    newLines_vt(i).end_point = end_points(i,:); 
end   

%lines into image
if exist('lines_in','var')
clear rhos start_points end_points
for i = 1:length(lines_in)
    rhos(i)  = lines_in(i).rho;
end
rhos = unique(rhos);
start_points = ones(length(rhos),2)*Inf;
end_points = zeros(length(rhos),2);
for i = 1:length(lines_in)    
    %find which rho this is
    idx = find(lines_in(i).rho == rhos);
    
    %check if start points have been set
    if start_points(idx,1) == Inf
        start_points(idx,:) = lines_in(i).point1;
        end_points(idx,:) = lines_in(i).point2;
    else
        %if they have, compare all points to find longest norm and keep
        C = nchoosek(1:4,2);
        pts = [start_points(idx,:);end_points(idx,:);lines_in(i).point1;lines_in(i).point2;];
        maxlen = 0;
        for j = 1:size(C,1)
            idx1 = C(j,1);
            idx2 = C(j,2);
            len = norm(pts(idx1,:) - pts(idx2,:));
            if len > maxlen
                cur_pts = [pts(idx1,:); pts(idx2,:)];
                maxlen = len;
            end
        end
        start_points(idx,:) = cur_pts(1,:);
        end_points(idx,:) = cur_pts(2,:);
    end  
end
for i = 1:length(rhos)
    newLines_in(i).start_point = start_points(i,:);
    newLines_in(i).end_point = end_points(i,:); 
end
else
    newLines_in = [];
end

%% Second calibration image

if show == 1
    
   figure
   imshow(cal_img);
   hold on
   for k = 1:length(newLines_hz)
       xy = [newLines_hz(k).start_point; newLines_hz(k).end_point];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

       % Plot beginnings and ends of lines
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
   end
   for k = 1:length(newLines_vt)
       xy = [newLines_vt(k).start_point; newLines_vt(k).end_point];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','blue');

       % Plot beginnings and ends of lines
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
   end
   if exist('lines_in','var')
   for k = 1:length(newLines_in)
       xy = [newLines_in(k).start_point; newLines_in(k).end_point];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');

       % Plot beginnings and ends of lines
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
   end
   end
   
   %plot avg vps
%    plot(avgVps(1,1),avgVps(2,1),'o','LineWidth',2,'Color','black');
%    plot(avgVps(1,2),avgVps(2,2),'o','LineWidth',2,'Color','black');
%    plot(avgVps(1,3),avgVps(2,3),'o','LineWidth',2,'Color','black');
   
end

%% Single view geometry calculations

%put everything into a cell
clear lines
lines{1} = newLines_hz;
lines{2} = newLines_vt;
lines{3} = newLines_in;

%loop through each direciton
vp_not_exists = [];
for i = 1:3
    cur_lines = lines{i};
    n = size(cur_lines,2);
    if n<2
        vp_not_exists = [vp_not_exists, i];
        continue
    end
    C = nchoosek(1:n,2);
    
    %get homogenous coords and lines
    for k = 1:n
        hom_pts(:,:,k) = [makeHom(cur_lines(k).start_point),makeHom(cur_lines(k).end_point)];
        cur_hom_lines(:,:,k) = line_from_points(hom_pts(:,1,k), hom_pts(:,2,k));
    end
   
    %loop through each combination of lines in current direction to find
    %vanishing points
    for j = 1:size(C,1)
        idx1 = C(j,1);
        idx2 = C(j,2);
        vps(:,j) = point_from_lines(cur_hom_lines(:,:,idx1),cur_hom_lines(:,:,idx2));
    end
    allVps{i} = vps;
    avgVps(:,i) = mean(vps,2);
end

if ~(vp_not_exists==1||vp_not_exists==2)
    r1 = avgVps(:,1)/ norm(avgVps(:,1));
    r2 = avgVps(:,2)/ norm(avgVps(:,2));
    r3 = cross(r1,r2);
    R = FixR([r1 r2 r3]);
else
    error('Not enough Vps exist')
end

t_w = [19; 29.5; -65]*25.4; %inches*mm/inch - coordinates of camera in world frame
t = -R*t_w; %coordinates of world origin in camera frame

%test to see if this works
X = [100 100 100 1]';
x = World2Image(K,RadDist,R,t,X);
% Vpx = imgNorm(avgVps(:,1));
% Vpy = imgNorm(avgVps(:,2));
figure
imshow(cal_img);
hold on
plot(x(1),x(2),'x','LineWidth',2,'Color','red');
% plot(Vpx(1),Vpx(2),'x','LineWidth',2,'Color','blue');
% plot(Vpy(1),Vpy(2),'x','LineWidth',2,'Color','green');
axis auto
hold off



end

