function FigHandle = support_PlotGrandERAConf(ERAConfCurves, Config, Meta)
    
    if Config.Plot.GrandERA.EveryParticipant
        for p = 1:size(ERAConfCurves,2)

            yVals = ERAConfCurves(:, p);
            
%             plot_time = 1:length(yVals);
            plot_time = 0:(length(yVals)-1);
            
            FigHandle = plot(plot_time, yVals, 'LineWidth', 2);
        
            % Transform to milliseconds
            set(FigHandle, 'XData', (get(FigHandle, 'XData')-1) / Meta.NomSRate * 1000 + Config.AnalyzeFromSec*1000);

        end

    else
        
%         PUPSIZE_CURVE_GRAND = NaN(Config.AnalyzeLenSample, 1);
%         PUPSIZE_CURVE_GRAND(1:Config.AnalyzeLenSample, 1) = mean(TEPRCurves, 2, 'omitnan');
        ERAConfCurves_GRAND = mean(ERAConfCurves, 2, 'omitnan');

        yVals = ERAConfCurves_GRAND;
%         plot_time = 1:length(yVals);
        plot_time = 0:(length(yVals)-1);
        
        if ~isfield(Config.Plots, 'LayeredFigCounter')
            Config.Plots.LayeredFigCounter = 1;
        end
            
        FigHandle = plot(plot_time, ERAConfCurves_GRAND, 'LineWidth', 2)
    
        % Transform to milliseconds
        set(FigHandle, 'XData', (get(FigHandle, 'XData')-1) / Meta.NomSRate * 1000 + Config.AnalyzeFromSec*1000);

    end
    
    if isnan(Config.Plot.GrandTEPR.XLim)
        Config.Plot.GrandTEPR.XLim = [round(Config.AnalyzeFromSec*1000) round(Config.AnalyzeToSec*1000)];
%         Config.Plot.GrandTEPR.XLim = [0 round(Config.AnalyzeToSec*1000)];
    end
    xlim(Config.Plot.GrandTEPR.XLim);

    if isnan(Config.Plot.GrandERA.YLim)
        ylim([0.85 1]);
    end

    if Config.Plots.Grid
        %grid on;
        %grid minor;
		set(gca,'XGrid','on','YGrid','on')
		set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on')
    end
    
    
    if Config.Plots.Markings.Enabled == true && Config.Plots.LayeredFigCounter < 2
        currylim = ylim;
        colorB = [0.3 0.3 0.9];
        yDt = 5;
        for t = (Config.AnalyzeFromSec*1000):(Config.AnalyzeToSec*1000)
%         for t = Config.Plot.GrandTEPR.XLim(1):Config.Plot.GrandTEPR.XLim(2)

            if ~Config.Plots.Markings.OnEdges && (t==Config.Plot.GrandTEPR.XLim(1) || t==Config.Plot.GrandTEPR.XLim(2))
                continue;
            end
            
            if Config.AlignToStimOrResp == true % STIMULUS-ALIGNED
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
            elseif Config.AlignToStimOrResp == false % RESPONSE-ALIGNED
                if Config.Plots.Markings.B && t~=0 && t/(Config.ISISec*1000) == Config.ISISec*1000 + (Config.BaselineFromSec+Config.BaselineToSec)/2*1000
                    xline(t, 'Color', colorB);
                    text(t, currylim(2)-(currylim(2)-currylim(1))/yDt,'B', 'Color', colorB)
                end
                if Config.Plots.Markings.R && t/(Config.ISISec*1000) == 0
                    xline(t, 'Color', colorB);
                    text(t, currylim(2)-(currylim(2)-currylim(1))/yDt,'R', 'Color', colorB)
                end
            end

%             if mod(t, Config.ISISec*1000) == 0
%                 xline(t+ (Config.BaselineFromSec+Config.BaselineToSec)/2*1000, 'Color', colorB);
%                 text(t+ (Config.BaselineFromSec+Config.BaselineToSec)/2*1000, currylim(2)-(currylim(2)-currylim(1))/yDt,'B', 'Color', colorB)
%                 
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
%     title(['ERA confidence averaged across all Participants']);
    xlabel(['Time [ms]']);
    ylabel(['Confidence']);
    
            OutFilePath = ['~RESULTS/' Meta.RootDirTag '/' ];
            if ~exist(OutFilePath, 'dir')
                mkdir(OutFilePath);
            end

            OutFileName = ['ERA_Conf'];
            OutFileName = [OutFileName ' alignSR=' num2str(Config.AlignToStimOrResp)];
            OutFileName = [OutFileName ' filt=' num2str(Config.Filter.Behav.Enabled)];
            OutFileName = [OutFileName ' (' Config.Filter.Behav.FriendlyName ')'];
            if Config.Plot.GrandTEPR.EveryParticipant
                OutFileName = [OutFileName '_EP'];
            end
            OutFileName = [OutFileName '.png'];
            OutFileName = char(OutFileName);
            
    %         set(gcf, 'Position', get(0, 'Screensize'));
            set(gcf, 'Position', get(0, 'Screensize')*Config.Plots.ScaleFactor);
            saveas(gcf,[OutFilePath OutFileName]);
    hold off;
    pause(0.5)

end