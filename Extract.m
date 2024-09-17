data = readmatrix("50deg.txt");
Samples = 1:length(data);
Time = Samples/1000;
VF = data(:,1);
VP = data(:,2);
VFsmooth = smoothdata(VF,'gaussian',10);
VPsmooth = smoothdata(VP,'gaussian',10);

%Moment function
Moment = (VFsmooth * 40.229-202.52)*0.05;

%Pressure function
pmax = 30;
pmin = -30;
Vs = 5;

Pressure = (VPsmooth * ((pmax - pmin)/(0.8 * Vs)) - (0.1 * Vs) + pmin - 3.54)*6.89476;
[pks,locs] = findpeaks(Moment,Time,'MinPeakProminence',0.3);

P11 = pks(1);
P12 = pks(2);
P13 = pks(3);
%P14 = pks(4);
%P15 = pks(5);
P21 = pks(4);
P22 = pks(5);
P23 = pks(6);
%P24 = pks(9);
%P25 = pks(10);
P31 = pks(7);
P32 = pks(8);
P33 = pks(9);
%P34 = pks(14);
%P35 = pks(15);

Peaks = [P11 P12 P13; P21 P22 P23; P31 P32 P33];
writematrix(Peaks,'Peaks5');

figure(1)
subplot(2,1,1)
plot(Time,Moment)
findpeaks(Moment,"MinPeakProminence",0.3)
ylabel ('Moment, Nm')
subplot(2,1,2)
plot(Time,Pressure)
ylabel ('Pressure, kPa')
xlabel ('Time (s)')