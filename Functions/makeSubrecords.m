function [outputData,win] = makeSubrecords(inputData,subrecordLength,overlapPercentage,varargin)
%MAKESUBRECORDS Given an input record, split it
%up into multiple subrecords
%   This is the core of making an average spectral density or a spectrogram

%{
INPUTS: 
------------------------
inputData 
    - the input record. N x 1 column of data. (real-valued time series for now)
subrecordLength 
    - how long do you want each subrecord [samples]
overlapPercentage
 - how much overlap between adjacent subrecords. decimal between 0 - 1
windowInfo (optional)
- if you want to apply a window to the data, give some window specs
    [windowType, windowParam]
- if you don't want to apply a window, leave this out
%}

%{
OUTPUTS:
-------------------------
outputData
    - a matrix where each column is a subrecord
win
    - a copy of the window that got applied (if any)
%}

%% FUNCTION START
%--------------------------------------------------------------------------

%{
- A "record" is the entire time series 
- We're splitting the record into "sub-records"
%}
%I asked for a column, but force a column if the user gave a row
inputData = inputData(:);
%How long is the input record
recordLength = length(inputData);
%Convert thhe overlap percentage to samples
overlapSamples = floor(overlapPercentage.*subrecordLength);
%Taking our subrecord length and overlap into account, how far do we move
%the start/end ndxs after each subrecord
advance = subrecordLength-overlapSamples; 

%Determine the number of subrecords 
%{
The first subrecord will takes up 'subrecordLength' # of
samples. All subsequent subrecords will take up an additional 'advance' # of samples.
There will probably be some leftover samples at the end of the record that
won't get included in a subrecord....we're just going to leave those out.
%}
numSubrecords = floor((recordLength-subrecordLength)/advance + 1);

%Build up a column-oriented matrix of subrecords. 
%---------------------------------------------------------
%Allocate space for the subrecords
outputData = zeros(subrecordLength,numSubrecords);
%define start and stop indices for the loop we're about to do
startNdx = 1;
stopNdx = subrecordLength;
%loop through the input record to make subrecords
for ii = 1:numSubrecords
    %make a subrecord
    outputData(:,ii) = inputData(startNdx:stopNdx);
    %update the indices
    startNdx = startNdx + advance;
    stopNdx = stopNdx + advance;
end

%Apply a window (if needed)
%-------------------------------------------------------------
win = ones(subrecordLength,1);

if nargin == 4 
    winType = varargin{1};
    switch winType
        case 'tukey'
            win = tukeywin(subrecordLength,0.15); 
        case 'hamming'
            win = hamming(subrecordLength,'periodic');
        case 'hanning'
            win = hann(subrecordLength,'periodic');
        case 'blackman'
            win = blackman(subrecordLength,'periodic');
        case 'flattop'
            win = flattopwin(subrecordLength,'periodic');
        otherwise
    
    end
    %normalize the window 
    win = win./rms(win); 
    %Apply the window and output
    outputData  = outputData .* win;
end

end
%FUNTION END
%-----------------------------------------------------------


