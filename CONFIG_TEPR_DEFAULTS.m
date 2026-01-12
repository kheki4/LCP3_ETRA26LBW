
Config = support_CreateVarWithDefaultValue(Config, 'ETDSDirName', '*');

Config = support_CreateVarWithDefaultValue(Config, 'RootDirTagSuffix', '');

%--------------------
Config = support_CreateVarWithDefaultValue(Config, 'BehavInitFunction', '*');
Config = support_CreateVarWithDefaultValue(Config, 'BehavFiltFunction', '*');

Config = support_CreateVarWithDefaultValue(Config, 'SkipFirstNtrials', 0);
Config = support_CreateVarWithDefaultValue(Config, 'RejectSpecificTrials', []);
Config = support_CreateVarWithDefaultValue(Config, 'RejectTrialsExceptExclusive', []);
Config = support_CreateVarWithDefaultValue(Config, 'RejectTrialsExceptExclusiveWithSkipFirstN', []);

%--------------------
% !! Also for NBACK_2alk_2023 SMI & PupilEXT 
Config = support_CreateVarWithDefaultValue(Config, 'AnalyzeFromSec', NaN);
Config = support_CreateVarWithDefaultValue(Config, 'AnalyzeToSec', NaN);
Config = support_CreateVarWithDefaultValue(Config, 'PeakFromSec', NaN);
Config = support_CreateVarWithDefaultValue(Config, 'PeakToSec', NaN);
Config = support_CreateVarWithDefaultValue(Config, 'BaselineFromSec', NaN);
Config = support_CreateVarWithDefaultValue(Config, 'BaselineToSec', NaN);

%-------------------
Config = support_CreateVarWithDefaultValue(Config, 'Filter', struct);

Config.Filter = support_CreateVarWithDefaultValue(Config.Filter, 'BaselineBlink', struct);
Config.Filter.BaselineBlink = support_CreateVarWithDefaultValue(Config.Filter.BaselineBlink, 'FromSec', NaN);
Config.Filter.BaselineBlink = support_CreateVarWithDefaultValue(Config.Filter.BaselineBlink, 'ToSec', NaN);

Config.Filter = support_CreateVarWithDefaultValue(Config.Filter, 'BaselineSaccade', struct);
Config.Filter.BaselineSaccade = support_CreateVarWithDefaultValue(Config.Filter.BaselineSaccade, 'FromSec', NaN);
Config.Filter.BaselineSaccade = support_CreateVarWithDefaultValue(Config.Filter.BaselineSaccade, 'ToSec', NaN);

Config.Filter = support_CreateVarWithDefaultValue(Config.Filter, 'SOIBlink', struct);
Config.Filter.SOIBlink = support_CreateVarWithDefaultValue(Config.Filter.SOIBlink, 'FromSec', NaN);
Config.Filter.SOIBlink = support_CreateVarWithDefaultValue(Config.Filter.SOIBlink, 'ToSec', NaN);

Config.Filter = support_CreateVarWithDefaultValue(Config.Filter, 'SOISaccade', struct);
Config.Filter.SOISaccade = support_CreateVarWithDefaultValue(Config.Filter.SOISaccade, 'FromSec', NaN);
Config.Filter.SOISaccade = support_CreateVarWithDefaultValue(Config.Filter.SOISaccade, 'ToSec', NaN);

Config = support_CreateVarWithDefaultValue(Config, 'DynBLCorrMap', struct);
Config.DynBLCorrMap = support_CreateVarWithDefaultValue(Config.DynBLCorrMap, 'BehavDF', '*');
Config.DynBLCorrMap = support_CreateVarWithDefaultValue(Config.DynBLCorrMap, 'DVFrom', NaN);
Config.DynBLCorrMap = support_CreateVarWithDefaultValue(Config.DynBLCorrMap, 'DVTo', NaN);
Config.DynBLCorrMap = support_CreateVarWithDefaultValue(Config.DynBLCorrMap, 'A1Sign', 0);
Config.DynBLCorrMap = support_CreateVarWithDefaultValue(Config.DynBLCorrMap, 'SmallOrLarge', true);

Config = support_CreateVarWithDefaultValue(Config, 'TimecourseCorrel', struct);
Config.TimecourseCorrel = support_CreateVarWithDefaultValue(Config.TimecourseCorrel, 'BehavDF', '*');
Config.TimecourseCorrel = support_CreateVarWithDefaultValue(Config.TimecourseCorrel, 'DVFrom', NaN);
Config.TimecourseCorrel = support_CreateVarWithDefaultValue(Config.TimecourseCorrel, 'DVTo', NaN);
%
Config.TimecourseCorrel = support_CreateVarWithDefaultValue(Config.TimecourseCorrel, 'CorrelMethod', 'Spearman');
% 'Spearman' or 'Pearson'
%
Config.TimecourseCorrel = support_CreateVarWithDefaultValue(Config.TimecourseCorrel, 'A1Sign', 0);
% Alternative hypothesis expected sign. Warning: this affects test significance output
% 1; % positive
% -1; % negative
% 0; % any
%
Config.TimecourseCorrel = support_CreateVarWithDefaultValue(Config.TimecourseCorrel, 'DrawLegend', true);
Config.TimecourseCorrel = support_CreateVarWithDefaultValue(Config.TimecourseCorrel, 'DrawTitle', true);
Config.TimecourseCorrel = support_CreateVarWithDefaultValue(Config.TimecourseCorrel, 'BeginAtTimeZero', true);
%
Config.TimecourseCorrel = support_CreateVarWithDefaultValue(Config.TimecourseCorrel, 'LegendLocation', 'northeast');
% 'northeast'; % ↗
% 'southeast'; % ↘
% 'southwest'; % ↙
% 'northwest'; % ↖
%
Config.TimecourseCorrel = support_CreateVarWithDefaultValue(Config.TimecourseCorrel, 'PlotInsig', true);

Config.TimecourseCorrel = support_CreateVarWithDefaultValue(Config.TimecourseCorrel, 'OnlySigLines_Enabled', true);
Config.TimecourseCorrel = support_CreateVarWithDefaultValue(Config.TimecourseCorrel, 'OnlySigLines_AtY', 0);

%-------------
Config = support_CreateVarWithDefaultValue(Config, 'Plot', struct);

Config.Plot = support_CreateVarWithDefaultValue(Config.Plot, 'TEPR', struct);
Config.Plot.TEPR = support_CreateVarWithDefaultValue(Config.Plot.TEPR, 'XLim', NaN);
Config.Plot.TEPR = support_CreateVarWithDefaultValue(Config.Plot.TEPR, 'YLim', NaN);

Config.Plot = support_CreateVarWithDefaultValue(Config.Plot, 'GrandTEPR', struct);
Config.Plot.GrandTEPR = support_CreateVarWithDefaultValue(Config.Plot.GrandTEPR, 'XLim', NaN);
Config.Plot.GrandTEPR = support_CreateVarWithDefaultValue(Config.Plot.GrandTEPR, 'YLim', NaN);
Config.Plot.GrandTEPR = support_CreateVarWithDefaultValue(Config.Plot.GrandTEPR, 'ShowCI', true);
Config.Plot.GrandTEPR = support_CreateVarWithDefaultValue(Config.Plot.GrandTEPR, 'CIFaceAlpha', 0.2);

Config.Plot = support_CreateVarWithDefaultValue(Config.Plot, 'GrandERA', struct);
% Config.Plot.GrandERA = support_CreateVarWithDefaultValue(Config.Plot.GrandERA, 'XLim', NaN);
Config.Plot.GrandERA = support_CreateVarWithDefaultValue(Config.Plot.GrandERA, 'YLim', [0.85, 1.0]);

Config.Plot = support_CreateVarWithDefaultValue(Config.Plot, 'DynBLCorrMap', struct);
Config.Plot.DynBLCorrMap = support_CreateVarWithDefaultValue(Config.Plot.DynBLCorrMap, 'XTickInt', 0.2);

%------------------- az alábbiak ÁLTALÁNOSAK, voltak sokáig a tepr szkriptben
Config = support_CreateVarWithDefaultValue(Config, 'AlignToStimOrResp', true);

% Use variable-baseline correction (VBL)
Config = support_CreateVarWithDefaultValue(Config, 'UseVBL', false);

Config = support_CreateVarWithDefaultValue(Config, 'BLC', 1);
% 0; % No baseline correction (mostly DEV only)
% 1; % BLC locally every trial of every participant 
% 2; % BLC after data aggregation to grand TEPR (DEV only; should produce the same results as the local one)

Config = support_CreateVarWithDefaultValue(Config, 'Z_norm_method', 1);
% 0; % No Z-normalization
% 1; % Reference to whole recording (advised)
% 2; % Reference to each trial for its own
% 3; % Reference to all existing trials
% 4; % Reference to all non-rejected trials
% % % 5; % TODO: Reference to nearby N seconds

Config = support_CreateVarWithDefaultValue(Config, 'RejectTrials', []);
Config = support_CreateVarWithDefaultValue(Config, 'DisregardTrialSections', {});

Config = support_CreateVarWithDefaultValue(Config, 'DisregardTrialSectionsOnBehav', false);
Config = support_CreateVarWithDefaultValue(Config, 'DisregardTrialSectionsOnBehavFunction', '*');

Config = support_CreateVarWithDefaultValue(Config, 'Save', struct);
Config.Save = support_CreateVarWithDefaultValue(Config.Save, 'BaselineValues', false);
Config.Save = support_CreateVarWithDefaultValue(Config.Save, 'PeakValues', true);
Config.Save = support_CreateVarWithDefaultValue(Config.Save, 'TEPREveryParticipant', true);

Config.Save = support_CreateVarWithDefaultValue(Config.Save, 'TrialExclusionSummary', true);

% can be very slow if there are many excluded trials
Config.Save = support_CreateVarWithDefaultValue(Config.Save, 'EveryTrial', true);

% METHOD
Config = support_CreateVarWithDefaultValue(Config, 'EventRelatedMethod', 1);
% 1; % TEPR (Avg)
% 2; % TEPR-SD
% 3; % TEPR-Ku
% 4; % TEPR-Sk
% 5; % TEPR-MAD
% 6; % TEPR-Min
% 7; % TEPR-Max
% 8; % TEPR-KMax
% 9; % TEPR-KVal
% 10; % % ERPD-CV (coefficient of variation, not in percentage)
% 11; % TEPR-Sh - Shapiro
% 12; % TEPR (Median)

% DYN BASELINE MAP
Config.Plot = support_CreateVarWithDefaultValue(Config.Plot, 'DynBLcorrMap', struct);
Config.Plot.DynBLcorrMap = support_CreateVarWithDefaultValue(Config.Plot.DynBLcorrMap, 'Make', false);
Config.Plot.DynBLcorrMap = support_CreateVarWithDefaultValue(Config.Plot.DynBLcorrMap, 'SmallOrLarge', true);
Config.Plot.DynBLcorrMap = support_CreateVarWithDefaultValue(Config.Plot.DynBLcorrMap, 'CorrelMethod', 'Spearman');
Config.Plot.DynBLcorrMap = support_CreateVarWithDefaultValue(Config.Plot.DynBLcorrMap, 'A1Sign', 0);
% 1; % positive
% -1; % negative
% 0; % any

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEV: TODO below this line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FilterConfigs.SD.LocalLimit = 1.5; 


% LOW FPS TRIGGER JITTER CORRECTION:

% NOTE: This only makes sense if the sampling rate is very low, e.g. below 30hz
% so that the delay between a trigger timestamp of trial number increment and the first actual sample that belongs to the new trial
% can be high, like 50ms in case of 20hz eye data... so we could help a little with interpolation.
% BUT: this should never be used if there is higher raw eye data quality available! Or in other words:
% this is for a tiny correction of between-trial temporal alignment for better TEPR/TEPR averaging, and not for "enhancing" the
% preprocessed data if it was previously downsampled too much during preprocessing. (Then it would not improve anything.)

% Config.PerformTJC = true;
Config.PerformTJC = false;

RejectTrialsOnTypicalLen = false;
RejectTrialsOutsideLenSec = NaN;

Config.Filter.Interpol.Threshold = 20;
Config.Filter.BaselineSaccade.Magnitude = 20; % deg?
Config.Filter.SOISaccade.Magnitude = 20; % deg?

Config.Filter.Interpol.Enabled = false; % true; 
% Config.Filter.BaselineBlink.Enabled = true; %%%%
% Config.Filter.BaselineSaccade.Enabled = true;
% Config.Filter.SOIBlink.Enabled = true;
% Config.Filter.SOISaccade.Enabled = true;
% % % % % Filter.OnBaselineInterpol = true;
% Config.Filter.SD.Enabled = true;

% Config.Filter.Interpol.Enabled = false;
Config.Filter.BaselineBlink.Enabled = false; %%%%
Config.Filter.BaselineSaccade.Enabled = false;
Config.Filter.SOIBlink.Enabled = false;
Config.Filter.SOISaccade.Enabled = false;
Config.Filter.SD.Enabled = false;

% Event-related latency
Config = support_CreateVarWithDefaultValue(Config, 'ERL', struct);
Config.ERL = support_CreateVarWithDefaultValue(Config.ERL, 'Method', 1);
% 1; % Next local maximum "peak"
% 2; % Next local minimum
% 3; % Next inflexion point
Config.ERL = support_CreateVarWithDefaultValue(Config.ERL, 'Enabled', 1);
Config.ERL = support_CreateVarWithDefaultValue(Config.ERL, 'FromSec', NaN);
Config.ERL = support_CreateVarWithDefaultValue(Config.ERL, 'ToSec', NaN);

Config = support_CreateVarWithDefaultValue(Config, 'CC', struct);
Config.CC = support_CreateVarWithDefaultValue(Config.CC, 'Conds', []);
Config.CC = support_CreateVarWithDefaultValue(Config.CC, 'Enabled', false);

Config.Filter = support_CreateVarWithDefaultValue(Config.Filter, 'Behav', struct);
Config.Filter.Behav = support_CreateVarWithDefaultValue(Config.Filter.Behav, 'Enabled', false);

% % % % Config.Filter.Behav.CondComb = 0; % tilos mert akkor nem jó az
% összehasonlitó kód (kivülről nem tudja megváltoztatni)

Config.ERA.Enabled = true; % event-related artefacts (event-related blink curve & event-related saccades curve)
% Config.ERA.Enabled = false;

Config.ERA.EventOfInterest = 0; % blink start
% Config.ERA.EventOfInterest = 1; % blink end
% Config.ERA.EventOfInterest = 2; % saccade start
% Config.ERA.EventOfInterest = 3; % saccade end

Config.Plot.TimecourseCorrel.Make = false;

% ERA visualization only
% Config.Plot.ERA.VisualMethod = 0; % kernel density estimation
Config.Plot.ERA.VisualMethod = 1; % histogram
%
Config.Plot.ERA.KDEBandwidth = 200;
Config.Plot.ERA.HistBinWidth = 200;
% 
Config.Plot.ERA.YLim = [0.85 1];

% Should we always close the existing figure on a new plot, or plot on it
% Config.Plots.Layered = true;
% Config.Plots.Layered = false;
%
% Config.Plots.LayeredFigCounter = 1;

% Config.Plot.TEPR.Make = true; %%%  %%%
% Config.Plot.GrandTEPR.Make = true;
% Config.Plot.ERA.Make = true;
% Config.Plot.GrandERA.Make = true;

% Config.Plot.TEPR.EveryTrial = true; %%%% %%%  %%%
% Config.Plot.GrandTEPR.EveryParticipant = true; %%%%
% Config.Plot.GrandERA.EveryParticipant true;

Config.Plot.TEPR.Make = false; %%%  %%%
Config.Plot.GrandTEPR.Make = false; %%%  %%%
Config.Plot.ERA.Make = false;
Config.Plot.GrandERA.Make = false;

Config.Plot.TEPR.EveryTrial = false; %%%% %%%  %%%
Config.Plot.GrandTEPR.EveryParticipant = false; %%%%
Config.Plot.GrandERA.EveryParticipant = false;


Config.Plots.ScaleFactor = 0.4;
% Config.Plots.ScaleFactor = 0.6;
% Config.Plots.ScaleFactor = 1.0;

% Config.Plots.ColorSig001 = [0.6350 0.0780 0.1840]; % pruple
% Config.Plots.ColorSig01 = [0.4660 0.6740 0.1880]; % green
% Config.Plots.ColorSig05 = [0.8500 0.3250 0.0980]; % orange
% Config.Plots.ColorSigNS = [0.5 0.5 0.5]; % 50% grey
%%%%
Config.Plots.ColorSig001 = [3/255 115/255 252/255]; % deep blue
Config.Plots.ColorSig01 = [3/255 181/255 252/255]; % sky blue
Config.Plots.ColorSig05 = [3/255 252/255 190/255]; % light blue
Config.Plots.ColorSigNS = [0.5 0.5 0.5]; % 50% grey

% NOTE: adding plot markings when the analytic length is long is slow
% Config.Plots.Markings = false;
Config.Plots.Markings.Enabled = true;
Config.Plots.Markings.F = false;
Config.Plots.Markings.B = true;
Config.Plots.Markings.S = true;
Config.Plots.Markings.R = true;
Config.Plots.Markings.Text = true;

Config.Plots.DrawTitle = true;

Config.Plots.Grid = true;
% Config.Plots.Grid = false;

% Config.Plots.Markings.OnEdges = true;
Config.Plots.Markings.OnEdges = false;





