function [data,fs] = loadAndPrep_Mendeley(pathToFile)
%LOADANDPREP_MENDELEY For loading the raw Mendeley data and putting it in a
%usable form
%   Reads in .txt files containing ADC counts, then converts to volts.
%   Always outputs fs = 4e3 Hz

%{
INPUTS: 
------------------------
pathToFile
    - where is the input file?
%}

%{
OUTPUTS:
-------------------------
data 
    - the data contained in the .txt file after converting to volts and
    removing the mean
fs
    - sample rate, always 4e3 Hz
%}

%% FUNCTION START
%--------------------------------------------------------------------------

%get a fileID using fopen. 'r' means we're reading
fileID = fopen(pathToFile,'r');
%use fscanf to read the file. %i formats the data as integers
raw = fscanf(fileID,'%i'); %[ADC count]
%We're done with this file. Close it
fclose(fileID);

%Theoretically this is 30 seconds of data recorded at fs = 4k
%---------------------------------------------------------------
%get all of our important acoustic signal processing values
fs = 4e3; %samplings rate [samples/second]

%ADC conversion
%-----------------------------------
%According to the authors, they used a 12-bit ADC
adcBits = 12; %[bits]

%Looked up the low and high reference voltages from the data sheet. These
%aren;t necessarily the values that got used in the experiment, but it
%should be good enough
vRefL = 0; %[volts]
vRefH = 3.3; %[volts]

%convert adc values to voltage using the ADC resolution
adcResolution = (vRefH - vRefL)/(2^adcBits); %[volts/ADC count]
data = raw.*adcResolution; %[volts]

%this is going to have a DC offset. remove the offset by subtracting the mean
data = data - mean(data);

end
%FUNCTION START
%--------------------------------------------------------------------------
