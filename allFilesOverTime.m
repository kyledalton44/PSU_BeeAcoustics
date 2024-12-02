
%% Clean up
clear variables
close all

%% Define the directory to look for files in and get a list of files
pathToDirectory = "./Queenless/Hive5/"; %path
ls = dir(fullfile(pathToDirectory,"muestra*.txt")); %get the listing at the path
%{
ugghhhh i want these files in 1,2,3,4,5,6.....and I get them 1,10,100.....
so I need to reorder them, which is surprisingly annoying
%}
%get the file names
fullNames = string({ls.name}.');
%trim down to only the number
trimmedFilenames = extractBetween(fullNames,"muestra",".txt");
%string to number
fileNumbers = zeros(length(trimmedFilenames),1);
%str2double only works one string at a time
for ii = 1:length(trimmedFilenames)
    fileNumbers(ii,:) = str2double(trimmedFilenames(ii));
end
%now sort those numbers and give me the indices
[~,ndx] = sort(fileNumbers);
%and finally use those indices to sort the filenames
sortedFilenames = fullNames(ndx);

%% load each file and do some analysis

%for computing average spectral densities
%Make some subrecords
subrecordLength = 1024; %[samples]
overlapPercentage = 0.9; %[decimal 0-1]
windowInfo = 'blackman'; 

%for storing results
rmsValues = zeros(length(sortedFilenames),1);
avgSxx = zeros(subrecordLength,length(sortedFilenames));


%this is very slow...parfor?...take them all to .mat?...just deal with it?
for ii = 1:length(sortedFilenames)
    %get the full file path including the specifc file
    pathToFile = fullfile(pathToDirectory,sortedFilenames(ii));
    %load it
    [data,fs] = loadAndPrep_Mendeley(pathToFile);
    %grab the rms value
    rmsValues(ii) = rms(data);

    %compute an average spectral density
    %------------------------------------------
    %make the subrecords
    [subrecords,win] = makeSubrecords(data,subrecordLength,overlapPercentage,windowInfo);
    %spectral density
    [Sxx,freqVec] = calcSpectralDensity(subrecords,fs);
    %take the average and store it
    avgSxx(:,ii) = mean(Sxx,2); 
    ii
end

%% Smoothing

%The raw data is noisy, let's smooth it out to see more general trends
windowSize = 12; %how many samples do we want to average over
b = (1/windowSize)*ones(1,windowSize); %b coefficient
a = 1; %a coefficient
rmsValues_smoothed = filter(b,a,rmsValues); %filter it

%% Plotting

[path,name,ext] = fileparts(pathToFile); %split the path to get the Hive
path = split(path,'\'); %split the path even further

figure
tiledlayout(1,2)

nexttile
plot(1:length(sortedFilenames),rmsValues,'b-','LineWidth',1.5)
xlabel('Time [Hours]','FontSize',14,'FontWeight','bold')
xticks(1:144:length(sortedFilenames))
xticklabels(split(num2str(0:24:floor(length(sortedFilenames)/144)*24)))
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'FontSize', 14);
ylabel('RMS Voltage [V]','FontSize',14,'FontWeight','bold')
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'FontSize', 14);
title('RMS Voltage vs. Time',strcat(path(2),"   |   ",path(3)),'FontSize',14,'FontWeight','bold')
grid on
hold on
plot(1:length(sortedFilenames),rmsValues_smoothed,'r-','LineWidth',1.75)
legend("Raw Data","2-hour Moving Average")
xlim([1 length(sortedFilenames)])

nexttile
nightStart = 50;
nighttimes = nightStart:144:length(sortedFilenames);
hold on
for ii = 1:length(nighttimes)
    rectangle('Position',[nighttimes(ii) 0 72 max(rmsValues_smoothed)],'FaceColor',"#CECECE")
end
plot(1:length(sortedFilenames),rmsValues_smoothed,'r-','LineWidth',1.75)
xlabel('Time [Hours]','FontSize',14,'FontWeight','bold')
xticks(1:144:length(sortedFilenames))
xticklabels(split(num2str(0:24:floor(length(sortedFilenames)/144)*24)))
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'FontSize', 14);
ylabel('RMS Voltage [V]','FontSize',14,'FontWeight','bold')
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'FontSize', 14);
title('RMS Voltage vs. Time with Est. Nights',strcat(path(2),"   |   ",path(3)),'FontSize',14,'FontWeight','bold')
grid on
xlim([1 length(sortedFilenames)])


avgSxx_norm = avgSxx./max(avgSxx); %normalize it to a max of 1

%we calculated Sxx but only need to show one side of it
if mod(subrecordLength,2)==0
    singleSideMax = freqVec(subrecordLength/2-1);
else
    singleSideMax = freqVec((subrecordLength+1)/2);
end

%and then plot a spectrogram
figure
imagesc(1:length(sortedFilenames),freqVec,10.*log10(avgSxx_norm))
ylabel('Frequency [Hz]')
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'FontSize', 14);
xlabel('Time [Hours]','FontSize',14,'FontWeight','bold')
xticks(1:144:length(sortedFilenames))
xticklabels(split(num2str(0:24:floor(length(sortedFilenames)/144)*24)))
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'FontSize', 14);
title(strcat("Spectrogram:  ",path(2),"   |   ",path(3)),...
    'FontSize',14,'FontWeight','bold')
clim([-30 0])
ylim([0 singleSideMax])
clrbr = colorbar;
clrbr.Label.String = 'dB ref. max';
axis xy
