
Config.ExpDirName = 'PLR_LUND';

ISISec = 10.250;
StimOnScreenSec = 4.0;

PerformGolayFiltering = true;
GolayWinSizeFactor = 0.1;
GolayOrder = 4;

% Config.ETDataFormat = 'Tobii';
% Config.PXorMM = false;

Config.ETDataFormat = 'PupilEXT';
Config.PXorMM = true;

Config.OutputNomSRate = 40; % Hz

Config.MapBehav = false;

SkipFirstNtrials = 0;

Config.EveryWhichTrial = 1;

Config.SkipParticipants = '*';


Config.FilterTrialsG = { ... 
    
    'subject_0001' [ 2 31 ]; ...
    'subject_0002' [ 2 31 ]; ...
    'subject_0003' [ 2 31 ]; ...
    'subject_0004' [ 2 31 ]; ...
    'subject_0005' [ 2 31 ]; ...
    'subject_0006' [ 2 31 ]; ...
    'subject_0007' [ 2 31 ]; ...
    'subject_0008' [ 2 31 ]; ...
    'subject_0009' [ 2 31 ]; ...
    
};

Config.FilterTrialsGVBL = Config.FilterTrialsG;
