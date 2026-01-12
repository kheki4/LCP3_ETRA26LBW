if ~exist('FLAG_GRANDCALC', 'var') || ~FLAG_GRANDCALC
    clear; % clear env
    clc; % clear command window
    Config.Plots.Layered = false;
    Config.Plots.LayeredFigCounter = 1;
else
    Config.Plots.Layered = true;
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

% Initializing defaults (must happen here)
CONFIG_TEPR_DEFAULTS

CONFIG_TEPR_PLR_LUND

% --------------------------------------------------
% PREPARE VARIABLES

Meta = load(['~PREPDATA/' Config.ETDSDirName '/' 'Metafile' '.mat']);

if ~isempty(Config.RootDirTagSuffix)
    Meta.RootDirTag = [Meta.RootDirTag Config.RootDirTagSuffix];
    disp(['Root Dir Tag Suffix used: ' Config.RootDirTagSuffix]);
end

if DEVMODE
    Meta.RootDirTag = [Meta.RootDirTag '_DEV'];
    disp('RUNNING IN DEVELOPER MODE');
end

Participants = support_FindParticipantsByFiles(Config, true);
NumParticipants = size(Participants,2);

if isnan(Config.Plot.GrandTEPR.XLim)
    Config.Plot.GrandTEPR.XLim = [Config.AnalyzeFromSec*1000 Config.AnalyzeToSec*1000];
end
if Config.Plot.GrandTEPR.Make && sum(isnan(Config.Plot.GrandTEPR.YLim)) == 0
    log_w('No Y limit defined for Grand TEPR plot generation. Every participant will have different scaling accordingly.');
end

if isnan(Config.Plot.TEPR.XLim)
    Config.Plot.TEPR.XLim = [Config.AnalyzeFromSec*1000 Config.AnalyzeToSec*1000];
end
if Config.Plot.TEPR.Make && sum(isnan(Config.Plot.TEPR.YLim)) == 0
    log_w('No Y limit defined for TEPR plot generation. Every participant will have different scaling accordingly.');
end

% --------------------------------------------------
% PREPARE EXPERIMENT-SPECIFIC VARIABLES 

ERAEventDensity_grand = [];

% To avoid cases when e.g. the stimulus presented software lagged a bit during a trial. But only when each trial was the same long. Can be disabled
if ~isnan(RejectTrialsOutsideLenSec) && length(RejectTrialsOutsideLenSec) == 2 && sum(isnan(RejectTrialsOutsideLenSec))==0 && RejectTrialsOutsideLenSec(1) >= 0.1 && RejectTrialsOutsideLenSec(2) <= 10*60
    RejectTrialsUnderSec = RejectTrialsOutsideLenSec(1);
    RejectTrialsOverSec = RejectTrialsOutsideLenSec(2);
else
    RejectTrialsUnderSec = Meta.ISISec -0.2;
    RejectTrialsOverSec = Meta.ISISec +0.2;
end

Config.SRate = Meta.NomSRate;
% Needed for calculations:
Config.FixBeforeStimSec = Meta.ISISec -Meta.StimOnScreenSec;
Config.AnalyzeLenSec = Config.AnalyzeToSec -Config.AnalyzeFromSec;

% Relative to x=0 line depending on sign, can be negative (+1 for Matlab indexing):
Config.AnalyzeFromSample = round(Meta.NomSRate *Config.AnalyzeFromSec) +1;
Config.AnalyzeToSample = round(Meta.NomSRate *Config.AnalyzeToSec) +1;
Config.PeakFromSample = round(Meta.NomSRate *Config.PeakFromSec) +1;
Config.PeakToSample = round(Meta.NomSRate *Config.PeakToSec) +1;
Config.BaselineFromSample = round(Meta.NomSRate *Config.BaselineFromSec) +1;
Config.BaselineToSample = round(Meta.NomSRate *Config.BaselineToSec) +1;

if isnan(Config.ERL.FromSec)
    Config.ERL.FromSec = 0;
end
if isnan(Config.ERL.ToSec)
    Config.ERL.ToSec = Config.PeakToSec;
end
Config.ERL.FromSample = round(Meta.NomSRate *Config.ERL.FromSec) +1;
Config.ERL.ToSample = round(Meta.NomSRate *Config.ERL.ToSec) +1;

% Mapped sample values, can be used for indexing the event-related curve
Config.PeakFromSampleMapped = (-1*Config.AnalyzeFromSample) +Config.PeakFromSample +1;
Config.PeakToSampleMapped = (-1*Config.AnalyzeFromSample) +Config.PeakToSample;
Config.BaselineFromSampleMapped = (-1*Config.AnalyzeFromSample) +Config.BaselineFromSample +1;
Config.BaselineToSampleMapped = (-1*Config.AnalyzeFromSample) +Config.BaselineToSample;

% Can only be positive:
Config.ISISec = Meta.StimOnScreenSec;
Config.ISISec = Config.FixBeforeStimSec;
Config.ISISec = Meta.ISISec;

Config.StimOnScreenSample = round( Meta.NomSRate *Meta.StimOnScreenSec);
Config.FixBeforeStimSample = round( Meta.NomSRate *Config.FixBeforeStimSec);
Config.ISISample = round(Meta.NomSRate *Meta.ISISec);
Config.AnalyzeLenSample = round(Meta.NomSRate *Config.AnalyzeLenSec) +1; % We store data at 0th elem too

NumTrials = Meta.NumTrials;

RejectTrialsUnderLen = floor(RejectTrialsUnderSec * Meta.NomSRate);
RejectTrialsOverLen = floor(RejectTrialsOverSec * Meta.NomSRate);
log_i([ 'Rejecting trials under typical length: ' num2str(RejectTrialsUnderSec) ' sec (= ' num2str(RejectTrialsUnderLen) ' data points)' ]);
log_i([ 'Rejecting trials over typical length: ' num2str(RejectTrialsOverSec) ' sec (= ' num2str(RejectTrialsOverLen) ' data points)' ]);

Config.Filter.Behav.S = '~';
Config.Filter.Behav.R = '~';
Config.Filter.Behav.V = '~';
Config.Filter.Behav.FriendlyName = 'All Trials';

if Config.Save.BaselineValues
    BaselineValuesEveryTrial = NaN(NumParticipants, NumTrials);
    BaselineValues = NaN(NumParticipants, 1);
end

if Config.ERL.Enabled
    ERLEveryTrial = NaN(NumParticipants, NumTrials);
    ERLVEveryTrial = NaN(NumParticipants, NumTrials);
    ERL = NaN(NumParticipants, 1);
    ERLV = NaN(NumParticipants, 1);
end

Filter.SD.PercentFiltered = zeros(NumParticipants, 1);
Config.Filter.Behav.PercentFiltered = zeros(NumParticipants, 1);
Filter.Interpol.PercentFiltered = zeros(NumParticipants, 1);
Filter.BaselineBlink.PercentFiltered = zeros(NumParticipants, 1);
Filter.BaselineSaccade.PercentFiltered = zeros(NumParticipants, 1);
Filter.SOIBlink.PercentFiltered = zeros(NumParticipants, 1);
Filter.SOISaccade.PercentFiltered = zeros(NumParticipants, 1);

TEPRCurves = NaN(Config.AnalyzeLenSample, NumParticipants);
PeakValues = NaN(NumParticipants, 1);
ERL = NaN(NumParticipants, 1);
TRIAL_EXCLUSIONS = NaN(NumParticipants, 9);
TEPREveryParticipant = NaN( NumParticipants, Config.AnalyzeLenSample );
TIMECOURSE_BRUTE = NaN( NumParticipants, Config.AnalyzeLenSample );

% --------------------------------------------------
% LOOP TO PROCESS PARTICIPANTS

for ppnr = 1:NumParticipants % DEV % 16-os indexu a 298-as
    
    Participant.ID = Participants{ppnr};
    Participant.Nr = ppnr;

    log_i('--------------------------------------------------');
    log_i(['Currently processing ' char(Participant.ID) ' at index ' num2str(Participant.Nr)]);
    
    % --------------------------------------------------
    % LOAD DATA
    
    load(['~PREPDATA/' Config.ETDSDirName '/' Participant.ID '.mat']);

    % Samples.Pupdil = Samples.Pupdil(randperm(length(Samples.Pupdil)));
    
    if round(Samples.SRate) ~= Meta.NomSRate
        log_w(['~Samples file SRate does not equal to the nominal sampling rate stated in Metafile. Please check preprocessor code and ensure data consistency.']);
    end
    
    % --------------------------------------------------
    % PREPARE SUBEJCT-SPECIFIC VARIABLES
    
    RejectedTrials = false(NumTrials, 1); 
    excludedTrials = false(NumTrials, 1); % this will contain the unified mask from all filters AND also the RejectedTrials mask
    Filter.Interpol.ExcludedMask = false(NumTrials, 1);
    Config.Filter.Behav.ExcludedMask = false(NumTrials, 1);
    
    % --------------------------------------------------
    % SELECTING TIMESTAMPS FOR INTER-TRIAL ALIGNMENT
    
    if Config.AlignToStimOrResp
        TrigsForAlignment = Triggers.Stim.Ts;
        TrigsForAlignmentVBL = Triggers.VBL.Ts;
    else
        % TODO: check if exists
        TrigsForAlignment = Triggers.Resp.Ts;
    end
    
    % --------------------------------------------------
    % REJECT CERTAIN TRIALS FROM ANY PROCESSING
    
    if ~isempty(Config.RejectTrials)
        RejectedTrials(Config.RejectTrials) = true;
    end

    for v = 1:NumTrials
        % DEV: NOTE: no checks implemented yet for variable-baselines (VBL) using TrigsForAlignmentVBL

        % E.g. when we are making a response-aligned analysis, and the subject has no response in a trial
        if isnan(TrigsForAlignment(v))
            RejectedTrials(v) = true;
            continue;
        end

        % Skip first N trials if necessary (e.g. when there was no separate practice block)
        if v <= Config.SkipFirstNtrials
            RejectedTrials(v) = true;
            continue;
        end

        % Only include the said trial section (rejection is exclusive, so
        % the mentioned trials will still be kept). If the specified trial
        % window does not overlap with Config.SkipFirstNtrials, the first N
        % trials will still be kept.
        if all(~isnan(Config.RejectTrialsExceptExclusive)) && length(Config.RejectTrialsExceptExclusive) == 2 && ...
            ~isempty(Config.RejectTrialsExceptExclusive) && ...
            (v < Config.RejectTrialsExceptExclusive(1) || v > Config.RejectTrialsExceptExclusive(2))

            RejectedTrials(v) = true;
            continue;
        end

        % Only include the said trial section (rejection is exclusive, so
        % the mentioned trials will still be kept). First N trials will be
        % also rejected within this section.
        if all(~isnan(Config.RejectTrialsExceptExclusiveWithSkipFirstN)) && length(Config.RejectTrialsExceptExclusiveWithSkipFirstN) == 2 && ...
            ~isempty(Config.RejectTrialsExceptExclusiveWithSkipFirstN) && ...
            (v < (Config.RejectTrialsExceptExclusiveWithSkipFirstN(1) + Config.SkipFirstNtrials) || v > Config.RejectTrialsExceptExclusiveWithSkipFirstN(2))

            RejectedTrials(v) = true;
            continue;
        end

        % Reject specific trials if necessary (e.g. when there was no separate practice block, 
        %  or at the beginning of each block there are practice trials)
        if ismember(v, Config.RejectSpecificTrials)
            RejectedTrials(v) = true;
            continue;
        end

        % NOTE: only whole trials are taken into averaging. Analytic time length setting affects this
        if ( length(Samples.Pupdil) - find(Samples.Ts >= TrigsForAlignment(v), 1, 'first') ) < Config.AnalyzeLenSample
            RejectedTrials(v) = true;
            continue;
        end

        if Config.AlignToStimOrResp == false && isnan(Behav.RT(v)) % EKKOR RESPONSE-HOZ IGAZÍTUNK. HA NINCS RESPONSE, REJECT TRIAL
            RejectedTrials(v) = true;
            continue;
        end

        % reject trials that would later break the pipeline because their analyzed period begins earlier than the first sample, or later than the last
        if ( length(TrigsForAlignment) > v && ...
                ( find(Samples.Ts >= TrigsForAlignment(v), 1, 'first')) + Config.AnalyzeFromSample < 1 || ...
                (find(Samples.Ts >= TrigsForAlignment(v), 1, 'first') + Config.AnalyzeLenSample > length(Samples.Ts) ) ) 

            RejectedTrials(v) = true;
            continue;
        end
        
        % reject trials that would later break the pipeline because their VBL analyzed period begins earlier than the first sample, or later than the last
        if ( Config.UseVBL && ...
                length(TrigsForAlignmentVBL) > v && ...
                ( ...
                    Samples.Ts(1) > TrigsForAlignmentVBL(v) || ...
                    Samples.Ts(end) < TrigsForAlignmentVBL(v) || ...
                    any((find(Samples.Ts >= TrigsForAlignmentVBL(v), 1, 'first')) + Config.AnalyzeFromSample < 1) || ...
                    any(find(Samples.Ts >= TrigsForAlignmentVBL(v), 1, 'first') + Config.AnalyzeLenSample > length(Samples.Ts)) ...
                )) 

            RejectedTrials(v) = true;
            continue;
        end

        % only in case we are in a stimulus-aligned analysis
        % NOTE: can be buggy, disable if needed
        if RejectTrialsOnTypicalLen && ...
                Config.AlignToStimOrResp == true && ( length(TrigsForAlignment) > v && ...
                ( (find(Samples.Ts >= TrigsForAlignment(v+1), 1, 'first') - find(Samples.Ts >= TrigsForAlignment(v), 1, 'first')) < RejectTrialsUnderLen || ...
                (find(Samples.Ts >= TrigsForAlignment(v+1), 1, 'first') - find(Samples.Ts >= TrigsForAlignment(v), 1, 'first')) > RejectTrialsOverLen ) ) || ...
                ( length(TrigsForAlignment) == v && (length(Samples.Ts) - find(Samples.Ts >= TrigsForAlignment(v), 1, 'first') < RejectTrialsUnderLen) )
            RejectedTrials(v) = true;
            continue;
        end

    end

    log_d('See list of rejected trials by trial number:')
    log_d(num2str(transpose(find(RejectedTrials==1))));

    % --------------------------------------------------
    % SPLIT SIGNAL INTO SEGMENTS (aka SWEEPS or TRIALS)
    
    [TrialsArray, ConfsArray] = support_SplitIntoSweeps(Samples, ~RejectedTrials, TrigsForAlignment, Config, Config.PerformTJC);

    [VBLsArray, VBLsConfsArray] = support_SplitIntoSweeps(Samples, ~RejectedTrials, TrigsForAlignmentVBL, Config, Config.PerformTJC);
    clear VBLsConfsArray;
    
    % --------------------------------------------------
    % WITHIN-TRIAL PROCESSING

    % DISREGARD SPECIFIC SECTIONS OF SPECIFIC TRIALS IF NECESSARY
    if ~isempty(Config.DisregardTrialSections)
        TrialsArray = support_DisregardTrialSections(TrialsArray, Config, Meta); 
    end

    if Config.DisregardTrialSectionsOnBehav
        TrialsArray = feval(Config.DisregardTrialSectionsOnBehavFunction, TrialsArray, Config, Meta, Participant);
    end
    
    % Z-NORMALIZATION
    if Config.Z_norm_method ~= 0
        TrialsArray = support_ZNormSweeps(Samples, TrialsArray, ~RejectedTrials, Config.Z_norm_method);
    else
        log_i('Using no Z-normalization now');
    end
    
    % --------------------------------------------------
    % BETWEEN-TRIALS FILTERING
    
    % FILTERING ON STIMULUS//RESPONSE CATEGORY
    if Config.Filter.Behav.Enabled
        
        if ~isfield(Config.Filter.Behav, 'CondComb')
            Config.Filter.Behav.CondComb = 1;
            
            log_i('No Config.Filter.Behav.CondComb specified');
        end

        [Config.Filter.Behav, Config.Plot.GrandTEPR] = feval(Config.BehavInitFunction, Config.Filter.Behav, Config.Plot.GrandTEPR);
        Config.Filter.Behav.ExcludedMask = feval(Config.BehavFiltFunction, NumTrials, Behav, Config.Filter.Behav, RejectedTrials);
        
    end
    %----------------------------------------------------------------------------------------------------------------


    % MAKING EXCLUDED MASKS FOR COND-COMPUTED TEPR CURVE, FILTERING ON STIMULUS//RESPONSE CATEGORY
    % e.g. when: (individual TEPR) = (TEPR of all trials) - (TEPR of false alarms)
    % ---------------------------------------------------------------------------------------------------------------
    if Config.CC.Enabled

        Config.CC.ExcludedMasks = false(NumTrials, length(Config.CC.Conds));

        LocalFilterConfig.StimType.A = Config.Filter.Behav.StimType.A;
        LocalFilterConfig.StimType.B = Config.Filter.Behav.StimType.B;
        LocalFilterConfig.RespType.A = Config.Filter.Behav.RespType.A;
        LocalFilterConfig.RespType.B = Config.Filter.Behav.RespType.B;
        % TODO: A BETTER SOLUTION

        for cx=1:length(Config.CC.Conds)
            LocalFilterConfig.CondComb = Config.CC.Conds(cx);
            Config.CC.ExcludedMasks(:, cx) = callable_behavfilt_NBACK(NumTrials, Behav, LocalFilterConfig, RejectedTrials);
        end
        
    end
    %----------------------------------------------------------------------------------------------------------------
    
    if Config.Filter.Interpol.Enabled
        log_i(['Excluding trials whose interpolation percentage is greater than ' num2str(Config.Filter.Interpol.Threshold)]);
        [Filter.Interpol.ExcludedMask, InterpolPercentages] = FiltSweepsOnInterpolVBL(Samples, ~RejectedTrials, TrigsForAlignment, Triggers.VBL.Ts, Meta.ISISec, Config.Filter.Interpol);
    end
    if Config.Filter.SD.Enabled
        log_d(['SD of whole recording: ' num2str(std( Samples.Pupdil , 'omitnan'))]);
        log_d(['SD of all existing trials: ' num2str(std( reshape(TrialsArray(:,1:NumTrials),1,[]) , 'omitnan'))]);
        log_d(['SD of all non-rejected trials: ' num2str(std( reshape(TrialsArray(:,~RejectedTrials),1,[]) , 'omitnan'))]);
        log_i(['Excluding trials whose SD is greater than ' num2str(Config.Filter.SD.LocalLimit)]);
        Filter.SD.ExcludedMask = FiltSweepsOnSD(TrialsArray, ~RejectedTrials, Filter.Config.SD);
    end
    if Config.Filter.BaselineBlink.Enabled
        log_i(['Excluding trials whose baseline-correction-period (BLP) would either contain a blink start, or blink end, or would completely fall within a blink']);
        if Config.UseVBL
            Filter.BaselineBlink.ExcludedMask = FiltSweepsOnBlink(Blinks, ~RejectedTrials, TrigsForAlignmentVBL, Config.Filter.BaselineBlink);
        else
            Filter.BaselineBlink.ExcludedMask = FiltSweepsOnBlink(Blinks, ~RejectedTrials, TrigsForAlignment, Config.Filter.BaselineBlink);
        end
    end
    if Config.Filter.BaselineSaccade.Enabled
        log_i(['Excluding trials whose baseline-correction-period (BLP) would contain a saccade']);
        if Config.UseVBL
            Filter.BaselineSaccade.ExcludedMask = FiltSweepsOnSaccade(Saccades, ~RejectedTrials, TrigsForAlignmentVBL, Config.Filter.BaselineSaccade);
        else
            Filter.BaselineSaccade.ExcludedMask = FiltSweepsOnSaccade(Saccades, ~RejectedTrials, TrigsForAlignment, Config.Filter.BaselineSaccade);
        end
    end
    if Config.Filter.SOIBlink.Enabled
        log_i(['Excluding trials whose time-section-of-interest (SOI) would either contain a blink start, or blink end, or would completely fall within a blink']);
        Filter.SOIBlink.ExcludedMask = FiltSweepsOnBlink(Blinks, ~RejectedTrials, TrigsForAlignment, Config.Filter.SOIBlink);
    end
    if Config.Filter.SOISaccade.Enabled
        log_i(['Excluding trials whose time-section-of-interest (SOI) would contain a saccade']);
        Filter.SOISaccade.ExcludedMask = FiltSweepsOnSaccade(Saccades, ~RejectedTrials, TrigsForAlignment, Config.Filter.SOISaccade);
    end


   
    
    % TODO: somehow put this in a loop? e.g. with function handles?
    log_i([ 'Proportion of trials rejected: ' num2str( sum(RejectedTrials)/(NumTrials) *100 ) '%' ]);
    if Config.Filter.Interpol.Enabled
        Filter.Interpol.PercentFiltered(Participant.Nr, 1) = sum(Filter.Interpol.ExcludedMask)/(NumTrials) *100;
        log_i([ 'Proportion of trials excluded on within-trial interpolation percentage: ' num2str( Filter.Interpol.PercentFiltered(Participant.Nr, 1) ) '%' ]);
    end
    if Config.Filter.BaselineBlink.Enabled
        Filter.BaselineBlink.PercentFiltered(Participant.Nr, 1) = sum(Filter.BaselineBlink.ExcludedMask)/(NumTrials) *100;
        log_i([ 'Proportion of trials excluded on blink-affected baseline interval: ' num2str( Filter.BaselineBlink.PercentFiltered(Participant.Nr, 1) ) '%' ]);
    end
    if Config.Filter.BaselineSaccade.Enabled
        Filter.BaselineSaccade.PercentFiltered(Participant.Nr, 1) = sum(Filter.BaselineSaccade.ExcludedMask)/(NumTrials) *100;
        log_i([ 'Proportion of trials excluded on saccade-affected baseline interval: ' num2str( Filter.BaselineSaccade.PercentFiltered(Participant.Nr, 1) ) '%' ]);
    end
    if Config.Filter.SOIBlink.Enabled
        Filter.SOIBlink.PercentFiltered(Participant.Nr, 1) = sum(Filter.SOIBlink.ExcludedMask)/(NumTrials) *100;
        log_i([ 'Proportion of trials excluded on blink-affected time-section of interest (SOI): ' num2str( Filter.SOIBlink.PercentFiltered(Participant.Nr, 1) ) '%' ]);
    end
    if Config.Filter.SOISaccade.Enabled
        Filter.SOISaccade.PercentFiltered(Participant.Nr, 1) = sum(Filter.SOISaccade.ExcludedMask)/(NumTrials) *100;
        log_i([ 'Proportion of trials excluded on saccade-affected time-section of interest (SOI): ' num2str( Filter.SOISaccade.PercentFiltered(Participant.Nr, 1) ) '%' ]);
    end
    if Config.Filter.SD.Enabled
        Filter.SD.PercentFiltered(Participant.Nr, 1) = sum(Filter.SD.ExcludedMask)/(NumTrials) *100;
        log_i([ 'Proportion of trials excluded on SD: ' num2str( Filter.SD.PercentFiltered(Participant.Nr, 1) ) '%' ]);
    end
    if Config.Filter.Behav.Enabled
        Config.Filter.Behav.PercentFiltered(Participant.Nr, 1) = sum(Config.Filter.Behav.ExcludedMask)/(NumTrials) *100;
        log_i([ 'Proportion of trials excluded on behav logfile (Stim or Resp category) (all components): ' num2str( Config.Filter.Behav.PercentFiltered(Participant.Nr, 1) ) '%' ]);
    end
    
    % Unify binary masks of filters
    % TODO: no loop (but then we cannot check for filters enabled flags)
    for i = 1:NumTrials
        
        if RejectedTrials(i) || ...
                (Config.Filter.Interpol.Enabled && Filter.Interpol.ExcludedMask(i)) || ...
                (Config.Filter.BaselineBlink.Enabled && Filter.BaselineBlink.ExcludedMask(i)) || ...
                (Config.Filter.BaselineSaccade.Enabled && Filter.BaselineSaccade.ExcludedMask(i)) || ...
                (Config.Filter.SOIBlink.Enabled && Filter.SOIBlink.ExcludedMask(i)) || ...
                (Config.Filter.SOISaccade.Enabled && Filter.SOISaccade.ExcludedMask(i)) || ...
                (Config.Filter.SD.Enabled && Filter.SD.ExcludedMask(i)) || ...
                (Config.Filter.Behav.Enabled && Config.Filter.Behav.ExcludedMask(i) )
            excludedTrials(i) = true;
        end
        
    end
    
    % --------------------------------------------------
    % EVENT-RELATED ARTEFACTS CALCULATION
    
    if Config.ERA.Enabled % event-related artefacts (event-related blink curve & event-related saccades curve)
        
        % TODO: Put Sample, Blinks, Saccades in a structure, and keep them NaN if empty
        % TODO: beutify
        % TODO: in case of KDE resample to be equally long as analyticlen, so that we can make Dyn BL corr maps with it
        ERAEventDensity = support_CalcERADensity(Samples, Blinks, Saccades, ~RejectedTrials, TrigsForAlignment, Config);
        
        % TODO: 
        if ~isempty(ERAEventDensity)
            ERAEventDensity_grand = [ERAEventDensity_grand; ERAEventDensity];
        end
    end
    
    % --------------------------------
    
    % DEV eventRelatedAmpEq
    eventRelatedAmpEq = true;
    
    if ~Config.CC.Enabled && eventRelatedAmpEq
        
        if exist('eventRelatedAmpEq1_lastRun', 'var')
            excludedTrials = support_restrictMaskToNumVals(excludedTrials, eventRelatedAmpEq1_lastRun, false, 2);
        end

        Config.CC.TrialsArray_cond1 = TrialsArray;
        Config.CC.TrialsArray_cond1(:, excludedTrials ) = NaN;

        eventRelatedAmpEq1(1,Participant.Nr) = sum(~isnan(mean(Config.CC.TrialsArray_cond1, 1, 'omitnan')),'omitnan');
        log_d(['Cond-Computed TEPR calc: Num.trials finally taken into averaging for Cond.1 = ' num2str(eventRelatedAmpEq1(1,Participant.Nr))]);
    end
    
    % --------------------------------
    
    log_i([ 'Proportion of all rejected & excluded trials: ' num2str( sum(excludedTrials)/(NumTrials) *100 ) '%' ]);

    log_d('See list of passed trials by trial number:')
    log_d(num2str(transpose(find(excludedTrials==0))));

    % record the number of exclusions for this participant
    if Config.Filter.Interpol.Enabled
        TRIAL_EXCLUSIONS(Participant.Nr, 1) = sum(Filter.Interpol.ExcludedMask);
    end
    if Config.Filter.BaselineBlink.Enabled
        TRIAL_EXCLUSIONS(Participant.Nr, 2) = sum(Filter.BaselineBlink.ExcludedMask);
    end
    if Config.Filter.BaselineSaccade.Enabled
        TRIAL_EXCLUSIONS(Participant.Nr, 3) = sum(Filter.BaselineSaccade.ExcludedMask);
    end
    if Config.Filter.SOIBlink.Enabled
        TRIAL_EXCLUSIONS(Participant.Nr, 4) = sum(Filter.SOIBlink.ExcludedMask);
    end
    if Config.Filter.SOISaccade.Enabled
        TRIAL_EXCLUSIONS(Participant.Nr, 5) = sum(Filter.SOISaccade.ExcludedMask);
    end
    if Config.Filter.SD.Enabled
        TRIAL_EXCLUSIONS(Participant.Nr, 6) = sum(Filter.SD.ExcludedMask);
    end
    if Config.Filter.Behav.Enabled
        TRIAL_EXCLUSIONS(Participant.Nr, 7) = sum(Config.Filter.Behav.ExcludedMask);
    end
    TRIAL_EXCLUSIONS(Participant.Nr, 8) = sum(RejectedTrials); % rejected
    TRIAL_EXCLUSIONS(Participant.Nr, 9) = sum(~excludedTrials); % passed

    % filter using the final mask
    TrialsArray(:, excludedTrials) = NaN;
    ConfsArray(:, excludedTrials) = NaN;
    
    
    % --------------------------------------------------
    % PEAK VALUES COMPUTATION
    
    if Config.BLC == 0
        log_w('No baseline correction preformed')
    elseif Config.BLC == 1 % BLC locally
        log_i('Performing baseline correction on each trial of the participant')
        for b = 1:NumTrials
            if Config.UseVBL
                TrialsArray(:, b) = TrialsArray(:, b) - mean(VBLsArray(Config.BaselineFromSampleMapped:Config.BaselineToSampleMapped, b), 'omitnan');
            else
                TrialsArray(:, b) = TrialsArray(:, b) - mean(TrialsArray(Config.BaselineFromSampleMapped:Config.BaselineToSampleMapped, b), 'omitnan');
            end
        end
        clear b;
    end

    % DEV
    save_EventRelated_WithinSubject = false;

    if save_EventRelated_WithinSubject

        header = cell( 1, NumTrials );
        for bfc = 1:NumTrials
            % headerColStr = [ Meta.CfPrefix '_' 'Epoch' '_' num2str(bfc) ];
            headerColStr = [ 'Epoch' '_' num2str(bfc) ];
            header{1, bfc} = headerColStr;
        end

        cols_sub_vals = cell(Config.AnalyzeLenSample+1, NumTrials);
        cols_sub_vals(1, 1:NumTrials) = header;

        cols_sub_vals(2:(Config.AnalyzeLenSample+1), 1:NumTrials) = num2cell(TrialsArray);
        outputMatrix = [cols_sub_vals];

        OutFilePath = char([ ...
            '~RESULTS/' Meta.RootDirTag '/' ...
            'TEPR csv WS' '/']);
        
        if ~exist(OutFilePath, 'dir')
            mkdir(OutFilePath);
        end

        OutFileName = char([ ...
            Participant.ID '_TEPR' ...
            ' alignSR=' num2str(Config.AlignToStimOrResp) ...
            ]);
        writecell(outputMatrix ,[OutFilePath OutFileName '.csv'],'Delimiter',';');
    end
    
    % WITHIN SUBJECT baseline averages for each trial
    if Config.Save.BaselineValues
        % TODO: átgondoltabban
        if Config.UseVBL
            BaselineValuesEveryTrial(Participant.Nr,:) = mean(VBLsArray(Config.BaselineFromSampleMapped:Config.BaselineToSampleMapped,:), 1, 'omitnan');
        else
            BaselineValuesEveryTrial(Participant.Nr,:) = mean(TrialsArray(Config.BaselineFromSampleMapped:Config.BaselineToSampleMapped,:), 1, 'omitnan');
        end
    end

    % DEV:
    % COND-COMPUTED TEPR CURVE NEEDS THIS
    % e.g. when: (individual TEPR) = (TEPR of all trials) - (TEPR of false alarms)
    if Config.CC.Enabled
        % DEV NOTE: 
        % currently averaged TEPR only, and 
        % for 2 conditions only, and 
        % it is subtracted, cond 1 - cond 2
        
        if exist('eventRelatedAmpEq1_lastRun', 'var') && exist('eventRelatedAmpEq2_lastRun', 'var')
            Config.CC.ExcludedMasks(:,1) = support_restrictMaskToNumVals(Config.CC.ExcludedMasks(:,1), eventRelatedAmpEq1_lastRun, false, 2);
            Config.CC.ExcludedMasks(:,2) = support_restrictMaskToNumVals(Config.CC.ExcludedMasks(:,2), eventRelatedAmpEq2_lastRun, false, 2);
        end

        Config.CC.TrialsArray_cond1 = TrialsArray;
        Config.CC.TrialsArray_cond1(:, Config.CC.ExcludedMasks(:,1) ) = NaN;

        Config.CC.TrialsArray_cond2 = TrialsArray;
        Config.CC.TrialsArray_cond2(:, Config.CC.ExcludedMasks(:,2) ) = NaN;

        eventRelatedAmpEq1(1,Participant.Nr) = sum(~isnan(mean(Config.CC.TrialsArray_cond1, 1, 'omitnan')),'omitnan');
        eventRelatedAmpEq2(1,Participant.Nr) = sum(~isnan(mean(Config.CC.TrialsArray_cond2, 1, 'omitnan')),'omitnan');
        log_d(['Cond-Computed TEPR calc: Num.trials finally taken into averaging for Cond.1 = ' num2str(eventRelatedAmpEq1(1,Participant.Nr))]);
        log_d(['Cond-Computed TEPR calc: Num.trials finally taken into averaging for Cond.2 = ' num2str(eventRelatedAmpEq2(1,Participant.Nr))]);

    end
    
    % ERA CONFIDENCE
    if Config.ERA.Enabled
        % TODO: hibat kapunk ha az analyzefromsec-et visszabb hozzuk es nem
        % clear-elunk old-new elemzesekkor
        ERAConfCurves(:, Participant.Nr)= ...
            support_eventRelatedFunc(ConfsArray, Config.EventRelatedMethod);
    end
    % TODO: save them to csv
    
    % --------------------------------------------------
    % Calculate and store TEPR
    
    if Config.CC.Enabled
        TEPRCurves(:, Participant.Nr)= ...
            support_eventRelatedFunc(Config.CC.TrialsArray_cond1, Config.EventRelatedMethod) - ...
            support_eventRelatedFunc(Config.CC.TrialsArray_cond2, Config.EventRelatedMethod) ;
    else
        TEPRCurves(:, Participant.Nr)= ...
            support_eventRelatedFunc(TrialsArray, Config.EventRelatedMethod);
    end

    % Also keep the non-baseline-corrected data
    TEPREveryParticipant(Participant.Nr,:) = TEPRCurves(:, Participant.Nr);

    if Config.BLC == 1
        log_i('Aggregating individual, baseline corrected TEPRs to a grand curve.')
%         PeakValues(Participant.Nr, 1) = ... 
%             max(TEPRCurves(Config.PeakFromSampleMapped:Config.PeakToSampleMapped, Participant.Nr), [], 'all');
        PeakValues(Participant.Nr, 1) = ... 
            mean(TEPRCurves(Config.PeakFromSampleMapped:Config.PeakToSampleMapped, Participant.Nr), 'omitnan');
    elseif Config.BLC == 2
        log_w('Using GLOBAL BASELINE CORRECTION, at aggregation to a grand curve.')
        log_w('No variable-baseline (VBL) correction performed this way.') % NOTE: egyelőre nem akartam külön curves tömböt csinálni csak a VBL esetekre
        PeakValues(Participant.Nr, 1) = ... 
            mean(TEPRCurves(Config.PeakFromSampleMapped:Config.PeakToSampleMapped, Participant.Nr), 'omitnan') - ...
            mean(TEPRCurves(Config.BaselineFromSampleMapped:Config.BaselineToSampleMapped, Participant.Nr), 'omitnan')
    end
    
    if Config.Save.BaselineValues
        % TODO: átgondoltabban
        BaselineValues(Participant.Nr) = ...
                mean(TEPRCurves(Config.BaselineFromSampleMapped:Config.BaselineToSampleMapped, Participant.Nr), 'omitnan');
        BaselineValuesCV(Participant.Nr) = ...
                std(TEPRCurves(Config.BaselineFromSampleMapped:Config.BaselineToSampleMapped, Participant.Nr), 'omitnan') ./ ...
                mean(TEPRCurves(Config.BaselineFromSampleMapped:Config.BaselineToSampleMapped, Participant.Nr), 'omitnan');
    end

    if Config.ERL.Enabled
        % TODO: átgondoltabban
        [ERLEveryTrial(Participant.Nr, :), ERLVEveryTrial(Participant.Nr, :)] = support_CalcERL(Config, TrialsArray, Meta);
        ERL(Participant.Nr) = mean(ERLEveryTrial(Participant.Nr, :), 'omitnan');
        ERLV(Participant.Nr) = mean(ERLVEveryTrial(Participant.Nr, :), 'omitnan');
    end

    if Config.Save.EveryTrial
        % NOTE: This does not try to save the different versions according to "TEPR condComputed" behav. filter selection
        % TODO: save according to any binary mask
        % TODO: remove redundant baseline correction step
        % TODO: include variable-baseline data too (VBL) (?) 
        support_SaveEveryTrial(TrialsArray, Meta, Config, Participant);
    end
    
    if Config.Plot.TEPR.Make
        % TODO: test and beautify
        % TODO: show ERLV
        support_PlotTEPR(TrialsArray, TEPRCurves, ERLEveryTrial, Config, Meta, Participant, excludedTrials);
    end
    
    if Config.ERA.Enabled && Config.Plot.ERA.Make
        % TODO: test and beautify
        support_PlotERA(ERAEventDensity, ERAConfCurves, Config, Meta, Participant);
    end

end
% PARTICIPANT LOOP END

if Config.Plot.GrandTEPR.Make
    
    if ~isfield(Config.Plots, 'LayeredFigCounter')
        Config.Plots.LayeredFigCounter = 1;
    end
    
    % TODO: make it work with layered fig properly WHILE still keeping
    % support for everyparticipant plot
    grandTEPR(Config.Plots.LayeredFigCounter) = support_PlotGrandTEPR(TEPRCurves, Config, Meta);
%     grandTEPR(Config.Plots.LayeredFigCounter) = support_PlotGrandTEPR_coloredSections(TEPRCurves, Config, Meta);
end


% --------------------------------------------------
% PLOTTING EVENT-RELATED ARTEFACTS

% TODO: check isempty(ERAEventDensity_grand)
% TODO: save image, beautify code, extend configurability
if Config.ERA.Enabled && Config.Plot.GrandERA.Make
    support_PlotGrandERADensity(ERAEventDensity_grand, Config, Meta);
end

if Config.ERA.Enabled && Config.Plot.GrandERA.Make
    support_PlotGrandERAConf(ERAConfCurves, Config, Meta);
end

% TODO: not only plot, but save in csv
if Config.Plot.DynBLcorrMap.Make
    support_PlotDynBLCorrMap(TEPREveryParticipant, Config, Meta);

%     % DEV
%     support_PlotDynBLCorrMap(ERAConfCurves', Config, Meta);
end

if Config.Plot.TimecourseCorrel.Make
    support_PlotTimecourseCorrel(TEPREveryParticipant, Config, Meta);
end

% TODO: remove NaNs and only pass empty into csv
if Config.Save.BaselineValues
%     support_SaveBaselineValuesEveryTrial(BaselineValuesEveryTrial,Config, Meta, Participants);
    support_SaveValuesEveryTrial(BaselineValuesEveryTrial,Config, Meta, Participants, 'TEPR csv', 'PD_Baseline-values every trial');
    % % DEV
%     plot(BaselineValuesEveryTrial')
%     grid minor
    
    support_SaveBaselineValues(BaselineValues, BaselineValuesCV, BaselineValuesEveryTrial, Config, Meta, Participants); % TODO
end

% TODO: remove NaNs and only pass empty into csv
if Config.ERL.Enabled
    support_SaveValuesEveryTrial(ERLEveryTrial,Config, Meta, Participants, 'TEPR csv', 'ERL');
    support_SaveValuesEveryTrial(ERLVEveryTrial,Config, Meta, Participants, 'TEPR csv', 'ERLV');

    % TODO: save ERL not only for EveryTrial
end

% TODO: remove NaNs and only pass empty into csv
if Config.Save.PeakValues
    support_SavePeakValues(PeakValues, Config, Meta, Participants);
end

if Config.Save.TrialExclusionSummary
    support_SaveTrialExclusionSummary(TRIAL_EXCLUSIONS, Config, Meta, Participants);
end

if Config.Save.TEPREveryParticipant
    support_SaveTEPREveryParticipant(TEPREveryParticipant, Config, Meta, Participants);
end
