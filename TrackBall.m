%% Setup

%run initialization
init;

%get startpoint of cart
GetUltrasonic(0); %throw out first one
pause(0.1);
startPt = 10*GetUltrasonic(0);
setPtRel = defaultLandingPt - startPt - basketOffset;
setPtRelDeg = setPtRel * mm2deg;
err = Inf;

%launch ball
launcherRunning = 1;
DirectMotorCommand(launchMotor,launchpwr,0,'on','off',0,'off');
tstart = tic;
pause(0.25) %pause to let it start moving


%% Run capture loop

while runLoop && frameCount < 30 && ~hitGround 
    
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
        if pastMax && goingUp && (toc(tstart) > 0.6)
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
            
            %get current landing estimates
            x_est = x_end(end);
        else
            
            %get current landing estimates even if ball isn't seen
            if exist('x_end','var')
                x_est = x_end(end);
            else
                x_est = defaultLandingPt;
            end
        end              
    end  
    
    %make sure x is a real value we can reach
    if ~isreal(x_est) || (x_est < 0)
        x_est = defaultLandingPt;
    end
    
    %recompute setpoint
    setPtRel = x_est - startPt - basketOffset;
    setPtRelDeg = setPtRel * mm2deg;
    
    %get cart position and find error
    data = NXT_GetOutputState(cartMotor);
    err = setPtRelDeg - data.TachoCount; %deg
    
    %compute power and limit it
    pwr_cal = abs(Kp*err);
    cartpwr = min([pwr_cal,cartpwrMax]); %cap max pwr
    cartpwr = max([cartpwr,2]); %cap min pwr    
    
    %figure out if we have made it and need to stop
    if abs(err) < tolDeg
        StopMotor(cartMotor,'brake');
    else    
        DirectMotorCommand(cartMotor,sign(err)*cartpwr,0,'on','off',0,'off')
    end
    
    %turn off launcher
    if launcherRunning && toc(tstart) > launchTime
        StopMotor(launchMotor,'brake');
        launcherRunning = 0;
    end          
    
end 


%% Post Processing

%display fps
tend = toc(tstart);
fprintf('Avg FPS: %i\n',round(frameCount/tend));

%Clean up camera stuff and stop NXT
StopMotor(cartMotor,'off');
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


