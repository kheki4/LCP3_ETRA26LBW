function support_PlotTEPR(TrialsArray, TEPRCurves, ERLEveryTrial, Config, Meta, Participant, excludedTrials)
   
    close(gcf);
    figure
    hold on

    if Config.Plot.TEPR.EveryTrial
        for p = 1:size(TrialsArray,2)
    
            plotVals = TrialsArray(:,p);
%             plot_time = 1:length(plotVals);
            plot_time = 0:(length(plotVals)-1);

            if excludedTrials(p)
                graphLineStyle = '-b';
            else
                graphLineStyle = '-g';
            end
            
%             if Filter.Phase.ExcludedMask(labelAt, p) || Filter.SD.ExcludedMask(1, p)
%                 graphLineStyle = '-b';
%             else
%                 graphLineStyle = '-g';
%             end

            currentPlot = plot(plot_time , plotVals, graphLineStyle);

            % Transform to milliseconds
            set(currentPlot, 'XData', (get(currentPlot, 'XData')-1) / Meta.NomSRate * 1000 + Config.AnalyzeFromSec*1000);

            % plot separately, transformed
            if Config.ERL.Enabled
                xline(ERLEveryTrial(Participant.Nr, p));
            end

%             % DEV
%             ylim(Config.Plot.TEPR.YLim);
        end
    else
        
        TEPRtoPlot = TEPRCurves(:, Participant.Nr); % - mean(TEPRCurves(Config.BaselineFromSampleMapped:Config.BaselineToSampleMapped, Participant.Nr), 'omitnan');
        plot_time = 0:(length(TEPRCurves(:, Participant.Nr))-1);
    
        if ~exist('TEPR_lineStyle', 'var') %ide majd isfield kell (isfield(behav, 'stimType'))
            TEPR_lineStyle = '-';
            TEPR_lineColor = 'g';
            TEPR_lineWidth = 2.0;
        end
    
        currentPlot = plot(plot_time, TEPRtoPlot, TEPR_lineStyle, 'Color', TEPR_lineColor, 'LineWidth', TEPR_lineWidth);

        % plot separately, transformed
        if Config.ERL.Enabled
            xline(mean(ERLEveryTrial(Participant.Nr, :), 'omitnan'));
        end

        % Transform to milliseconds
        set(currentPlot, 'XData', (get(currentPlot, 'XData')-1) / Meta.NomSRate * 1000 + Config.AnalyzeFromSec*1000);

    end
        
    if isfield(Config.Plot.TEPR, 'YLim') & ~isnan(Config.Plot.TEPR.YLim)
        ylim(Config.Plot.TEPR.YLim);
    end
   
    if isnan(Config.Plot.TEPR.XLim)
%         Config.Plot.TEPR.XLim = [round(Config.AnalyzeFromSec*1000) round(Config.AnalyzeToSec*1000)];
        Config.Plot.TEPR.XLim = [0 round(Config.AnalyzeToSec*1000)];
    end
    xlim(Config.Plot.TEPR.XLim);
    
    if Config.Plots.Grid
        %grid on;
        %grid minor;
		set(gca,'XGrid','on','YGrid','on')
		set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on')
    end  
    
    if Config.Plots.Markings.Enabled == true
        currylim = ylim;
        colorB = [0.3 0.3 0.9];
        yDt = 5;
        for t = (Config.AnalyzeFromSec*1000):(Config.AnalyzeToSec*1000) 
%         for t = Config.Plot.TEPR.XLim(1):Config.Plot.TEPR.XLim(2)

            if ~Config.Plots.Markings.OnEdges && (t==Config.Plot.TEPR.XLim(1) || t==Config.Plot.TEPR.XLim(2))
                continue;
            end
                
            if Config.Plots.Markings.B && t~=0 && mod(t, Config.ISISec*1000) == Config.ISISec*1000 + (Config.BaselineFromSec+Config.BaselineToSec)/2*1000
                xline(t, 'Color', colorB);
                text(t, currylim(2)-(currylim(2)-currylim(1))/yDt,'B', 'Color', colorB)
            end
            if Config.Plots.Markings.S && mod(t, Config.ISISec*1000) == 0
                % todo: ONLY IF STIMULUS-ALIGNED
                xline(t, 'Color', colorB);
                text(t, currylim(2)-(currylim(2)-currylim(1))/yDt,'S', 'Color', colorB)
            end
            if Config.Plots.Markings.F && t~=0 && mod(t, Config.ISISec*1000) == Config.ISISec*1000 - Config.FixBeforeStimSec*1000
                xline(t, 'Color', colorB);
                text(t, currylim(2)-(currylim(2)-currylim(1))/yDt,'F', 'Color', colorB)
            end

%             if mod(t, Config.ISISec*1000) == 0
%                 xline(t+ (Config.BaselineFromSec+Config.BaselineToSec)/2*1000, 'Color', colorB);
%                 text(t+ (Config.BaselineFromSec+Config.BaselineToSec)/2*1000, currylim(2)-(currylim(2)-currylim(1))/yDt,'B', 'Color', colorB)
%                     
%                 % todo: ONLY IF STIMULUS-ALIGNED
%                 xline(t, 'Color', colorB);
%                 text(t, currylim(2)-(currylim(2)-currylim(1))/yDt,'S', 'Color', colorB)
%                 
%                 xline(t -Config.FixBeforeStimSec*1000, 'Color', colorB);
%                 text(t -Config.FixBeforeStimSec*1000, currylim(2)-(currylim(2)-currylim(1))/yDt,'F', 'Color', colorB)
%                     
%             end
        end
    end
    
    set(gcf, 'Position', get(0, 'Screensize')*Config.Plots.ScaleFactor);
%     title(['TEPR curve averaged across all Participants']);
    xlabel(['Time [ms]']);
    if Config.Z_norm_method == 0
        if Meta.Flag_PXorMM == 1
            ylabel(['Pupil size [px]']);
        else
            ylabel(['Pupil size [mm]']);
        end
    else
        ylabel(['Pupil size [a.u.]']);
    end     

    OutFilePath = char([ ...
        '~RESULTS/' Meta.RootDirTag '/' ...
        'TEPR each iteration' ...
        ' alignSR=' num2str(Config.AlignToStimOrResp) ...
        ' filt=' num2str(Config.Filter.Behav.Enabled) ...
        ' (' Config.Filter.Behav.FriendlyName ')' ...
        '/']);
        
    if ~exist(OutFilePath, 'dir')
        mkdir(OutFilePath);
    end

    OutFileName = char([ ...
        Participant.ID '_response_each-iter' ...
        ' alignSR=' num2str(Config.AlignToStimOrResp) ...
        ' filt=' num2str(Config.Filter.Behav.Enabled) ...
        ' (' Config.Filter.Behav.FriendlyName ')' ...
        '.png']);

  %   set(gcf, 'Position', get(0, 'Screensize'));
    set(gcf, 'Position', get(0, 'Screensize')*Config.Plots.ScaleFactor);
    saveas(gcf,[OutFilePath OutFileName]);

    hold off;
    pause(0.5)

end