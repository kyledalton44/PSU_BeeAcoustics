function [data,fs,json] = loadAndPrep_Kevin(pathToDirectory)
%LOADANDPREP_KEVIN For loading the data from Kevins files and putting it in a
%usable form
%   Reads in a directory that has a .wav and a .json file
%   outputs the data and some of the non-acoustic 'meta' data

%{
INPUTS: 
------------------------
pathToFile
    - where is the input directory?
%}

%{
OUTPUTS:
-------------------------
data 
    - the data contained in the .wav file
        - should be four channels (n x 4)
        - no other processing
fs
    - sample rate as returned by audioread() [Hz]

json
    - the metadata from the .json file in a MATLAB Struct
%}

%% FUNCTION START
%--------------------------------------------------------------------------

%grab the wav file and json file
%-----------------------------------------
% This is not the most efficient or robust, but it works because
% these directories only have 2 files in them
wavFile = dir(fullfile(pathToDirectory,'*.wav')); 
jsonFile = dir(fullfile(pathToDirectory,'*.json'));

%read wav
[data,fs] = audioread(fullfile(wavFile.folder,wavFile.name));

%read the json file
fid = fopen(fullfile(jsonFile.folder,jsonFile.name)); %open the file
raw = fread(fid,inf); %read in the raw data
fclose(fid); %close the file
str = char(raw'); %format it for jsondecode
json = jsondecode(str); %calljsondecode to put it in a nice struct

end
%FUNCTION START
%--------------------------------------------------------------------------
