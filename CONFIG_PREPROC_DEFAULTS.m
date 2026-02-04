
Config.DQ.Zeros.Apply = true;
Config.DQ.Zeros.CutBackMs = 0;
Config.DQ.Zeros.CutForwardMs = 0;
Config.DQ.Blinks.Apply = true;
Config.DQ.Blinks.CutBackMs = 0;
Config.DQ.Blinks.CutForwardMs = 0;
Config.DQ.Hiccups.Apply = false; %% TODO: make also other params for each device changeable
Config.DQ.DistFromCentral.Apply = false;
Config.DQ.DistFromCentral.Method = 0; % 0 = mean-SD; 1 = median-IQR
Config.DQ.DistFromCentral.Threshold = 2.5; % 2.5 advised for method 0; 2.0 or 1.5 advised for method 1


% Config.Timing.ISISec = NaN;
% Config.Timing.StimOnScreenSec = NaN;
ISISec = NaN;
StimOnScreenSec = NaN;

Config.ExpDirName = '*';
PerformGolayFiltering = false;
GolayOrder = 5; % Has to be lower than the window length so for very low fps recordings this might need to be changed

Config.ETDataFormat = 'SMI';
% Config.ETDataFormat = 'PupilEXT'; 
% Config.ETDataFormat = 'EyeLink';
% Config.ETDataFormat = 'Other';

% PupilEXT NOTE: ALWAYS USE THE SAME ALGORITHM FOR ONE ANALYSIS. CONFIDENCE CAN DIFFER

Config.SkipRawTrials = NaN;

Config.SkipRawTrialsP = [];

% Config.PXorMM = true;
Config.PXorMM = false;

GolayWinSizeFactor = 0.1;

% Config.HarFilt.Enabled = true;
Config.HarFilt.Enabled = false;

% PupilEXT specific now
confidenceThreshold = 0.87;
outlineConfidenceThreshold = 0.87; 

% Also saves behav data alongside eye data
Config.MapBehav = false;

SkipFirstNtrials = 0;

Config.EveryWhichTrial = 1;   
Config.BehavDir = '*';
Config.BehavParserFunction = '*';

Config.SkipParticipants = '*';

Config.EncOrTest = true;
Config.EncOrTest = false;

Config.FilterTrialsG = '*';
Config.FilterTrialsGVBL = '*';

Config.PlotPupil.Enabled = false;
Config.PlotPupil.Mode = 0;
% 0 = none
% 1 = FFT before + after
% 2 = signal before + after

Config.HarFilt.BaseFreq = NaN;
Config.HarFilt.FreqRadius = NaN;
Config.HarFilt.NumAddHarmonics = NaN; 

Config.OutputNomSRate = 50; % Hz

% DEV: Manually correct trigger timestamps
% Config.ManShiftMs = 120;
% Config.ManShiftMs = 180;
Config.ManShiftMs = NaN;

Config.PredefinedParticipantList = NaN;

Config.RootDirTagSuffix = '';


