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
startTime = datetime("now");