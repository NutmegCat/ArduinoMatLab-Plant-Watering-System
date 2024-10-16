function plant_state = Plant_Watering_System

clear
clc

a = arduino('COM5', 'Nano3');

% watering values
reallyDryValue = 3.5;
moistureThreshold = 2.7;
saturaedValue = 2.7;

% stop condition
stop = 0;

% beginning stop loop
while ~stop

    dryness = readVoltage(a, 'A1'); % variable for moisture sensor voltage

    % conditional for dry soil
    if (dryness > reallyDryValue)
        plant_state = "Thirsty";
        disp(plant_state);
        writeDigitalPin(a, 'D2', 1)
        writeDigitalPin(a, 'D4', 1)
        
    % conditional for semi-wet soil
    elseif (dryness > moistureThreshold)
        plant_state = "A bit of water is needed";
        disp(plant_state);
        writeDigitalPin(a, 'D2', 1)
        writeDigitalPin(a, 'D4', 1)
        
    % conditional for wet soil
    elseif (dryness <= saturaedValue)
        plant_state = "Watered";
        disp(plant_state);
        writeDigitalPin(a, 'D2', 0)
        writeDigitalPin(a, 'D4', 0)

    % conditional if failure
    else
        plant_state = "SYSTEM FAILURE";
        disp(plant_state);
        writeDigitalPin(a, 'D2', 0)
        stop = 1;
    end

    % stop condition when button (D6) is pressed
    stop = readDigitalPin(a, 'D6');
end