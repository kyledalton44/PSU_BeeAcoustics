function [Sxx,freqVec] = calcSpectralDensity(inputData,fs)
%CALCSPECTRALDENSITY Calculate a Spectral Density
%   Given a column of data or a column-oriented matrix, return the
%   two-sided spectral density and the associated frequencies

%{
INPUTS: 
------------------------
inputData 
    - the input record(s). N x 1 column or NxM column-oriented matrix
fs
    - sampling rate [Hz]
%}

%{
OUTPUTS:
-------------------------
Sxx
    - the two-sided spectral density of the input [WU^2/Hz]
freqVec
    - the frequency vector associated with the Sxx [Hz]
%}

%% FUNCTION START
%--------------------------------------------------------------------------
%use sample rate to get sample spacing in time
dt = 1/fs; %[seconds]
%How long is the input? [samples]
N = size(inputData,1);
%how long is the input? [seconds]
T = N*dt;

%fft() to get the linear spectrum
INPUT = fft(inputData).*dt; %[WU/Hz]
%calculate frequency spacing
df = 1/T; %[Hz]
%calculate Sxx
Sxx = (abs(INPUT).^2).*df; %[WU^2 / Hz]
%frequency vector
freqVec = (0:N-1).*df; %[Hz]

end
%FUNCTION END
%--------------------------------------------------------------------------

