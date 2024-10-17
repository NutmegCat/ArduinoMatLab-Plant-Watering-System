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

% create the figure and initialize the animated line
figure(1);
h = animatedline('Color', 'b', 'LineWidth', 2);
xlabel('Time (HH:MM:SS)');
ylabel('Dryness (voltage)');
title('Dryness over Time');
grid on;
hold on;

% initialize the start time
startTime = datetime('now');

% beginning stop loop
while ~stop

    dryness = readVoltage(a, 'A1');  % read moisture sensor voltage
    currentTime = datetime('now');   % get current time
    elapsedTime = currentTime - startTime;  % calculate elapsed time as duration

    % add points to the animated line (time in datetime format)
    addpoints(h, datenum(currentTime), dryness);

    % dynamically adjust the x-axis limits to keep the graph expanding
    ax = gca;
    ax.XLim = datenum([startTime, currentTime]);

    % update the graph
    drawnow limitrate;  % 'limitrate' makes plotting smoother by limiting updates

    % format the x-axis to display as HH:MM:SS
    datetick('x', 'HH:MM:SS', 'keeplimits');

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

    % stop condition when button (D6) is pressed
    stop = readDigitalPin(a, 'D6');
end

% convert datetime numbers to HH:MM:SS format at the end
datetick('x', 'HH:MM:SS', 'keepticks');