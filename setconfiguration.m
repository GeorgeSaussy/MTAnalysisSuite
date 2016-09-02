%{
    setconfuguration.m
    @purpose function to hold all of the user-ser configuration and most of the preprocessing memory declaration for runtime
    @version 0.8.4
    @author George Saussy
%}

Datastructure=struct;
% Specify appropriate folder
DataDirectory = 'Z:\Veikko_Geyer\Summer Lab\Microtubule_Analysis\';
[FileName, PathName] = uigetfile([DataDirectory, '*.mat'],'Load FIESTA File');
path = [PathName FileName];
load(path);
filamentPath=path;

FilamentData = ExtractFilamentData(Objects, Config);
numFrames=0; % to calculate -- number of usable frames
for j=1:size(FilamentData.Data,2)
    if ~isempty(FilamentData.Data{j})
        numFrames=numFrames+1;
    end
end
maxMode=50; % [] the number of modes calculated
fitNum=50; % [] max number of modes to fit
startNum=1; % [] the first mode to fit (can be changed to ignore first mode)
useCalculatedNormalError=false; % [] whether of not to use apparent width of MT or calculated normal error
Epsilon=5e-7; % [m] apparent width of MT under microscope
Temperature=297; % [K] room temperature in Kelvin (can be changed to 300 K)
delta_Temperature=1; % [K] error in temperature in Kelvin
k_B=1.3806488e-23; % [J/K] Boltzmann's constant
modeAmp=zeros(maxMode,numFrames); % [rad] to calculate -- the mode amplitudes in a given frame by mode number, frame number
epsilon=zeros(numFrames,1); % [m^2] error in point 
N=zeros(numFrames,1); % [] to calculate -- number of points on a filament in a given frame
LengthAtTime=zeros(1,numFrames); % [m] to calculate -- length of the filament in a given frame 


