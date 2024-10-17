function plant_state = Plant_Watering_System

clear
clc

a = arduino('COM5', 'Nano3');

% watering values
reallyDryValue = 2.4;
moistureThreshold = 1.6;
saturatedValue = 1.6;

% stop condition
stop = 0;

% pre-allocate arrays for 1000 data points (you can adjust this)
timeData = nan(1, 1000);
drynessData = nan(1, 1000);
startTime = datetime('now');  % record the starting time

% create the figure and initialize the plot
figure(1);
hPlot = plot(nan, nan, 'b-', 'LineWidth', 2);
xlabel('Time (seconds)');
ylabel('Dryness (voltage)');
title('Dryness over Time');
grid on;
hold on;

% initialize the index for data storage
idx = 1;

% beginning loop
while ~stop

    dryness = readVoltage(a, 'A1'); % variable for moisture sensor voltage
    elapsedTime = seconds(datetime('now') - startTime);  % calculate elapsed time

    % store time and dryness data
    if idx <= length(timeData)
        timeData(idx) = elapsedTime;
        drynessData(idx) = dryness;
    else
        % dynamically grow the arrays if more space is needed
        timeData = [timeData, nan(1, 1000)];
        drynessData = [drynessData, nan(1, 1000)];
        timeData(idx) = elapsedTime;
        drynessData(idx) = dryness;
    end

    % conditional for dry soil
    if (dryness > reallyDryValue)
        plant_state = "Thirsty";
        disp(plant_state);
        writeDigitalPin(a, 'D2', 1);
        writeDigitalPin(a, 'D4', 1);

        % conditional for semi-wet soil
    elseif (dryness > moistureThreshold)
        plant_state = "A bit of water is needed";
        disp(plant_state);
        writeDigitalPin(a, 'D2', 1);
        writeDigitalPin(a, 'D4', 1);

        % conditional for wet soil
    elseif (dryness <= saturatedValue)
        plant_state = "Watered";
        disp(plant_state);
        writeDigitalPin(a, 'D2', 0);
        writeDigitalPin(a, 'D4', 0);

        % conditional if failure
    else
        plant_state = "SYSTEM FAILURE";
        disp(plant_state);
        writeDigitalPin(a, 'D2', 0);
        stop = 1;
    end

    % update the plot every 10 iterations to avoid slowing down the loop
    if mod(idx, 10) == 0
        set(hPlot, 'XData', timeData(~isnan(timeData)), 'YData', drynessData(~isnan(drynessData)));
        drawnow;  % update the plot
    end

    % increment index
    idx = idx + 1;

    % stop condition when button (D6) is pressed
    stop = readDigitalPin(a, 'D6');
end

% final plot update after loop ends
set(hPlot, 'XData', timeData(~isnan(timeData)), 'YData', drynessData(~isnan(drynessData)));
drawnow;