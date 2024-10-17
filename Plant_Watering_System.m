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
xlabel('Time (seconds)');
ylabel('Dryness (voltage)');
title('Dryness over Time');
grid on;
hold on;

% set axis limits (adjust as needed)
xlim([0, 100]);  % adjust the time range
ylim([0, 5]);    % adjust based on expected dryness values

% initialize the start time
startTime = datetime('now');

% beginning stop loop
while ~stop

    dryness = readVoltage(a, 'A1'); % variable for moisture sensor voltage
    elapsedTime = seconds(datetime('now') - startTime);  % calculate elapsed time

    % add points to the animated line
    addpoints(h, elapsedTime, dryness);

    % update the graph
    drawnow limitrate;  % 'limitrate' makes plotting smoother by limiting updates

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