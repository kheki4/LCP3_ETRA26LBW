function support_PlotTimecourseCorrel(TEPREveryParticipant, Config, Meta)

    if Config.TimecourseCorrel.A1Sign == 'any'
        log_w(['No expected sign specified for timecourse correlation tests']);
    end

%     % plot_insig = false;
%     plot_insig = true;

    % do_shuffle = true;

%     xlim_desired = [0 Config.AnalyzeToSec*1000]; 
    xlim_desired = [Config.AnalyzeFromSec*1000 Config.AnalyzeToSec*1000];

    % TODO
    %
    % ylim_desired = [0 0.6];
    % % ylim_desired = [-0.6 0.6];
% % %     ylim_desired = [-0.9 0.9];
% %     ylim_desired = [-0.1 0.5];
%     ylim_desired = [0 0.5];
    ylim_desired = [-0.5 0.5];

    dv_cols = [Config.TimecourseCorrel.DVFrom Config.TimecourseCorrel.DVTo];
    % % liv_cols = [12 21];
    % liv_cols = [12 160];
%     liv_cols = [2 2+analyzeLenSample-1];

    % VariableNamingRule: starting from Matlab R2019b
%     T_PD = readtable(filename_PD); %, 'VariableNamingRule', 'preserve'); %, 'HeaderLines', 8); 
    T_DV = readtable(Config.TimecourseCorrel.BehavDF); %, 'VariableNamingRule', 'preserve'); %, 'HeaderLines', 8);

    %     %colNames_RTfile = ['rt', 'set number'];
    %     
    %     % MST encode esetén
    %     RT = T{:,4};
    %     trial_fromRTfile = T{:,5};

    num_dv = (dv_cols(2)-dv_cols(1)+1);
%     num_liv = (liv_cols(2)-liv_cols(1)+1);

    correl_matrix_rho = zeros(num_dv, Config.AnalyzeLenSample);
    correl_matrix_pval = zeros(num_dv, Config.AnalyzeLenSample);



    %     if do_shuffle
    %         scols = size(A,2);
    %         P = randperm(scols);
    %         B = A(:,P);
    %     end
    
    cTo = Config.AnalyzeLenSample;

    % computing
    for dv = 1:num_dv % cycle through dependent variable

        for cAt = 1:cTo
            
            % TEPREveryParticipant*********************{:,(liv_cols(1)+liv-1)}
            
            % TODO: MINEK EZ? HISZEM MÁR ELVILEG EZEN KIVÜL EGYSZER
            % BASELINE KORRIGÁLVA VAN
            statAtDelta = ...
                TEPREveryParticipant(:, cAt ) - ...
                mean(TEPREveryParticipant(:, Config.BaselineFromSampleMapped:Config.BaselineToSampleMapped ), 2, 'omitnan');

    %         if do_shuffle
    %             temp_vals = T{:,(dv_cols(1)+dv-1)};
    %             temp_vals = temp_vals(randperm(length(temp_vals)));
    %             [RHO,PVAL] = corr(temp_vals, T{:,(liv_cols(1)+liv-1)}, 'Type', correlMethod, 'rows','complete'); % omits NaN
    %         else
                if Config.TimecourseCorrel.A1Sign == 1
                    [RHO,PVAL] = corr(T_DV{:,(dv_cols(1)+dv-1)}, statAtDelta, 'Type', Config.TimecourseCorrel.CorrelMethod, 'rows','complete','Tail','right');
                elseif Config.TimecourseCorrel.A1Sign == -1
                    [RHO,PVAL] = corr(T_DV{:,(dv_cols(1)+dv-1)}, statAtDelta, 'Type', Config.TimecourseCorrel.CorrelMethod, 'rows','complete','Tail','left');
                elseif Config.TimecourseCorrel.A1Sign == 0
                    [RHO,PVAL] = corr(T_DV{:,(dv_cols(1)+dv-1)}, statAtDelta, 'Type', Config.TimecourseCorrel.CorrelMethod, 'rows','complete');
                end
    %         end

            correl_matrix_rho(dv, cAt) = RHO;
            correl_matrix_pval(dv, cAt) = PVAL;
        end

    end

    
    % PLOTTING 3D POINT CLOUD
    for dv = 1:num_dv
        
        % Sample
        xx = repmat(linspace(round(Config.AnalyzeFromSec*1000),round(Config.AnalyzeToSec*1000),Config.AnalyzeLenSample), 1, size(TEPREveryParticipant,1));
%         xx = repmat(1:Config.AnalyzeLenSample*1000, 1, size(TEPREveryParticipant,1));
        
        % Behav
        yy = reshape(transpose(repmat(T_DV{:,(dv_cols(1)+dv-1)}, 1, Config.AnalyzeLenSample)), [1, size(TEPREveryParticipant,1)*Config.AnalyzeLenSample]);
        
        % Pup dil
        zz = reshape(transpose(TEPREveryParticipant),[1, size(TEPREveryParticipant,1)*Config.AnalyzeLenSample]);
        

        mat = [xx(:) yy(:) zz(:)];

        axp = pcshow(mat);
        axp.DataAspectRatio = [diff(axp.XLim), diff(axp.YLim), diff(axp.ZLim)] / diff(axp.YLim);
        
        for cAt = 1:cTo
            
            yy2 = T_DV{:,(dv_cols(1)+dv-1)};
            zz2 = TEPREveryParticipant(:, cAt );

            [RHO,PVAL] = corr(yy2, zz2, 'Type', Config.TimecourseCorrel.CorrelMethod, 'rows','complete'); % omits NaN
            correl_rho(cAt) = RHO;
            correl_pval(cAt) = PVAL;
            
            P = polyfit(yy2, zz2, 1);
            correl_slope(cAt) = P(1);
            correl_intercept(cAt) = P(2);

            hold on
            maxDV = max(T_DV{:,(dv_cols(1)+dv-1)});
            minDV = min(T_DV{:,(dv_cols(1)+dv-1)});
            pcan = round(Config.AnalyzeFromSec*1000)+round((Config.AnalyzeToSec-Config.AnalyzeFromSec)*1000)/Config.AnalyzeLenSample*cAt;
            x3 = [pcan pcan];
%             x3 = [cAt cAt];
            y3 = [minDV maxDV];
            z3 = [correl_intercept(cAt)+minDV*correl_slope(cAt) correl_intercept(cAt)+maxDV*correl_slope(cAt)];

            if correl_pval(cAt) <= 0.001
                clco = Config.Plots.ColorSig001;
            elseif correl_pval(cAt) <= 0.01 && correl_pval(cAt) > 0.001
                clco = Config.Plots.ColorSig01;
            elseif correl_pval(cAt) <= 0.05 && correl_pval(cAt) > 0.01
                clco = Config.Plots.ColorSig05;
            else
                clco = Config.Plots.ColorSigNS;
            end
%             plot3(x3',y3',z3', 'Color', 'g');
            plot3(x3',y3',z3', 'Color', clco);
            
        end

%         % Front
%         view([0 0])
    
        % 3D
        view([-10 10])
        
    end

    % %%%%%%%%%%%%%%%%%%%%%%

    % plotting 2D
    for dv =  1:num_dv % cycle through dependent variable

        % NOTE: here the transformation happens at creation of the x vector, not when plotting
    %     x_backbone = (1:analyzeLenSample) / meta.nomSrate * 1000 + analyzeFromSec*1000;
        x_backbone = (0:(Config.AnalyzeLenSample-1)) / Meta.NomSRate * 1000 + Config.AnalyzeFromSec*1000;

        close all
        hold on
        
        beginFromSample = 2;
        if Config.TimecourseCorrel.BeginAtTimeZero
            beginFromSample = beginFromSample + 1 + (-1 * Config.AnalyzeFromSample); % DEV, miért pont így jó? hardcoded magic egyelőre
        end
        
        for n = beginFromSample:length(correl_matrix_rho(dv, :))
            if Config.TimecourseCorrel.OnlySigLines_Enabled
                yVal = [Config.TimecourseCorrel.OnlySigLines_AtY Config.TimecourseCorrel.OnlySigLines_AtY];
            else
                yVal = correl_matrix_rho(dv, [n-1 n]);
            end
        
            if correl_matrix_pval(dv, n) <= 0.001 && correl_matrix_pval(dv, n-1) <= 0.001
                pcat3_line = plot(x_backbone([n-1 n]), yVal, 'color', Config.Plots.ColorSig001, 'linewidth', 2.5);
            elseif correl_matrix_pval(dv, n) <= 0.01 && correl_matrix_pval(dv, n-1) <= 0.01
                pcat2_line = plot(x_backbone([n-1 n]), yVal, 'color', Config.Plots.ColorSig01, 'linewidth', 2.5);
            elseif correl_matrix_pval(dv, n) <= 0.05 && correl_matrix_pval(dv, n-1) <= 0.05
                pcat1_line = plot(x_backbone([n-1 n]), yVal, 'color', Config.Plots.ColorSig05, 'linewidth', 2.5);
            elseif Config.TimecourseCorrel.PlotInsig
                pcat4_line = plot(x_backbone([n-1 n]), yVal, 'color', Config.Plots.ColorSigNS, 'linewidth', 2);
            end
        end
        hold off

        if Config.Plots.Grid
            %grid on;
            %grid minor;
			set(gca,'XGrid','on','YGrid','on')
			set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on')
        end
        ax = gca;
        box(ax,'on'); % black 1px border and etchings on it, even on top of plot

        if ~Config.TimecourseCorrel.OnlySigLines_Enabled
            xlabel('Time [ms]');
            ylabel('Spearman''s Rho [-]');
        end

        xlim(xlim_desired);
        ylim(ylim_desired);

        if Config.Plots.Markings.Enabled == true
            currylim = ylim;
            colorB = [0.3 0.3 0.9];
            yDt = 4; %5;
            for t = (Config.AnalyzeFromSec*1000):(Config.AnalyzeToSec*1000) 
    %         for t = xlim_desired(1):xlim_desired(2)

                if ~Config.Plots.Markings.OnEdges && (t==xlim_desired(1) || t==xlim_desired(2))
                    continue;
                end

                if Config.Plots.Markings.B && t~= 0 && mod(t, Meta.ISISec*1000) == Meta.ISISec*1000 + (Config.BaselineFromSec+Config.BaselineToSec)/2*1000
                    xline(t, 'Color', colorB);
                    if Config.Plots.Markings.Text
                        text(t, currylim(2)-(currylim(2)-currylim(1))/yDt,'B', 'Color', colorB)
                    end
                end

                if Config.Plots.Markings.S && mod(t, Meta.ISISec*1000) == 0
                    xline(t, 'Color', colorB);
                    if Config.Plots.Markings.Text
                        text(t, currylim(2)-(currylim(2)-currylim(1))/yDt,'S', 'Color', colorB)
                    end
                end

                if Config.Plots.Markings.F && t~= 0 && mod(t, Meta.ISISec*1000) == Meta.ISISec*1000 - Config.FixBeforeStimSec*1000
                    xline(t, 'Color', colorB);
                    if Config.Plots.Markings.Text
                        text(t, currylim(2)-(currylim(2)-currylim(1))/yDt,'F', 'Color', colorB)
                    end
                end

            end
        end

        yline(0);

        if Config.Plots.DrawTitle
            title(strrep(['Baseline corrected TEPR value (' Config.Filter.Behav.FriendlyName ') x ' T_DV.Properties.VariableNames{Config.TimecourseCorrel.DVFrom+dv-1}],'_','-'));
    %         title(['ERPD x ' T_DV.Properties.VariableNames{Config.TimecourseCorrel.DVFrom+dv-1}]);
        end





        %------------------
        ccc = 0;
        if exist('pcat4_line', 'var')
            ccc = ccc + 1;
        end
        if exist('pcat1_line', 'var')
            ccc = ccc + 1;
        end
        if exist('pcat2_line', 'var')
            ccc = ccc + 1;
        end
        if exist('pcat3_line', 'var')
            ccc = ccc + 1;
        end
        %%%%%%%%%%%%%%%%%
        jjj = 0;
        colorLegendRows = cell( ccc, 1 );
        plotHandlesArray = [];
        if exist('pcat4_line', 'var')
            plotHandlesArray = [plotHandlesArray, pcat4_line];
            jjj = jjj+1;
%             colorLegendRows(jjj) = { ['p > 0.05'] };
            colorLegendRows(jjj) = { ['N.S.'] };
        end
        if exist('pcat1_line', 'var')
            plotHandlesArray = [plotHandlesArray, pcat1_line];
            jjj = jjj+1;
%             colorLegendRows(jjj) = { ['p <= 0.05 && p > 0.01'] };
            colorLegendRows(jjj) = { ['✱'] };
        end
        if exist('pcat2_line', 'var')
            plotHandlesArray = [plotHandlesArray, pcat2_line];
            jjj = jjj+1;
%             colorLegendRows(jjj) = { ['p <= 0.01 && p > 0.001'] };
            colorLegendRows(jjj) = { ['✱✱'] };
        end
        if exist('pcat3_line', 'var')
            plotHandlesArray = [plotHandlesArray, pcat3_line];
            jjj = jjj+1;
%             colorLegendRows(jjj) = { ['p <= 0.001'] };
            colorLegendRows(jjj) = { ['✱✱✱'] };
        end

    %     legendlocation = 'southeast';
    
        if Config.TimecourseCorrel.DrawLegend && (exist('pcat1_line', 'var') || exist('pcat2_line', 'var') || exist('pcat3_line', 'var') || exist('pcat4_line', 'var'))
            legLoc = Config.TimecourseCorrel.LegendLocation;
            % DEV: the below solution is commented out, because it bugs
            % (makes the plot narrower than desired).. to be done
%             if Config.TimecourseCorrel.OnlySigLines_Enabled
%                 legLoc = [legLoc 'outside']; 
%             end
            legend(plotHandlesArray, colorLegendRows,'Location',legLoc,'Orientation','horizontal')
            lgd = legend;
            lgd.NumColumns = 1;
        end

    %     legendlocation = 'northeast';
    %     legend([pcat_line,pcat1,pcat2,pcat3], {'p > 0.05', 'p <= 0.05 && p > 0.01', 'p <= 0.01 && p > 0.001', 'p <= 0.001'},'Location',legendlocation,'Orientation','horizontal')
    % %     legend([pcat_line,pcat1,pcat2], {'p > 0.05', 'p <= 0.05 && p > 0.01', 'p <= 0.01 && p > 0.001'},'Location',legendlocation,'Orientation','horizontal')
    % % %     legend([pcat_line,pcat1], {'p > 0.05', 'p <= 0.05 && p > 0.01'},'Location',legendlocation,'Orientation','horizontal')
    %     lgd = legend;
    %     lgd.NumColumns = 1;
    
        if Config.TimecourseCorrel.OnlySigLines_Enabled
            xlim([0 2500])
            grid minor;
            set(gca,'XGrid','on','YGrid','off')
            set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'off')
            ylim([-0.1 -0.08])
            set(gca, 'YTick', [])
            set(gca, 'XTickLabels', [])
            %
            wideImageSize = get(0, 'Screensize')*0.4;
            wideImageSize(3) = wideImageSize(3)*1.66;
            wideImageSize(4) = wideImageSize(4)*(1/7);
            set(gcf, 'Position', wideImageSize);
        end

        formatOut = 'mm_dd_yy__HH_MM_SS';

        %{
        outFileName = [datestr(datetime('now'), formatOut) 'timecourse-correl_' 'method=' Config.TimecourseCorrel.CorrelMethod '_' 'dep-var=' T_DV.Properties.VariableNames{Config.TimecourseCorrel.DVFrom+dv-1} '_' 'plot-insig=' num2str(Config.TimecourseCorrel.PlotInsig) '.png'];
        ylim([0 0.9]);
%         set(gcf, 'Position', get(0, 'Screensize')*Config.Plots.ScaleFactor);
    wideImageSize = get(0, 'Screensize')*0.4;
    wideImageSize(3) = wideImageSize(3)*1.66;
    set(gcf, 'Position', wideImageSize);

%     xlim([0 2500])
        saveas(gcf,outFileName);
        %}

        OutFilePath = ['~RESULTS/' Meta.RootDirTag '/' 'Timecourse corr maps' ' AlignSR=' num2str(Config.AlignToStimOrResp) ' filt=' num2str(Config.Filter.Behav.Enabled) ' (' Config.Filter.Behav.FriendlyName ')'  '/' ];
        OutFileName = ['Timecourse' '-' Config.TimecourseCorrel.CorrelMethod '_' 'dep-var=' T_DV.Properties.VariableNames{Config.TimecourseCorrel.DVFrom+dv-1} ' filt=' num2str(Config.Filter.Behav.Enabled) ' (' Config.Filter.Behav.FriendlyName ')'  '.png'];

        mkdir(OutFilePath);
        
%         set(gcf, 'Position', get(0, 'Screensize')*0.9);
% %         set(gcf, 'Position', get(0, 'Screensize')*Config.Plots.ScaleFactor);
% % %         pbaspect([1 1 1]) % looks like a square, better readable
        wideImageSize = get(0, 'Screensize')*0.4;
        wideImageSize(3) = wideImageSize(3)*1.66;
        set(gcf, 'Position', wideImageSize);
        saveas(gcf,[OutFilePath OutFileName]);



        clear pcat1_line pcat2_line pcat3_line pcat4_line plotHandlesArray colorLegendRows;

    end

end