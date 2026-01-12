
% PLR LUND

% Config.ETDSDirName = 'PLR_LUND_DQ_MM_Tobii';
% Config.Plot.GrandTEPR.LineColor = '#1170be'; % matlab stock blue, but reproducible

Config.ETDSDirName = 'PLR_LUND_DQ_PX_PupilEXT';
Config.Plot.GrandTEPR.LineColor = '#dd5500'; % matlab stock orange, but reproducible

% % Plus:
% box on
% legend({'Spark'}, 'Location', 'southeast')
% % or
% legend({'PupilEXT'}, 'Location', 'southeast')

Config.Z_norm_method = 2; % Reference to each trial for its own

Config.BLC = 1; % BLC locally % BASIC

Config.SkipFirstNtrials = 0;

%--------------------
Config.AnalyzeFromSec = -0.5;
Config.AnalyzeToSec = 10.250; 
Config.PeakFromSec = 0.5; 
Config.PeakToSec = 2.0;
Config.BaselineFromSec = -0.5;
Config.BaselineToSec = 0.0;
%--------------------

Config.Save.BaselineValues = true;

Config.Plots.ScaleFactor = 0.6; % every trial
Config.Plots.Markings.Enabled = true;
Config.Plots.Markings.B = false;
Config.Plots.Markings.S = true;
Config.Plots.Markings.F = false;
Config.Plots.Markings.Text = false;

Config.Plots.DrawTitle = false;

Config.ERL.Enabled = true;
Config.ERL.Method = 2; % next local minimum
Config.ERL.FromSec = 0.5;
Config.ERL.ToSec = 2.0;

Config.Plot.TEPR.Make = true; % FOR EACH PERSON
Config.Plot.TEPR.EveryTrial = true; 
Config.Plot.TEPR.XLim = NaN;
% % % Config.Plot.TEPR.YLim = [-3 3];

Config.Plot.GrandTEPR.Make = true;
Config.Plot.GrandTEPR.ShowCI = true;
Config.Plot.GrandTEPR.CIFaceAlpha = 0.15;

Config.Plot.GrandTEPR.XLim = [0.0 10250];
Config.Plot.GrandTEPR.YLim = [-3.0 0.2];




