
clc
clear
format long

ERL_Spark = readtable('~RESULTS/PLR_LUND_DQ_MM_Tobii/TEPR csv alignSR=1 filt=0 (All Trials)/ERL BL=[-0.5 0] alignSR=1 filt=0 (All Trials).csv', 'NumHeaderLines', 1);
ERLV_Spark = readtable('~RESULTS/PLR_LUND_DQ_MM_Tobii/TEPR csv alignSR=1 filt=0 (All Trials)/ERLV BL=[-0.5 0] alignSR=1 filt=0 (All Trials).csv', 'NumHeaderLines', 1);
ERL_PupilEXT = readtable('~RESULTS/PLR_LUND_DQ_PX_PupilEXT/TEPR csv alignSR=1 filt=0 (All Trials)/ERL BL=[-0.5 0] alignSR=1 filt=0 (All Trials).csv', 'NumHeaderLines', 1);
ERLV_PupilEXT = readtable('~RESULTS/PLR_LUND_DQ_PX_PupilEXT/TEPR csv alignSR=1 filt=0 (All Trials)/ERLV BL=[-0.5 0] alignSR=1 filt=0 (All Trials).csv', 'NumHeaderLines', 1);

participants = ERL_Spark{:,1};

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

%%
% x1 = ERL_Spark_m;
% x2 = ERL_PupilEXT_m;
% [f1,xi1] = ksdensity(x1);
% [f2,xi2] = ksdensity(x2);
% plot(xi1,f1,'LineWidth',2, 'Color', '#1170be'); % matlab stock blue, but reproducible
histogram(ERL_Spark_m, 'BinWidth', 100, 'FaceColor', '#1170be', 'FaceAlpha', 0.5); % matlab stock blue, but reproducible
hold on;
% plot(xi2,f2,'LineWidth',2, 'Color', '#dd5500'); % matlab stock orange, but reproducible
histogram(ERL_PupilEXT_m, 'BinWidth', 100, 'FaceColor', '#dd5500', 'FaceAlpha', 0.5); % matlab stock orange, but reproducible
hold off;
%
xlim([500 4000])
ylim([0 25])
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

exportgraphics(gcf,'Figure_2a.png','Resolution',300)
pause(1)

%%
disp('--')
disp('Y difference (in a.u.):')
% [h, p, ci, stats] = ttest(ERLV_Spark_m, ERLV_PupilEXT_m);
% disp(['Student T test: p = ' num2str(p)])
[p, h, stats] = ranksum(ERLV_Spark_m, ERLV_PupilEXT_m);
disp(['Mann Whitney U test (significant result means two sets are different): p = ' num2str(p)])
disp(stats)
disp('Non-significant result means PD estimate readings from Spark and PupilEXT originate from the same distribution.')

% x1 = ERLV_Spark_m;
% x2 = ERLV_PupilEXT_m;
% [f1,xi1] = ksdensity(x1);
% [f2,xi2] = ksdensity(x2);
% plot(xi1,f1,'LineWidth',2, 'Color', '#1170be'); % matlab stock blue, but reproducible
histogram(ERLV_Spark_m, 'BinWidth', 0.1, 'FaceColor', '#1170be', 'FaceAlpha', 0.5); % matlab stock blue, but reproducible
hold on;
% plot(xi2,f2,'LineWidth',2, 'Color', '#dd5500'); % matlab stock orange, but reproducible
histogram(ERLV_PupilEXT_m, 'BinWidth', 0.1, 'FaceColor', '#dd5500', 'FaceAlpha', 0.5); % matlab stock orange, but reproducible
hold off;
legend({'Spark', 'PupilEXT'}, 'Location', 'northeast')
%
xlabel('Pupillary Light Response pupil diameter [a.u.]') % baseline-corrected, z-normalized, of single trial responses
ylabel('Frequency [-]') % approximated by Kernel Density Estimation
%
% ylim([0 1.3])
ylim([0 35])
%
grid on
grid minor
%
ffa = get(0, 'Screensize');
set(gcf, 'Position', [1 1 ffa(3)*1/4 ffa(4)*1/3]);

exportgraphics(gcf,'Figure_2b.png','Resolution',300)
pause(1)

%%
T = table( ...
    'Size',[0 4], ...
    'VariableTypes', {'double','double','string', 'string'}, ...
    'VariableNames', {'TrialNr','Latency','Subject','System'} );
T_rowi = 1;
for si = 1:numParticipants
    for ti = 1:numTrials
        T(T_rowi,:) = {ti, ERL_Spark_m((si-1)*numTrials+ti), participants(si), "Tobii"};
        T_rowi = T_rowi+1;
    end
end
for si = 1:numParticipants
    for ti = 1:numTrials
        T(T_rowi,:) = {ti, ERL_PupilEXT_m((si-1)*numTrials+ti), participants(si), "PupilEXT"};
        T_rowi = T_rowi+1;
    end
end

writetable(T, 'T_JASP_ERL.csv', 'Delimiter', ';');
clear T

%%
T = table( ...
    'Size',[0 4], ...
    'VariableTypes', {'double','double','string', 'string'}, ...
    'VariableNames', {'TrialNr','Amplitude','Subject','System'} );
T_rowi = 1;
for si = 1:numParticipants
    for ti = 1:numTrials
        T(T_rowi,:) = {ti, ERLV_Spark_m((si-1)*numTrials+ti), participants(si), "Tobii"};
        T_rowi = T_rowi+1;
    end
end
for si = 1:numParticipants
    for ti = 1:numTrials
        T(T_rowi,:) = {ti, ERLV_PupilEXT_m((si-1)*numTrials+ti), participants(si), "PupilEXT"};
        T_rowi = T_rowi+1;
    end
end

writetable(T, 'T_JASP_ERLV.csv', 'Delimiter', ';');
clear T
