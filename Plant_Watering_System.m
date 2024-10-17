function plant_state = Plant_Watering_System

clear
clc

a = arduino('COM5', 'Nano3');

% watering values
reallyDryValue = 3.0;
moistureThreshold = 2.7;
saturatedValue = 2.7;

% stop condition
stop = 0;

% create the figure and initialize the animated line
figure(1);
h = animatedline('Color', 'b', 'LineWidth', 2);
xlabel('Elapsed Time (HH:MM:SS)');
ylabel('Dryness (voltage)');
title('Dryness over Time');
grid on;
hold on;

% set the y-axis limit to a fixed range [0, 4]
ax = gca;
ax.YLim = [0, 4];  % make y-axis static with max value at 4

% initialize the start time (set it as 0)
startTime = tic;  % start a timer

% beginning stop loop
while ~stop

    dryness = readVoltage(a, 'A1');  % read moisture sensor voltage
    elapsedTime = toc(startTime);    % get the elapsed time in seconds since the timer started

    % add points to the animated line (convert elapsedTime to datenum)
    addpoints(h, elapsedTime, dryness);

    % dynamically adjust the x-axis limits to keep the graph expanding
    ax.XLim = [0, elapsedTime];

    % update the graph
    drawnow limitrate;  % 'limitrate' makes plotting smoother by limiting updates

    % format the x-axis to display as HH:MM:SS
    ax.XTickLabel = datestr(seconds(ax.XTick), 'HH:MM:SS');  % set the x-axis labels to HH:MM:SS

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

% final update to the x-axis labels as HH:MM:SS
ax.XTickLabel = datestr(seconds(ax.XTick), 'HH:MM:SS');