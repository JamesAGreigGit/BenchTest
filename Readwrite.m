clear
close all 
clc

d = daq('ni');
d.Rate = 1000;

%Outputs
ch = addoutput(d,'Dev1',0,'Voltage');
% (Initial voltage,end voltage,number of steps)
outScanData = linspace(0,1,20000)';

%Inputs
ch0 = addinput(d,"Dev1",0:5,"Voltage");
scanData = readwrite(d,outScanData);
chan1 = scanData(:,1);
chan2 = scanData(:,2);
chan3 = scanData(:,3); 
chan4 = scanData(:,4);
chan5 = scanData(:,5);


%Moment function
func1 = @(x) (x*40.229-202.52)*0.05;
Moment = varfun(func1,chan1);

%Pressure 1 function
pmax = 30;
pmin = -30;
Vs = 5;

func2 = @(x) (x * ((pmax - pmin)/(0.8 * Vs)) - (0.1 * Vs) + pmin - 3.54)*6.89476;
PosPressure = varfun(func2,chan2);

%Pressure 2 function
pmax2 = 30;
pmin2 = -30;
Vs = 5;

func3 = @(y) (y * ((pmax2 - pmin2)/(0.8 * Vs)) - (0.1 * Vs) + pmin2 -3.54)*6.89476;
NegPressure = varfun(func3,chan3);

%Angle function
func4 = @(z) (4.5-z)*(90);
Angle1 = varfun(func4,chan4);

%Distance function
func5 = @(a) (a*9);
Distance = varfun(func5,chan5);

%Rename variables for plot
Moment = renamevars(Moment,["Fun_Dev1_ai0"],["Moment (Nm)"]);
Pos.Pressure = renamevars(PosPressure,["Fun_Dev1_ai1"],["PosPressure (kPa)"]);
Neg.Pressure = renamevars(NegPressure,["Fun_Dev1_ai2"],["NegPressure (kPa)"]);
Angle = renamevars(Angle1,["Fun_Dev1_ai3"],["Angle (Deg)"]);
Distance = renamevars(Distance,["Fun_Dev1_ai4"],["Distance (mm)"]);

%Gaussian filter, duration A
data = [Moment,Pos.Pressure,Angle];
A = 0.5*seconds;
Data = smoothdata(data,'gaussian',A);
%Plot data
stackedplot(Data)
%('Pressure & Moment Data');

%Write file
%writetimetable(Data);

%Zero pressure
write(d,0)
