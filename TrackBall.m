%% Setup

%run initialization
init;

% get a quick preview of the image
preview(cam);
pause(1);
closepreview(cam);

%launch ball
motor = NXTMotor('C');
motor.Power = 100;
motor.TachoLimit = 150;
motor.SendToNXT();


%% Run capture loop

%pause to let ball start moving
pause(firstpause)
tstart = tic;

%could look into parallelizing this
% Task 1 - Camera image aquisition
% Task 2 - Image processing/filtering
% Task 3 - Ball tracking/ kalman filter
% Task 4 - Realtime cart control

while runLoop && frameCount < 20 && ~hitGround 
    
    %Get the next frame
    frame = getsnapshot(cam);    
    frameCount = frameCount + 1;
    
    %get just red stuff in the image
    [bw, rgb] = createMask(frame);
    
    %analyze the bw image for the ball blob
    [ballLocation, bbox] = step(blob, bw);
    if isempty(ballLocation)
        ballDetected = false;
    else
        ballLocation = ballLocation(1, :);
        bbox = bbox(1,:);
        ballDetected = true;
        Location3D = Image2World(K,R,t,ballLocation,1470)';
    end
    
    %check to see if ball has already reached ground
    if hitGround ~= 1 && ~isempty(allLocations3D)
        [~,idx] = max(allLocations3D(:,3));
        pastMax = idx<size(allLocations3D,1);
        goingUp = Location3D(2)>allLocations3D(end,3);
        if pastMax && goingUp
            hitGround = true;
        end
    end
    
    %collect data
    if ballDetected && ~hitGround    
        t_cur = toc(tstart);
        allDetections = [allDetections; bbox];
        allLocations = [allLocations; ballLocation];
        allLocations3D = [allLocations3D; [t_cur Location3D]];
        detectedImages(:,:,:,size(allLocations,1)) = rgb;
    end 
    
    %show live preview?
    if livePreview        
        %build preview image
        if ballDetected
            finalImage = insertShape(frame,'Rectangle',allDetections,'Color','blue','LineWidth',3);
        else
            finalImage = frame;
        end
        
        %show image
        step(videoPlayer, finalImage);
        runLoop = isOpen(videoPlayer);
    end        
    
    %analyze flight path
    if size(allLocations3D,1) >= 3 && ~hitGround
        
        %update current estimates of path when we get a measurment
        if ballDetected 
               
            %fit parabola for y direction
            Cy{count} = polyfit(allLocations3D(:,1),allLocations3D(:,3)-h_end,2);

            %fit linear for x direction
            Cx{count} = polyfit(allLocations3D(:,1),allLocations3D(:,2),1);
         
            %calculate landing time
            r = roots(Cy{count});
            t_end(count) = max(r);
            
            %calculate landing location
            x_end(count) = polyval(Cx{count},t_end(count));
            count = count + 1; 
            
            %get current landing estimages
            t_est = t_end(end);
            x_est = x_end(end);
        else
            
            %get current landing estimates even if ball isn't seen
            if exist('x_end','var')
                t_est = t_end(end);
                x_est = x_end(end);
            else
                t_est = t_blindest;
                x_est = x_blindest;
            end
        end              
    end  
    
    %take readings from sensors
    posUS = 10*GetUltrasonic(0); %dist in mm
    motorData = cart.ReadFromNXT;
    wheelAngle = motorData.Position; %angle in degrees
    posEn = wheelAngle * deg2dist; %dist in mm
    
    %do motor control
            
    
end 


%% Post Processing

%display fps
pause(secondpause);
tend = toc(tstart);
fprintf('Avg FPS: %i\n',round(frameCount/(tend-(firstpause+secondpause))));

%Clean up camera stuff and stop NXT
CleanUp;

%build overview image
overviewImage = insertShape(frame,'Rectangle',allDetections,'Color','blue','LineWidth',3);
for i=1:size(detectedImages,4)
    overviewImage = imadd(overviewImage, im2uint8(detectedImages(:,:,:,i)));
end
imshow(overviewImage)
hold on
scatter(allLocations(:,1), allLocations(:,2),40,[1 0 0],'filled');
hold off

%build trajectory image
figure
hold on
t = 0:0.01:tend;
for i = 1:count-1
    x = polyval(Cx{i},t);
    y = polyval(Cy{i},t);
    plot(x,y)
end
hold off
grid on
ylim([0 1000]);


