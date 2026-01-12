
clc
clear
format long

ERL_Spark = readtable('~RESULTS/PLR_LUND_DQ_MM_Tobii/TEPR csv alignSR=1 filt=0 (All Trials)/ERL BL=[-0.5 0] alignSR=1 filt=0 (All Trials).csv', 'NumHeaderLines', 1);
ERLV_Spark = readtable('~RESULTS/PLR_LUND_DQ_MM_Tobii/TEPR csv alignSR=1 filt=0 (All Trials)/ERLV BL=[-0.5 0] alignSR=1 filt=0 (All Trials).csv', 'NumHeaderLines', 1);
ERL_PupilEXT = readtable('~RESULTS/PLR_LUND_DQ_PX_PupilEXT/TEPR csv alignSR=1 filt=0 (All Trials)/ERL BL=[-0.5 0] alignSR=1 filt=0 (All Trials).csv', 'NumHeaderLines', 1);
ERLV_PupilEXT = readtable('~RESULTS/PLR_LUND_DQ_PX_PupilEXT/TEPR csv alignSR=1 filt=0 (All Trials)/ERLV BL=[-0.5 0] alignSR=1 filt=0 (All Trials).csv', 'NumHeaderLines', 1);

ERL_Spark(:,1) = [];
ERLV_Spark(:,1) = [];
ERL_PupilEXT(:,1) = [];
ERLV_PupilEXT(:,1) = [];

numParticipants = size(ERL_Spark, 1);
numTrials = size(ERL_Spark, 2);

ERL_Spark_m = table2array(ERL_Spark);
ERL_Spark_m = reshape(ERL_Spark_m.', 1, []);
ERLV_Spark_m = table2array(ERLV_Spark);
ERLV_Spark_m = reshape(ERLV_Spark_m.', 1, []);
ERL_PupilEXT_m = table2array(ERL_PupilEXT);
ERL_PupilEXT_m = reshape(ERL_PupilEXT_m.', 1, []);
ERLV_PupilEXT_m = table2array(ERLV_PupilEXT);
ERLV_PupilEXT_m = reshape(ERLV_PupilEXT_m.', 1, []);

%% 
% Shapiro tests for normality

support_displayShapiro(ERL_Spark_m);
support_displayShapiro(ERLV_Spark_m);
support_displayShapiro(ERL_PupilEXT_m);
support_displayShapiro(ERLV_PupilEXT_m);

%%
disp('Two sample tests, illustrated with histograms: checking whether difference in latency or pupil diameter estimate exists.')

disp('X difference (in ms):')
% [h, p, ci, stats] = ttest(ERL_Spark_m, ERL_PupilEXT_m);
% disp(['Student T test: p = ' num2str(p)])
[p, h, stats] = ranksum(ERL_Spark_m, ERL_PupilEXT_m);
disp(['Mann Whitney U test (significant result means two sets are different): p = ' num2str(p)])
disp(stats)
disp('Non-significant result means latency of evoked PD readings from Spark and PupilEXT originate from the same distribution.')

x1 = ERL_Spark_m;
x2 = ERL_PupilEXT_m;
[f1,xi1] = ksdensity(x1);
[f2,xi2] = ksdensity(x2);
plot(xi1,f1,'LineWidth',2, 'Color', '#1170be'); % matlab stock blue, but reproducible
hold on;
plot(xi2,f2,'LineWidth',2, 'Color', '#dd5500'); % matlab stock orange, but reproducible
hold off;
legend({'Spark', 'PupilEXT'}, 'Location', 'northeast')
%
xlabel('Pupillary Light Response latency [ms]') % of single trial responses
ylabel('Frequency [-]') % approximated by Kernel Density Estimation
%
grid on
grid minor
%
ffa = get(0, 'Screensize');
set(gcf, 'Position', [1 1 ffa(3)*1/4 ffa(4)*1/3]);

disp('--')
disp('Y difference (in a.u.):')
% [h, p, ci, stats] = ttest(ERLV_Spark_m, ERLV_PupilEXT_m);
% disp(['Student T test: p = ' num2str(p)])
[p, h, stats] = ranksum(ERLV_Spark_m, ERLV_PupilEXT_m);
disp(['Mann Whitney U test (significant result means two sets are different): p = ' num2str(p)])
disp(stats)
disp('Non-significant result means PD estimate readings from Spark and PupilEXT originate from the same distribution.')

x1 = ERLV_Spark_m;
x2 = ERLV_PupilEXT_m;
[f1,xi1] = ksdensity(x1);
[f2,xi2] = ksdensity(x2);
plot(xi1,f1,'LineWidth',2, 'Color', '#1170be'); % matlab stock blue, but reproducible
hold on;
plot(xi2,f2,'LineWidth',2, 'Color', '#dd5500'); % matlab stock orange, but reproducible
hold off;
legend({'Spark', 'PupilEXT'}, 'Location', 'northeast')
%
xlabel('Pupillary Light Response pupil diameter [a.u.]') % baseline-corrected, z-normalized, of single trial responses
ylabel('Frequency [-]') % approximated by Kernel Density Estimation
%
grid on
grid minor
%
ffa = get(0, 'Screensize');
set(gcf, 'Position', [1 1 ffa(3)*1/4 ffa(4)*1/3]);

