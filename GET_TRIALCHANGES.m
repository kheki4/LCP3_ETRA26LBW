clear; %clear environment variables
clc; %clear command window
format compact; %tömören mutassa a parancssor kimenetét

global LOGLEVEL
% LOGLEVEL = 1; % nothing
% LOGLEVEL = 2; % info only
% LOGLEVEL = 3; % info and warning too
LOGLEVEL = 4; % info, warning and debug too

% --------------------------------------------------
% CONFIG

Config.ExpDirName = 'PLR_LUND';

% Config.ETDataFormat = 'Tobii';
Config.ETDataFormat = 'PupilEXT';


% --------------------------------------------------
% PREPARE VARIABLES

Meta.RootDirTag = [strrep(Config.ExpDirName,' ','_')];
Meta.CfPrefix = [strrep(Config.ExpDirName,' ','_') '_'];

Meta.RootDirTag = [Meta.RootDirTag '_' Config.ETDataFormat];
disp(['Using eye tracker data format: ' Config.ETDataFormat]);

Config = support_DefineETDataSpecs(Config);

Participants = support_FindParticipantsByFiles(Config, false);


% --------------------------------------------------
% PROCESS AND SAVE

for ppnr = 1:length(Participants)

    Participant.ID = Participants{ppnr};
    Participant.Nr = ppnr;
    
    disp('--------------------------------------------------');
    log_i(['Currently processing ' char(Participants(ppnr)) ' at index ' num2str(ppnr)]);
    
    Config.PXorMM = true;
    ETData = GetData(['~RAWDATA/' Config.ETDeviceDirName '/' Config.ExpDirName], char(Participants(ppnr)), Config.ETDataFormat, Config.PXorMM);
    timestamp = ETData.Samples.Ts;
    pupdil = ETData.Samples.Pupdil;

    T = support_findTrialChanges(ETData.Triggers.Trial, ETData.Triggers.Ts);
    
    outFilePath = ['~RESULTS/' Meta.RootDirTag '/' 'Trial changes' '/' ];
    mkdir(outFilePath);
    outFileName = [char(Participants(ppnr)) '_trial_changes' '_' Config.ETDataFormat '.xls']; % no prefix here

    writetable(T, [outFilePath outFileName]);
    clearvars timestamp trial pupdil;
    
end





