
%% Clean up
clear variables
close all

%% Load the data
pathToFile = "./Queenright/Hive1/muestra999.txt"; %path including the specific file
[data,fs] = loadAndPrep_Mendeley(pathToFile); %load it

[path,name,ext] = fileparts(pathToFile); %split the path to get the Hive
path = split(path,'/'); %split the path even further

%% Calculate some other important acoustic parameters
dt = 1/fs; %sample spacing [seconds]
N = length(data); %record length [samples]
t = (0:N-1).*dt; %time vector [seconds]

%Some sanity-check time series plots:
figure
tiledlayout(2,1)
vlim = 0.35;
%plot the whole record
nexttile
plot(t,data,'b-','LineWidth',1.5)
xlabel('Time [sec]','FontSize',14,'FontWeight','bold')
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'FontSize', 14);
ylabel('Volts [v]','FontSize',14,'FontWeight','bold')
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'FontSize', 14);
title('Voltage vs. Time',strcat(path(2),"   |   ",path(3),"  |   ",strcat(name,ext)),'FontSize',14,'FontWeight','bold')
ylim([-vlim vlim])
grid on
%and plot just the first second
nexttile
plot(t,data,'b-','LineWidth',1.5)
xlabel('Time [sec]','FontSize',14,'FontWeight','bold')
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'FontSize', 14);
ylabel('Volts [v]','FontSize',14,'FontWeight','bold')
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'FontSize', 14);
title('Voltage vs. Time',strcat(path(2),"   |   ",path(3),"  |   ",strcat(name,ext)),'FontSize',14,'FontWeight','bold')
xlim([0 1])
ylim([-vlim vlim])
grid on

%% Some slightly more involved analysis

%Make some subrecords
subrecordLength = 1024; %[samples]
overlapPercentage = 0.95; %[decimal 0-1]
windowInfo = 'blackman'; 
[subrecords,win] = makeSubrecords(data,subrecordLength,overlapPercentage,windowInfo);

%Now give me an average spectral density
[Sxx,freqVec] = calcSpectralDensity(subrecords,fs);
avgSxx = mean(Sxx,2); %take the average
avgSxx_norm = avgSxx./max(avgSxx); %normalize it to a max of 1

%we calculated Sxx but only need to show one side of it
if mod(N,2)==0
    singleSideMax = freqVec(subrecordLength/2-1);
else
    singleSideMax = freqVec((subrecordLength+1)/2);
end

figure
plot(freqVec,10.*log10(avgSxx_norm),'g-','LineWidth',1.75);
xlabel('Frequency [Hz]')
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'FontSize', 14);
ylabel('Spectral Density [dB ref. Max]')
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'FontSize', 14);
title('Avergage Spectral Density',strcat(path(2),"   |   ",path(3),"  |   ",strcat(name,ext)),'FontSize',14,'FontWeight','bold')
grid on
xlim([0 singleSideMax])

%and then plot a spectrogram
figure
imagesc(t,freqVec,10.*log10(Sxx./max(max(Sxx))))
ylabel('Frequency [Hz]')
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'FontSize', 14);
xlabel('Time [seconds]')
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'FontSize', 14);
title(strcat("Spectrogram:  ",path(2),"   |   ",path(3),"  |   ",strcat(name,ext)),...
    'FontSize',14,'FontWeight','bold')
clim([-40 0])
ylim([0 singleSideMax])
clrbr = colorbar;
clrbr.Label.String = 'dB ref. max';
axis xy

%% listen to it

normForListening = data./max(data);
sound(normForListening,fs);

%Notes
%----------------------
%1111 is interesting
%999 acomms? digital pulse?

%ToDo
%-------------------------
%low pass, i don't think we're seeing anything important over 1500Hz
