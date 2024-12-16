%% Clean up
clear variables
close all

%% Path adjustments/additions
addpath("Functions\");

%% Load the data

%let the user select the right directory (rather than typing a string)
pathToDirectory = uigetdir;

%call the loading function
[data,fs,json] = loadAndPrep_Kevin(pathToDirectory);

%% make a time vector

N = size(data,1); %Number of samples (column-oriented matrix)
dt = 1/fs; %sample spacing in time [seconds]
t = (0:N-1).'.*dt; %column-oriented time vector [sec]

%% Some sanity plots

%This data theoretically has 4 channels....plot em
figure
tiledlayout(4,1)

ax1 = nexttile;
plot(t,data(:,1),'b','LineWidth',1.5)
xlabel('Time [sec]','FontSize',14,'FontWeight','bold')
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'FontSize', 14);
ylabel('Amplitude [WU]','FontSize',14,'FontWeight','bold')
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'FontSize', 14);
title('Voltage vs. Time','FontSize',14,'FontWeight','bold')
legend('Channel 1');
grid on

ax2 = nexttile;
plot(t,data(:,2),'g','LineWidth',1.5)
xlabel('Time [sec]','FontSize',14,'FontWeight','bold')
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'FontSize', 14);
ylabel('Amplitude [WU]','FontSize',14,'FontWeight','bold')
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'FontSize', 14);
title('Voltage vs. Time','FontSize',14,'FontWeight','bold')
legend('Channel 1');
grid on

ax3 = nexttile;
plot(t,data(:,3),'k','LineWidth',1.5)
xlabel('Time [sec]','FontSize',14,'FontWeight','bold')
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'FontSize', 14);
ylabel('Amplitude [WU]','FontSize',14,'FontWeight','bold')
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'FontSize', 14);
title('Voltage vs. Time','FontSize',14,'FontWeight','bold')
legend('Channel 3');
grid on

ax4 = nexttile;
plot(t,data(:,4),'r','LineWidth',1.5)
xlabel('Time [sec]','FontSize',14,'FontWeight','bold')
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'FontSize', 14);
ylabel('Amplitude [WU]','FontSize',14,'FontWeight','bold')
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'FontSize', 14);
title('Voltage vs. Time','FontSize',14,'FontWeight','bold')
legend('Channel 4');
grid on

linkaxes([ax1 ax2 ax3 ax4],'xy')

%% Initial thoughts

%{
The files are thirty seconds long. 
    It might be worth a function to only examine a portion of the signal
Definitely need to remove the DC offset
The signals seem pretty similar by eye...write a cross-correlation function
%}

%% Make zero-mean
data = data-mean(data,1);

%% AVG PSDs

%Make some subrecords
subrecordLength = fs/2; %[samples]
overlapPercentage = 0.95; %[decimal 0-1]
windowInfo = 'blackman'; 
%make the subrecords
[subrecord1,win] = makeSubrecords(data(:,1),subrecordLength,overlapPercentage,windowInfo);
subrecords = zeros(size(subrecord1,1),size(subrecord1,2),4);
subrecords(:,:,1) = subrecord1;
for nn = 2:4
subrecords(:,:,nn) = makeSubrecords(data(:,nn),subrecordLength,overlapPercentage,windowInfo);
end

%allocate space for the Sxx results
Sxx = zeros(size(subrecords,1),size(subrecords,2),4);

%for each channel....
for nn = 1:4
    %spectral density
    [Sxx_temp,freqVec] = calcSpectralDensity(subrecords(:,:,nn),fs);
    Sxx(:,:,nn) = Sxx_temp;
end

%take the average
avgSxx = squeeze(mean(Sxx,2)); 

%we calculated Sxx but only need to show one side of it
if mod(N,2)==0
    singleSideMax = freqVec(subrecordLength/2-1);
else
    singleSideMax = freqVec((subrecordLength+1)/2);
end

%% Plots 
figure
plot(freqVec./1e3,10.*log10(avgSxx(:,1)),'b-','LineWidth',1.75);
hold on
plot(freqVec./1e3,10.*log10(avgSxx(:,2)),'g-','LineWidth',1.75);
plot(freqVec./1e3,10.*log10(avgSxx(:,3)),'k-','LineWidth',1.75);
plot(freqVec./1e3,10.*log10(avgSxx(:,4)),'r-','LineWidth',1.75);
xlabel('Frequency [kHz]')
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'FontSize', 14);
ylabel('Spectral Density [dB ref. 1]')
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'FontSize', 14);
title('Avergage Spectral Density','FontSize',14,'FontWeight','bold')
xlim([0 singleSideMax./1e3])
legend('Channel 1','Channel 2','Channel 3', 'Channel 4');
grid on


figure
tiledlayout(2,2)

%set a colormap?
% colormap('cool')

%How many frequencies do we want to show....
% freqLim = singleSideMax./1e3; %one full side
freqLim = 8;

ax1 = nexttile;
imagesc(t,freqVec./1e3,10.*log10(Sxx(:,:,1)))
ylabel('Frequency [kHz]')
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'FontSize', 14);
xlabel('Time [seconds]')
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'FontSize', 14);
title("Channel 1",'FontSize',14,'FontWeight','bold')
clim([max(10.*log10(Sxx(:,:,1)),[],'all')-40 max(10.*log10(Sxx(:,:,1)),[],'all')])
ylim([0 freqLim])
clrbr = colorbar;
clrbr.Label.String = 'dB ref. 1';
axis xy

ax2 = nexttile;
imagesc(t,freqVec./1e3,10.*log10(Sxx(:,:,2)))
ylabel('Frequency [kHz]')
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'FontSize', 14);
xlabel('Time [seconds]')
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'FontSize', 14);
title("Channel 2",'FontSize',14,'FontWeight','bold')
clim([max(10.*log10(Sxx(:,:,1)),[],'all')-40 max(10.*log10(Sxx(:,:,2)),[],'all')])
ylim([0 freqLim])
clrbr = colorbar;
clrbr.Label.String = 'dB ref. 1';
axis xy

ax3 = nexttile;
imagesc(t,freqVec./1e3,10.*log10(Sxx(:,:,3)))
ylabel('Frequency [kHz]')
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'FontSize', 14);
xlabel('Time [seconds]')
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'FontSize', 14);
title("Channel 3",'FontSize',14,'FontWeight','bold')
clim([max(10.*log10(Sxx(:,:,1)),[],'all')-40 max(10.*log10(Sxx(:,:,3)),[],'all')])
ylim([0 freqLim])
clrbr = colorbar;
clrbr.Label.String = 'dB ref. 1';
axis xy

ax4 = nexttile;
imagesc(t,freqVec./1e3,10.*log10(Sxx(:,:,4)))
ylabel('Frequency [kHz]')
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'FontSize', 14);
xlabel('Time [seconds]')
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'FontSize', 14);
title("Channel 4",'FontSize',14,'FontWeight','bold')
clim([max(10.*log10(Sxx(:,:,1)),[],'all')-40 max(10.*log10(Sxx(:,:,4)),[],'all')])
ylim([0 freqLim])
clrbr = colorbar;
clrbr.Label.String = 'dB ref. 1';
axis xy

linkaxes([ax1 ax2 ax3 ax4],'xy')
