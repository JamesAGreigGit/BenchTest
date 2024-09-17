% Define parameters
voltages = [1, 2, 3]; % Voltages to output
numPulses = 3; % Number of pulses per voltage level
pulseDuration = 5; % Duration of each pulse in seconds
pauseDuration = 3; % Duration of each pause in seconds
samplingRate = 1000; % Sampling rate in Hz

% Create a DataAcquisition object
daqObj = daq("ni");

% Add an analog output channel
addoutput(daqObj, "Dev1", "ao0", "Voltage");

% Add two analog input channels
addinput(daqObj, "Dev1", "ai0", "Voltage");
addinput(daqObj, "Dev1", "ai1", "Voltage");

% Set the session's rate
daqObj.Rate = samplingRate;

% Total duration for the session
totalPulses = numPulses * numel(voltages);
totalDuration = totalPulses * (pulseDuration + pauseDuration);

% Create the output signal
outputSignal = zeros(totalDuration * samplingRate, 1);
for vIndex = 1:numel(voltages)
    for i = 1:numPulses
        startIndex = (vIndex-1) * numPulses * (pulseDuration + pauseDuration) * samplingRate + ...
                     (i-1) * (pulseDuration + pauseDuration) * samplingRate + 1;
        endIndex = startIndex + pulseDuration * samplingRate - 1;
        outputSignal(startIndex:endIndex) = voltages(vIndex);
    end
end

% Queue the output data
preload(daqObj, outputSignal);

% Initialize data storage
global data;
data = [];

% Start background operation
start(daqObj, "Duration", seconds(totalDuration));

% Continuous data reading
while daqObj.Running
    [inputData, timestamps] = read(daqObj, seconds(1), "OutputFormat", "Matrix");
    storeData(inputData);
end

% Clean up
disp('Data acquisition complete');

% Plot the data
time = (0:length(data)-1) / samplingRate;
figure;
subplot(2,1,1);
plot(time, data(:,1));
title('Analog Input Channel 1');
xlabel('Time (s)');
ylabel('Voltage (V)');
subplot(2,1,2);
plot(time, data(:,2));
title('Analog Input Channel 2');
xlabel('Time (s)');
ylabel('Voltage (V)');

% Write the data to a .txt file
filename = 'daq_data.txt';
dlmwrite(filename, data, 'delimiter', '\t', 'precision', '%.6f');
disp(['Data written to ', filename]);

% Helper function to store data
function storeData(inputData)
    global data;
    data = [data; inputData];
end
