if ~exist('FLAG_GRANDCALC', 'var') || ~FLAG_GRANDCALC
    clear; % clear env
    clc; % clear command window
end
format compact;
format long;

global LOGLEVEL
% LOGLEVEL = 1; % nothing
% LOGLEVEL = 2; % info only
% LOGLEVEL = 3; % info and warning too
LOGLEVEL = 4; % info, warning and debug too

% DEVMODE = true;
DEVMODE = false;

% --------------------------------------------------
% CONFIG

% EXCEPT IF BATCH
CONFIG_PREPROC_DEFAULTS

CONFIG_PREPROC_PLR_LUND

% --------------------------------------------------
% PREPARE VARIABLES

if ~exist('Config', 'var')
    log_e('Defaults config script was not run')
end

if strcmp(Config.ExpDirName, '*')
    log_e('Experiment dir name was not set. Experiment config script likely was not run')
end

Meta.NomSRate = NaN;
Meta.FilterTrials = [NaN NaN];

Meta.ISISec = ISISec;
Meta.StimOnScreenSec = StimOnScreenSec;

Meta.RootDirTag = [strrep(Config.ExpDirName,' ','_')];
Meta.CfPrefix = regexprep(Config.ExpDirName,'[^a-zA-Z0-9_\s]','');

if Config.HarFilt.Enabled
    Meta.RootDirTag = [Meta.RootDirTag '_BASE+' num2str(Config.HarFilt.NumAddHarmonics) 'HAR'];
else
    Meta.RootDirTag = [Meta.RootDirTag '_DQ'];
end

% Meta.RootDirTag = [Meta.RootDirTag '_NOGOLAY'];
% Meta.RootDirTag = [Meta.RootDirTag '_MUTUAL'];
% Meta.RootDirTag = [Meta.RootDirTag '_FAST'];
% Meta.RootDirTag = [Meta.RootDirTag '_VBL'];

disp(['Using eye tracker data format: ' Config.ETDataFormat]);
Config = support_DefineETDataSpecs(Config);

if Config.PXorMM
    Meta.RootDirTag = [Meta.RootDirTag '_PX'];
else
    Meta.RootDirTag = [Meta.RootDirTag '_MM'];
end
Meta.RootDirTag = [Meta.RootDirTag '_' Config.ETDataFormat];

if((length(Config.PredefinedParticipantList)==1 && isnan(Config.PredefinedParticipantList(1))))
    Participants = support_FindParticipantsByFiles(Config, false);
else
    Participants = Config.PredefinedParticipantList;
end

if ~isempty(Config.RootDirTagSuffix)
    Meta.RootDirTag = [Meta.RootDirTag Config.RootDirTagSuffix];
    disp(['Root Dir Tag Suffix used: ' Config.RootDirTagSuffix]);
end

if DEVMODE
    Meta.RootDirTag = [Meta.RootDirTag '_DEV'];
    disp('RUNNING IN DEVELOPER MODE');
end

Meta.Flag_spectFiltered = Config.HarFilt.Enabled;
Meta.Flag_PXorMM = Config.PXorMM;
Meta.Flag_BehavMapped = Config.MapBehav;
Meta.PreprocVersion = 0.006;
Meta.DataStructureVersion = 0.002;

log_i(['Meta.Flag_spectFiltered = ' num2str(Meta.Flag_spectFiltered)]);
log_i(['Meta.Flag_PXorMM = ' num2str(Meta.Flag_PXorMM)]);
log_i(['Meta.Flag_BehavMapped = ' num2str(Meta.Flag_BehavMapped)]);
log_i(['Meta.PreprocVersion = ' num2str(Meta.PreprocVersion)]);

% Preallocating vectors
MeanInterpolRatio = nan(length(Participants), 1);

% Generates (target*harmonics)+-delta freq intervals, to be filtered later
interval_base = [ Config.HarFilt.BaseFreq-Config.HarFilt.FreqRadius Config.HarFilt.BaseFreq+Config.HarFilt.FreqRadius ];
%
Config.HarFilt.TargetFreqRanges = [interval_base];
for(fcs = 2:(Config.HarFilt.NumAddHarmonics+1))
    interval_har = [ (fcs*Config.HarFilt.BaseFreq)-Config.HarFilt.FreqRadius (fcs*Config.HarFilt.BaseFreq)+Config.HarFilt.FreqRadius ];
    Config.HarFilt.TargetFreqRanges = [Config.HarFilt.TargetFreqRanges ; interval_har];
end
clearvars interval_base interval_har;

% Wipe older preprocessed files in the target folder
OutFilePath = ['~PREPDATA/' Meta.RootDirTag '/'];
if exist(OutFilePath, 'dir')
    rmdir(OutFilePath, 's');
end
% Note: keep this here
if ~exist(OutFilePath, 'dir')
    mkdir(OutFilePath);
end

% --------------------------------------------------
% PROCESS AND SAVE

for ppnr = 1:length(Participants) % 23: 298 hibás VBL-es
    
    Participant.ID = Participants{ppnr};
    Participant.Nr = ppnr;
    
    disp('--------------------------------------------------');
    log_i(['Currently processing ' char(Participants(ppnr)) ' at index ' num2str(ppnr)]);
    
    Samples = struct();
    Behav = struct();
    Blinks = struct();
    Saccades = struct();
    Triggers = struct();
    
    if(strcmp(Config.ETDataFormat, 'SMI'))
        Samples.SRate = str2double(Parser_SMI_getParamValue(strcat(['~RAWDATA/' Config.ETDeviceDirName '/' Config.ExpDirName], '/', char(Participants(ppnr)), Config.ETDataFileNameEnding), 'Sample Rate'));
    elseif(strcmp(Config.ETDataFormat, 'PupilEXT'))
        ProvETData = GetData(['~RAWDATA/' Config.ETDeviceDirName '/' Config.ExpDirName], char(Participants(1)), Config.ETDataFormat, Config.PXorMM);
        Samples.SRate = 1 / median(diff(ProvETData.Samples.Ts))*1000*1000; 
    elseif(strcmp(Config.ETDataFormat, 'EyeLink'))
    % TODO: not hardcoded
%         Samples.SRate = 1000; 
        Samples.SRate = 250; 
    elseif(strcmp(Config.ETDataFormat, 'Tobii'))
        ProvETData = GetData(['~RAWDATA/' Config.ETDeviceDirName '/' Config.ExpDirName], char(Participants(1)), Config.ETDataFormat, Config.PXorMM);
        Samples.SRate = 1 / median(diff(ProvETData.Samples.Ts))*1000*1000; 
    elseif(strcmp(Config.ETDataFormat, 'GGProcessed'))
        Samples.SRate = 50; 
    elseif(strcmp(Config.ETDataFormat, 'Other'))
        Samples.SRate = 500;
    end
    Samples.OrigSRate = Samples.SRate;
    log_i(['Sample Rate in eye data file: ' num2str(Samples.SRate)]);

    % TODO: check srate so that every input recording has the same srate
    
    % Config.FilterTrialsG check
    if isfield(Config, 'FilterTrials')
%     clear Config.FilterTrials;
        Config = rmfield(Config, 'FilterTrials'); % this works only for structs
    end
    if size(Config.FilterTrialsG, 1) >= 1 && size(Config.FilterTrialsG, 2) == 2
        for fts = 1:size(Config.FilterTrialsG, 1)
            if strcmp( Config.FilterTrialsG{fts,1},char(Participants(ppnr)) )
                Config.FilterTrials = Config.FilterTrialsG{fts,2};
                break
            end
        end
        %%%
        for fts = 1:size(Config.FilterTrialsGVBL, 1)
            if strcmp( Config.FilterTrialsGVBL{fts,1},char(Participants(ppnr)) )
                Config.FilterTrialsVBL = Config.FilterTrialsGVBL{fts,2};
                break
            end
        end
        %%%
        if ~isfield(Config,'FilterTrials')
            if(strcmp(Config.ETDataFormat, 'Other'))
                log_w(['Config.FilterTrials set for dummy [1 1] as device is specified as Other, now at participant ' char(Participants(ppnr))]);
                Config.FilterTrials =  [1 1];
                Config.FilterTrialsVBLC =  [1 1]; % DEV
            else
                log_e(['Config.FilterTrials not specified for participant ' char(Participants(ppnr))]);
            end
        end
        log_i(['Filtering trials of each participant separately.']);
    else
        log_e(['Please check Config.FilterTrialsG in script configuration']);
    end

    % Config.SkipRawTrialsP check
    if isfield(Config, 'SkipRawTrials')
%     clear Config.SkipRawTrials;
        Config = rmfield(Config, 'SkipRawTrials'); % this works only for structs
    end
    if size(Config.SkipRawTrialsP, 1) >= 1 && size(Config.SkipRawTrialsP, 2) == 2
        for fts = 1:size(Config.SkipRawTrialsP, 1)
            if strcmp( Config.SkipRawTrialsP{fts,1},char(Participants(ppnr)) )
                Config.SkipRawTrials = Config.SkipRawTrialsP{fts,2};
                break
            end
        end
        %%%
        if ~isfield(Config,'SkipRawTrials')
            if(strcmp(Config.ETDataFormat, 'Other'))
                log_w(['Config.SkipRawTrials set for dummy []']);
                Config.SkipRawTrials = [];
            else
                log_e(['Config.SkipRawTrials not specified for participant ' char(Participants(ppnr))]);
            end
        end
        log_i(['Skipping trials specified for each participant separately.']);
    else
        Config.SkipRawTrials = []; 
        log_w(['Please check Config.SkipRawTrialsP in script configuration']);
    end

    % TODO: TO BE PHASED OUT
    if ~isnan(SkipFirstNtrials) && isnumeric(SkipFirstNtrials) && SkipFirstNtrials>0
        log_w(['Skipping first ' num2str(SkipFirstNtrials) ' trials']);
        Config.FilterTrials(1) = Config.FilterTrials(1) + SkipFirstNtrials;
        Config.FilterTrialsVBL(1) = Config.FilterTrialsVBL(1) + SkipFirstNtrials; % DEV
    end

    log_i(['Parsing participant data']);
    ETData = GetData(['~RAWDATA/' Config.ETDeviceDirName '/' Config.ExpDirName], char(Participants(ppnr)), Config.ETDataFormat, Config.PXorMM);
    Samples.Ts = ETData.Samples.Ts;
    Samples.Pupdil = ETData.Samples.Pupdil;
    Samples.QualityValues = ETData.Samples.QualityValues;
    Blinks.StartTs = ETData.Blinks.Start;
    Blinks.EndTs = ETData.Blinks.End;
    Saccades.StartTs = ETData.Saccades.Start;
    Saccades.EndTs = ETData.Saccades.End;
    Saccades.StartX = ETData.Saccades.StartX;
    Saccades.StartY = ETData.Saccades.StartY;
    Saccades.EndX = ETData.Saccades.EndX;
    Saccades.EndY = ETData.Saccades.EndY;
    Saccades.Magnitude = ETData.Saccades.Magnitude;
%     qualityValues = ETData.QualityValues;
    % NOTE: "end" is a keyword of Matlab language, need to avoid it

    % PERFORM TRIGGER "NUMBERING ALIGNMENT", based on Config.FilterTrials and everyWhich, on ONLY the trigger timestamp vector! 
    % So we only KEEP the needed trigger timestamps, that is the "renumbering" step
    [Meta.NumTrials, Triggers.Stim.Trial, Triggers.Stim.Ts] = support_createAlignedTriggerVecStim(ETData.Triggers.Trial, ETData.Triggers.Ts, Config.FilterTrials, Config.SkipRawTrials, Config.EveryWhichTrial);

    % Create variable-baseline (VBL) alignment vector. This is necessary if there is a special trigger vector that designates the timestamps,
    % related to which the baseline correction should be done (e.g. if stimulus presentation onset was in variable temporal distance related to
    % the baseline correction period, in each trial). E.g. a sequence of stimuli to be memorized starts presentation at a certain time, and
    % variable time later comes the actual to-be-baseline-corrected period
    [ChecksumNumTrialsVBL, Triggers.VBL.Trial, Triggers.VBL.Ts] = support_createAlignedTriggerVecStim(ETData.Triggers.Trial, ETData.Triggers.Ts, Config.FilterTrialsVBL, Config.SkipRawTrials, Config.EveryWhichTrial);

    if Meta.NumTrials ~= ChecksumNumTrialsVBL
        log_e(['The number of trials based on stimulus trigger timestamps and variable-baseline alignment vector is different. This should normally never happen.']);
    end

    Samples.OrigRecLenSec = (Samples.Ts(length(Samples.Ts))-Samples.Ts(1))/1000/1000;
    log_i(['Length of recording to be processed in seconds: ' num2str( (Samples.Ts(length(Samples.Ts))-Samples.Ts(1))/1000/1000 )]);
    
    if DEVMODE && ~isnan(Config.ManShiftMs) && isnumeric(Config.ManShiftMs) && Config.ManShiftMs~=0
        log_w('MANUALLY SHIFTED STIMULUS TIMESTAMPS');
        Triggers.Stim.Ts = Triggers.Stim.Ts + Config.ManShiftMs*1000;
    end
    
    % --------------------------------------------------
    % MAP BEHAV DATA
    
    if Config.MapBehav
        if size(Config.FilterTrials, 1) == 1
            clear(Config.BehavParserFunction);
            Behav = feval(Config.BehavParserFunction, Config, Triggers.Stim, Participant.ID);
        else
            log_e(['Please check Config.FilterTrials in script configuration']);
        end

%         if length(Triggers.Stim.Trial) < length(Behav.Trial)
%             log_w(['Behav_trial vector length is different than expected. Cutting back behav data to available number of trials in recording.'])
% %             pause()
%             Behav.Trial = Behav.Trial(1:length(Triggers.Stim.Trial));
%             Behav.RT = Behav.RT(1:length(Triggers.Stim.Trial));
%             Behav.StimType = Behav.StimType(1:length(Triggers.Stim.Trial));
%             Behav.RespType = Behav.RespType(1:length(Triggers.Stim.Trial));
%             Behav.RespVerid = Behav.RespVerid(1:length(Triggers.Stim.Trial));
%             Behav.Trial = Behav.Trial(1:length(Triggers.Stim.Trial));
%         end
    end
    
    if Config.MapBehav
        [Triggers.Resp.Trial, Triggers.Resp.Ts] = support_createTriggerVecResp(Triggers.Stim.Trial, Triggers.Stim.Ts, Behav.Trial, Behav.RT);
        
        if DEVMODE && ~isnan(Config.ManShiftMs) && isnumeric(Config.ManShiftMs) && Config.ManShiftMs~=0
            log_w('MANUALLY SHIFTED RESPONSE TIMESTAMPS');
            Triggers.Resp.Ts = Triggers.Resp.Ts + Config.ManShiftMs*1000;
        end
    end
    
    % --------------------------------------------------
    % DATA QUALITY SECTION

    if(strcmp(Config.ETDataFormat, 'PupilEXT'))
        log_i(['Rejecting Samples upon pupil detection confidence criteria: ']);
        log_i([sprintf('\t') 'Confidence < ' num2str( confidenceThreshold )]);
        log_i([sprintf('\t') 'Outline Confidence < ' num2str( outlineConfidenceThreshold )]);
        [Samples.Ts, Samples.Pupdil, Samples.QualityValues.Conf, Samples.QualityValues.OutlineConf] = DQ_RemoveSamplesByConfidence(Samples.Ts, Samples.Pupdil, Samples.QualityValues.Conf, Samples.QualityValues.OutlineConf, confidenceThreshold, outlineConfidenceThreshold);
    end

    % DEV
    if ~isnan(Samples.QualityValues.Conf)
        qualityValuesTs = Samples.Ts;
        qualityValuesConf = Samples.QualityValues.Conf;
        % resample confidence scores too, because they may be used for later analyses during TEPR calculation, etc
        [qualityValuesTs, qualityValuesConf, qualityValuesSRate] = DQ_Resample(qualityValuesTs, qualityValuesConf, Config.OutputNomSRate);
        Samples.QualityValues.Conf = qualityValuesConf;
    end
    % DEV
    
    [Samples.Ts, Samples.Pupdil] = DQ_RemoveNaNs(Samples.Ts, Samples.Pupdil);
    if Config.DQ.Zeros.Apply
        [Samples.Ts, Samples.Pupdil] = DQ_RemoveZeros(Samples.Ts, Samples.Pupdil, Config.DQ.Zeros.CutBackMs, Config.DQ.Zeros.CutForwardMs);
    end
    if Config.DQ.Blinks.Apply && sum(isnan(Blinks.StartTs)) == 0 && sum(isnan(Blinks.EndTs)) == 0
        [Samples.Ts, Samples.Pupdil] = DQ_RemoveBlinks(Samples.Ts, Samples.Pupdil, Blinks.StartTs, Blinks.EndTs, Config.DQ.Blinks.CutBackMs, Config.DQ.Blinks.CutForwardMs);
    end
    
    if(Config.DQ.Hiccups.Apply)
        log_i(['Removing hiccups']);
%         [Samples.Ts, Samples.Pupdil] = DQ_RemoveHiccups(Samples.Ts, Samples.Pupdil, floor(Samples.SRate/4), 10);
        [Samples.Ts, Samples.Pupdil] = DQ_RemoveHiccups(Samples.Ts, Samples.Pupdil, floor(Samples.SRate/Config.DQ.Hiccups.WindowLengthFactor), Config.DQ.Hiccups.Threshold);
    end

    if(Config.DQ.DistFromCentral.Apply)
        log_i(['Removing outlier samples, by their distance from central values']);
        [Samples.Ts, Samples.Pupdil] = DQ_RemoveDistFromCentral(Samples.Ts, Samples.Pupdil, Config.DQ.DistFromCentral.Method, Config.DQ.DistFromCentral.Threshold);
    end
    
    
    % DEV TEST, 2023.10.30
    %{
    if(strcmp(Config.ETDataFormat, 'PupilEXT'))
        log_i(['(DEV) Removing extreme values']);
        refy = mode(Samples.Pupdil);
        devlimsd = 3;
        mask2 = Samples.Pupdil > refy + devlimsd*std(Samples.Pupdil,'omitnan');
        mask3 = Samples.Pupdil < refy - devlimsd*std(Samples.Pupdil,'omitnan');
        markedToRemove = mask2 | mask3;
        Samples.Pupdil = Samples.Pupdil(~markedToRemove);
        Samples.Ts = Samples.Ts(~markedToRemove);
    end
    
    if(strcmp(Config.ETDataFormat, 'PupilEXT'))
        log_i(['(DEV) Lowpass filtering to remove noise']);
        Samples.Pupdil = lowpass(Samples.Pupdil, 3, Samples.SRate); 
    end
    %}
    
    [Samples.interpol_ratio] = DQ_CalcInterpLossAnalogWhole(Samples.Ts, Samples.SRate, Triggers.Stim.Trial, Triggers.Stim.Ts, ISISec, StimOnScreenSec);
    MeanInterpolRatio(ppnr, 1) = Samples.interpol_ratio;

    % ANALOG VERSION
    % There is no "interpolation ratio" generated here, but it is generated
    % on-demand, if needed for event-related processing
    % That is why we have stored the timestamps of ground truth Samples used
    % for interpolation in this vector:
    Samples.OrigSamplesTs = Samples.Ts;
    
    [Samples.Ts, Samples.Pupdil, Samples.SRate] = DQ_Resample(Samples.Ts, Samples.Pupdil, Samples.SRate);
    
    if PerformGolayFiltering && ~isnan(GolayWinSizeFactor) && isnumeric(GolayWinSizeFactor) && GolayWinSizeFactor>0
        golay_winlen = floor(Samples.SRate*GolayWinSizeFactor);
        if mod(golay_winlen, 2) == 0
            golay_winlen = golay_winlen + 1;
        end
        Samples.Pupdil = sgolayfilt(Samples.Pupdil, 5, golay_winlen); % 3, 11
    end

    % TODO: why here?
    [Samples.Ts, Samples.Pupdil, Samples.SRate] = DQ_Resample(Samples.Ts, Samples.Pupdil, Config.OutputNomSRate); % Config.OutputNomSRate

    % DEV: check
% % %     disp(sum(~(qualityValuesTs == Samples.Ts)));
% % % 
% % %     disp(qualityValuesSRate = Samples.SRate);
    % DEV
    
    log_i(['Sample Rate after decimation in data quality step: ' num2str(Samples.SRate)]);
    log_i(['Length of recording in seconds, after data quality step: ' num2str( (Samples.Ts(length(Samples.Ts))-Samples.Ts(1))/1000/1000 )]);
    
    if isnan(Meta.NomSRate)
        log_i(['No predefined nominal sampling rate was defined for metafile. Using the one first found. Namely ' num2str(Samples.SRate)]);
        Meta.NomSRate = round(Samples.SRate);
    else
        log_i(['Nominal sampling rate is already defined.']);
        if round(Meta.NomSRate) == round(Samples.SRate)
            log_i(['    Current eye data file complies with it.']);
        else
            log_e(['    Current eye data file does not comply with it.']);
        end
    end

    % ANALOG VERSION
    % There is no "interpolation ratio" generated here, but it is generated
    % on-demand, if needed for event-related processing
    % That is why we have stored the timestamps of ground truth Samples used
    % for interpolation

    Config.FilterTrialsRenum = Config.FilterTrials;
%     [Samples.Trial] = renumberTrials(Samples.Trial, Config.FilterTrials, Config.EveryWhichTrial);
    Config.FilterTrialsRenum(2) = ceil((Config.FilterTrialsRenum(2)-Config.FilterTrialsRenum(1) + 1)/Config.EveryWhichTrial);
    Config.FilterTrialsRenum(1) = 1;
    Config.FilterTrials_original = Config.FilterTrials;
    if sum(isnan(Meta.FilterTrials)) > 0
        Meta.FilterTrials = Config.FilterTrialsRenum;
        log_d(['Re-setting Meta.FilterTrials']);
    end
    if Meta.FilterTrials(1) ~= Config.FilterTrialsRenum(1) || Meta.FilterTrials(2) ~= Config.FilterTrialsRenum(2)
        log_e(['Current and defined common meta (renumbered and aligned) Config.FilterTrials do not match.']);
    end

    % --------------------------------------------------
    % CHECKS (TODO)
    % ...
    
    % --------------------------------------------------
    % PLOTTING 1 (DEV, only for debug, not saved as image files)
    if Config.PlotPupil.Enabled 
        support_PlotPupilData(Config.PlotPupil.Mode, Samples);
    end

    % --------------------------------------------------
    % PERFORM SPECTRAL FILTERING
        
    if Config.HarFilt.Enabled
        Samples.Pupdil = support_PerformHarFilt(Config, Samples);
    end
    
    % --------------------------------------------------
    % PLOTTING 2 (DEV, only for debug, not saved as image files)
    
    % TODO: not simple before-after show figure, but plot them on one plot,
    % and also save them in needed
    if Config.PlotPupil.Enabled 
        support_PlotPupilData(Config.PlotPupil.Mode, Samples);
    end

    % --------------------------------------------------
    % EXTRA (DEV)
    [Samples.TrialwiseInterpolPercentages_fromVBLToStimOnset, Samples.TrialwiseInterpolPercentages_fromStimOnsetToStimOffset] = ...
        support_calcInterpolPercentagesVBL(Samples.Ts, Samples.OrigSamplesTs, Triggers.Stim.Ts, Triggers.VBL.Ts, ISISec, StimOnScreenSec, Samples.SRate, Samples.OrigSRate);
    %
    TrialwiseMeanInterpolPercentage_fromVBLToStimOnset(ppnr, 1) = mean(Samples.TrialwiseInterpolPercentages_fromVBLToStimOnset);
    TrialwiseSDInterpolPercentage_fromVBLToStimOnset(ppnr, 1) = std(Samples.TrialwiseInterpolPercentages_fromVBLToStimOnset);
    TrialwiseMeanInterpolPercentage_fromStimOnsetToStimOffset(ppnr, 1) = mean(Samples.TrialwiseInterpolPercentages_fromStimOnsetToStimOffset);
    TrialwiseSDInterpolPercentage_fromStimOnsetToStimOffset(ppnr, 1) = std(Samples.TrialwiseInterpolPercentages_fromStimOnsetToStimOffset);
    
    log_d(['Interp. percent (trialwise timestamps, VBL to Stim Onset): M: ' num2str(mean(Samples.TrialwiseInterpolPercentages_fromVBLToStimOnset)) ' %; SD: ' num2str(std(Samples.TrialwiseInterpolPercentages_fromVBLToStimOnset)) ])
    log_d(['Interp. percent (trialwise timestamps, Stim Onset to Stim Offset): M: ' num2str(mean(Samples.TrialwiseInterpolPercentages_fromStimOnsetToStimOffset)) ' %; SD: ' num2str(std(Samples.TrialwiseInterpolPercentages_fromStimOnsetToStimOffset)) ])

    % --------------------------------------------------
    % SAVING SPECIFIC .mat FILES
    outFileName = char(Participants(ppnr));
    
    % TODO: wipe folder contents if folder exists already

    % save them as v7 .mat files so that SciPy can open them if needed
    save([OutFilePath outFileName '.mat'], 'Samples', 'Behav', 'Blinks', 'Saccades', 'Triggers', '-v7');
    % NOTE: it can happen that behav data (resp type, stim type, etc) are
    % not saved as strings. We need conversion in this case. Take care
    
    clearvars Samples Behav Blinks Saccades Triggers;
end

% --------------------------------------------------
% SAVING COMMON METAFILE

OutFilePath = ['~PREPDATA/' Meta.RootDirTag '/'];
if ~exist(OutFilePath, 'dir')
    mkdir(OutFilePath);
end
outFileName = 'Metafile';
save([OutFilePath outFileName '.mat'], '-struct', 'Meta' );

% --------------------------------------------------
% SAVING SUMMARY STATISTICS

col_participants = transpose([{ [Meta.CfPrefix '_' 'Participant'] }  Participants]);
cols_sub_vals = cell(length(Participants)+1, 5);
cols_sub_vals(1, 1) = { [Meta.CfPrefix '_' 'Recording interp [%]']};
cols_sub_vals(1, 2) = { [Meta.CfPrefix '_' 'Mean of Trialwise interp fromVBLToStimOnset[%]']};
cols_sub_vals(1, 3) = { [Meta.CfPrefix '_' 'SD of Trialwise interp fromVBLToStimOnset[%]']};
cols_sub_vals(1, 4) = { [Meta.CfPrefix '_' 'Mean of Trialwise interp fromStimOnsetToStimOffset[%]']};
cols_sub_vals(1, 5) = { [Meta.CfPrefix '_' 'SD of Trialwise interp fromStimOnsetToStimOffset[%]']};
cols_sub_vals(2:length(Participants)+1, 1) = num2cell(MeanInterpolRatio*100);
cols_sub_vals(2:length(Participants)+1, 2) = num2cell(TrialwiseMeanInterpolPercentage_fromVBLToStimOnset);
cols_sub_vals(2:length(Participants)+1, 3) = num2cell(TrialwiseSDInterpolPercentage_fromVBLToStimOnset);
cols_sub_vals(2:length(Participants)+1, 4) = num2cell(TrialwiseMeanInterpolPercentage_fromStimOnsetToStimOffset);
cols_sub_vals(2:length(Participants)+1, 5) = num2cell(TrialwiseSDInterpolPercentage_fromStimOnsetToStimOffset);
outputMatrix = [col_participants cols_sub_vals];
OutFilePath = ['~RESULTS/' Meta.RootDirTag '/'];
if ~exist(OutFilePath, 'dir')
    mkdir(OutFilePath);
end
outFileName = [ Meta.CfPrefix '_' 'Preproc interpolation percentages' ];

writecell(outputMatrix,[OutFilePath outFileName '.csv'],'Delimiter',';');

