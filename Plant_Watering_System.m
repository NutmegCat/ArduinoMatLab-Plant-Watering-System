function plant_state = Plant_Watering_System
a = arduino('COM5', 'Nano3')

% live graph setup
figure(1)
h = animatedLine;
ax = gca;
ax.YGrid = 'on';
ax.YLim = [-0.1 5];
title("Moisture Sensor v. Time (LIVE)");
ylabel("Moisture Sensor Voltage (Volts)");
xlabel("Tiem [HH:mm:SS]");
startTime = dateTime("now");

% stop condition
stop = 0;

% beginning stop loop
while ~stop
    moist = readVoltage(a, 'A1'); % variable for moisture sensor voltage

    t = dateTime('now') - startTime; % current time

    addpoints(h, datenum(t), moist) % points to graph

    % update axes
    ax.XLim = datenum([t-seconds(15) t]);
    datetick('x', 'keeplimits')
    drawnow

    % conditional for dry soil
    if (moist > 3.5)
        plant_state = "Thirsty";
        disp(plant_state);
        writeDigitalPin(a, 'D2', 1)
    % conditional for semi-wet soil
    elseif (moist > 2.7)
        plant_state = "A bit of water is needed";
        disp(plant_state);
        writeDigitalPin(a, 'D2', 1)
    % conditional for wet soil
    elseif (moist <= 2.7)
        plant_state = "Watered";
        disp(plant_state);
        writeDigitalPin(a, 'D2', 0)
    % conditional if failure
    else
        plant_state = "SYSTEM FAILURE";
        disp(plant_state);
        writeDigitalPin(a, 'D2', 0)
        stop = 1;
    end
end