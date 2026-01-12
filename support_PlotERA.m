function support_PlotERA(EventDensity, ERAConfCurves, Config, Meta, Participant)
   
    if Config.Plot.ERA.VisualMethod == 0 % kernel density estimation
        [ks_y, ks_x] = ksdensity(EventDensity, 'Bandwidth', Config.Plot.ERA.KDEBandwidth, 'Kernel', 'normal');

        % normalize ks density output
        ks_y = (ks_y - min(ks_y)) / ( max(ks_y) - min(ks_y) );

        plot(ks_x, ks_y, 'LineWidth', 2) %graphLineStyle
    else %if Config.Plot.ERA.VisualMethod == 1
        histogram(EventDensity, Config.Plot.ERA.HistBinWidth)
    end
        
    xlim([Config.AnalyzeFromSec*1000, Config.AnalyzeToSec*1000])
        
    pause(0.5)
    
    % -------------------------------------------------------
    % calculate confidence ERA

    close(gcf);
    figure
    hold on
      
        
    ERAtoPlot = ERAConfCurves(:, Participant.Nr);
    plot_time = 0:(length(ERAConfCurves(:, Participant.Nr))-1);
        
    % TODO: SHORTEN CODE! from now on, almost full of this section is
    % same as TEPR code
    
    if ~exist('TEPR_lineStyle', 'var') %ide majd isfield kell (isfield(behav, 'stimType'))
        TEPR_lineStyle = '-';
        TEPR_lineColor = 'g';
        TEPR_lineWidth = 2.0;
    end

    currentPlot = plot(plot_time, ERAtoPlot, TEPR_lineStyle, 'Color', TEPR_lineColor, 'LineWidth', TEPR_lineWidth);

    % Transform to milliseconds
    set(currentPlot, 'XData', (get(currentPlot, 'XData')-1) / Meta.NomSRate * 1000 + Config.AnalyzeFromSec*1000);
        
    if ~isnan(Config.Plot.ERA.YLim)
        ylim(Config.Plot.ERA.YLim);
    end
    
    if isnan(Config.Plot.TEPR.XLim)
%         Config.Plot.TEPR.XLim = [round(Config.AnalyzeFromSec*1000) round(Config.AnalyzeToSec*1000)];
        Config.Plot.TEPR.XLim = [0 round(Config.AnalyzeToSec*1000)];
    end
    xlim(Config.Plot.TEPR.XLim);
    
    % todo: analĂłgra Ăˇt kell Ă­rni
% % %     xline(round(stimPresentedAtSec*1000)); % stim prez
    
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
   %  title(['TEPR curve averaged across all Participants']);
    xlabel(['Time [ms]']);
    ylabel(['Confidence']);
        
        
    OutFilePath = char([ ...
        '~RESULTS/' Meta.RootDirTag '/' ...
        'ERA each iteration' ...
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