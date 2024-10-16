function plant_state = Plant_Watering_System

clear
clc

a = arduino('COM5', 'Nano3');

% stop condition
stop = 0;

% beginning stop loop
while ~stop
    
    dryness = readVoltage(a, 'A1'); % variable for moisture sensor voltage

    % conditional for dry soil
    if (dryness > 3.5)
        plant_state = "Thirsty";
        disp(plant_state);
        writeDigitalPin(a, 'D2', 1)
    % conditional for semi-wet soil
    elseif (dryness > 2.7)
        plant_state = "A bit of water is needed";
        disp(plant_state);
        writeDigitalPin(a, 'D2', 1)
    % conditional for wet soil
    elseif (dryness <= 2.7)
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

    % stop condition when button (D6) is pressed
    stop = readDigitalPin(a, 'D6');
end