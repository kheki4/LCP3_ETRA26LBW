function support_PlotGrandERADensity(ERAEventDensity_grand, Config, Meta)

    if Config.Plot.ERA.VisualMethod == 0 % kernel density estimation
        [ks_y, ks_x] = ksdensity(ERAEventDensity_grand, 'Bandwidth', Config.Plot.ERA.KDEBandwidth, 'Kernel', 'normal');

        % normalize ks density output
        ks_y = (ks_y - min(ks_y)) / ( max(ks_y) - min(ks_y) );

        plot(ks_x, ks_y, 'LineWidth', 2) %graphLineStyle
    else %if Config.Plot.ERA.VisualMethod == 1
        histogram(ERAEventDensity_grand, Config.Plot.ERA.HistBinWidth)
    end
    
    xlim([Config.AnalyzeFromSec*1000, Config.AnalyzeToSec*1000])

    

    if Config.Plots.Markings.Enabled == true && Config.Plots.LayeredFigCounter < 2
        currylim = ylim;
        colorB = [0.3 0.3 0.9];
        yDt = 5;
        for t = (Config.AnalyzeFromSec*1000):(Config.AnalyzeToSec*1000)
%         for t = grandTEPR_xlim(1):grandTEPR_xlim(2)

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
                if Config.Plots.Markings.F && t~=0 && mod(t, Config.ISISec*1000) == Config.ISISec*1000 - fixBeforeStimSec*1000
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

%             if mod(t, TimeDefs.ISISec*1000) == 0
%                 xline(t+ (TimeDefs.BaselineFromSec+TimeDefs.BaselineToSec)/2*1000, 'Color', colorB);
%                 text(t+ (TimeDefs.BaselineFromSec+TimeDefs.BaselineToSec)/2*1000, currylim(2)-(currylim(2)-currylim(1))/yDt,'B', 'Color', colorB)
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
%     title(['TEPR curve averaged across all Participants']);
    xlabel(['Time [ms]']);
    if Config.Plot.ERA.VisualMethod == 0 % kernel density estimation
        ylabel(['Normalized KDE event density']);
    else %if Config.Plot.ERA.VisualMethod == 1
        ylabel(['Event density (frequency)']);
    end

    %grid on
    %grid minor
	set(gca,'XGrid','on','YGrid','on')
	set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on')


        OutFilePath = ['~RESULTS/' Meta.RootDirTag '/' ];
            if ~exist(OutFilePath, 'dir')
                mkdir(OutFilePath);
            end

            OutFileName = ['ERA_Dens'];
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