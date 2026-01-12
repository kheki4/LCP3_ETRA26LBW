function FigHandle = support_PlotGrandTEPR(TEPRCurves, Config, Meta)
    
    if ~isfield(Config.Plots, 'Layered') || ~Config.Plots.Layered
        close(gcf);
        figure
        hold on
    end

    if ~isfield(Config.Plot.GrandTEPR, 'LineStyle') % ide majd ilyen kell isfield(behav, 'stimType')
        Config.Plot.GrandTEPR.LineStyle = '-';
    end
    if ~isfield(Config.Plot.GrandTEPR, 'LineColor') % ide majd ilyen kell isfield(behav, 'stimType')
        Config.Plot.GrandTEPR.LineColor = 'g';
    end
    Config.Plot.GrandTEPR.LineWidth = 2.0;


    if Config.Plot.GrandTEPR.EveryParticipant
        for p = 1:size(TEPRCurves,2)

            yVals = TEPRCurves(:, p);
    
            % kell ez ?
            % if the curve should be baseline corrected
            yVals = ...
                yVals - ...
                mean(yVals(Config.BaselineFromSampleMapped:Config.BaselineToSampleMapped, 1), 'omitnan');
    
%             plot_time = 1:length(yVals);
            plot_time = 0:(length(yVals)-1);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            FigHandle = figure();

            breaks = [0 3 6 9 12 15 18 21];

            bcolors = {
                [0 0 0]; % black
                [0/255 255/255 255/255]; % light sky blue
                [0/255 128/255 255/255]; % deep sky blue
                [153/255 102/255 255/255]; % light purple
                [205/255 0/255 205/255]; % rose purple
                [0/255 255/255 0/255]; % green
                [0.4660 0.6740 0.1880]; % dark green
            };


            for bbb = 1:(length(breaks)-1)
                fromS = Config.AnalyzeFromSample - round(Meta.NomSRate*breaks(bbb));
                toS = Config.AnalyzeFromSample - round(Meta.NomSRate*breaks(bbb+1));
                plot(plot_time(fromS:toS), yVals(fromS:toS), Config.Plot.GrandTEPR.LineStyle, bcolors{bbb}, Config.Plot.GrandTEPR.LineColor, 'LineWidth', Config.Plot.GrandTEPR.LineWidth);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Transform to milliseconds
            set(FigHandle, 'XData', (get(FigHandle, 'XData')-1) / Meta.NomSRate * 1000 + Config.AnalyzeFromSec*1000);

        end

    else
    
        %----------------------------------------------
        % TODO: ĂˇttehetĹ‘ sima kĂłdba, ne itt a plottolĂłban legyen
        
%         TEPRCurves_GRAND = NaN(trial_length, 1);
%         TEPRCurves_GRAND(1:trial_length, 1) = mean(TEPRCurves, 2, 'omitnan');
        TEPRCurves_GRAND = mean(TEPRCurves, 2, 'omitnan');
    
        % if the curve should be baseline corrected
        TEPRCurves_GRAND = ...
            TEPRCurves_GRAND - ...
            mean(TEPRCurves_GRAND(Config.BaselineFromSampleMapped:Config.BaselineToSampleMapped, 1), 'omitnan');
        %----------------------------------------------

        yVals = TEPRCurves_GRAND;
%         plot_time = 1:length(yVals);
        plot_time = 0:(length(yVals)-1);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            FigHandle = figure();

            breaks = [0 3 6 9 12 15 18 21];

            bcolors = {
                [0 0 0]; % black
                [0/255 255/255 255/255]; % light sky blue
                [0/255 128/255 255/255]; % deep sky blue
                [153/255 102/255 255/255]; % light purple
                [205/255 0/255 205/255]; % rose purple
                [0/255 255/255 0/255]; % green
                [0.4660 0.6740 0.1880]; % dark green
            };

            hold on
            for bbb = 1:(length(breaks)-1)
                fromS = -1*Config.AnalyzeFromSample + round(Meta.NomSRate*breaks(bbb));
                toS = -1*Config.AnalyzeFromSample + round(Meta.NomSRate*breaks(bbb+1));
                FigHandleLine = plot(plot_time(fromS:toS), transpose(yVals(fromS:toS)), Config.Plot.GrandTEPR.LineStyle, 'Color', bcolors{bbb}, 'LineWidth', Config.Plot.GrandTEPR.LineWidth);
                % Transform to milliseconds
                set(FigHandleLine, 'XData', (get(FigHandleLine, 'XData')-1) / Meta.NomSRate * 1000 + Config.AnalyzeFromSec*1000);
            end
            hold off

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
% % %     %     plot(plot_time, TEPRCurves_GRAND, grandTEPR_lineStyle)
% % %         FigHandle = plot(plot_time, TEPRCurves_GRAND, Config.Plot.GrandTEPR.LineStyle, 'Color', Config.Plot.GrandTEPR.LineColor, 'LineWidth', Config.Plot.GrandTEPR.LineWidth);
% % % %         grandTEPR(layeredFigCounter) = FigHandle;
% % %     
% % %         % Transform to milliseconds
% % %         set(FigHandle, 'XData', (get(FigHandle, 'XData')-1) / Meta.NomSRate * 1000 + Config.AnalyzeFromSec*1000);

    end
    
    if isnan(Config.Plot.GrandTEPR.XLim)
        Config.Plot.GrandTEPR.XLim = [round(Config.AnalyzeFromSec*1000) round(Config.AnalyzeToSec*1000)];
%         Config.Plot.GrandTEPR.XLim = [0 round(TimeDefs.AnalyzeToSec*1000)];
    end
    xlim(Config.Plot.GrandTEPR.XLim);


    % TODO: analógra átirni
% %     xline(round(stimPresentedAtSec*1000)); % stim prez
    

    if ~isnan(Config.Plot.GrandTEPR.YLim)
        ylim(Config.Plot.GrandTEPR.YLim);
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
    if Config.Z_norm_method == 0
        if Meta.Flag_PXorMM == 1
            ylabel(['Pupil size [px]']);
        else
            ylabel(['Pupil size [mm]']);
        end
    else
        ylabel(['Pupil size [a.u.]']);
    end

    %ax = ancestor(FigHandle, 'axes');
    ax = gca;
    if ax.XAxis.Exponent >= 3
        ax.XAxis.Exponent = 3;
    else
        ax.XAxis.Exponent = 0;
    end
    xtickformat('%.0f');
    
            OutFilePath = ['~RESULTS/' Meta.RootDirTag '/' ];
            if ~exist(OutFilePath, 'dir')
                mkdir(OutFilePath);
            end

            OutFileName = ['TEPR'];
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