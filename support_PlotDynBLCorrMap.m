function support_PlotDynBLCorrMap(TEPREveryParticipant, Config, Meta)

    % NOTE: Not intended to be used for p-hacking. This is for exporatory
    % data-driven analyses, mainly to help develop better feature extraction
    % methods for machine learning, for use in between-subjects regression 

    dv_cols = [Config.DynBLCorrMap.DVFrom Config.DynBLCorrMap.DVTo];
    T = readtable(Config.DynBLCorrMap.BehavDF); 
    num_dv = (dv_cols(2)-dv_cols(1)+1);
    
    if Config.DynBLCorrMap.A1Sign == 'any'
        log_w(['No expected sign specified for dynamic baseline corr map correlative tests']);
    end

    for dv = 1:num_dv % cycle through dependent variable

        ErrorsEnc = false;
        
        if Config.DynBLCorrMap.SmallOrLarge
            hmat = Config.AnalyzeLenSample;
            wmat = Config.AnalyzeLenSample;
            blFrom = 1;
            cTo = Config.AnalyzeLenSample;
        else
            hmat = ceil(1.5 *Config.AnalyzeLenSample);
            wmat = ceil(1.5 *Config.AnalyzeLenSample);
            blFrom = (1 -ceil(Config.AnalyzeLenSample/2));
            cTo = (Config.AnalyzeLenSample +ceil(Config.AnalyzeLenSample/2));
        end
        
        correl_map_rho = NaN(hmat, wmat);
        correl_map_pval = NaN(hmat, wmat);
        
        for blAt = blFrom:Config.AnalyzeLenSample % loop to change baseline sample index
%         for blAt = 1:(Config.AnalyzeLenSample +ceil(Config.AnalyzeLenSample/2)) % loop to change baseline sample index

            singleMapTic = tic;
            
            for cAt = 1:cTo

                % skip trivial (repeating) correlations of:
                % lower left triangle
                % upper left triangle
                % upper right triangle
                % lower right triangle
                if (cAt < ceil(Config.AnalyzeLenSample/2) && blAt+cAt < 1 ) || ... 
                    (blAt > cAt) || ... 
                    (blAt > ceil(Config.AnalyzeLenSample/2) && blAt + cAt > 2*Config.AnalyzeLenSample) || ... 
                    (cAt > blAt + Config.AnalyzeLenSample ) 
                    
                    continue;
                end
                subtractFrom = cAt;
                subtractVal = blAt;

                if subtractFrom < 1
                    subtractFrom = subtractFrom + Config.AnalyzeLenSample;
                end
                if subtractVal < 1
                    subtractVal = subtractVal + Config.AnalyzeLenSample;
                end

                if subtractFrom > Config.AnalyzeLenSample
                    subtractFrom = subtractFrom - Config.AnalyzeLenSample;
                end
                if subtractVal > Config.AnalyzeLenSample
                    subtractVal = subtractVal - Config.AnalyzeLenSample;
                end

                statAtDelta = ...
                    TEPREveryParticipant(:, subtractFrom ) - ...
                    TEPREveryParticipant(:, subtractVal );

                try
%                     [RHO,PVAL] = corr(T{:,(dv_cols(1)+dv-1)}, statAtDelta, 'Type', Config.DynBLCorrMap.CorrelMethod, 'rows','complete');
                    if Config.DynBLCorrMap.A1Sign > 0
                        [RHO,PVAL] = corr(T{:,(dv_cols(1)+dv-1)}, statAtDelta, 'Type', Config.DynBLCorrMap.CorrelMethod, 'rows','complete','Tail','right');
                    elseif Config.DynBLCorrMap.A1Sign < 0
                        [RHO,PVAL] = corr(T{:,(dv_cols(1)+dv-1)}, statAtDelta, 'Type', Config.DynBLCorrMap.CorrelMethod, 'rows','complete','Tail','left');
                    elseif Config.DynBLCorrMap.A1Sign == 0
                        [RHO,PVAL] = corr(T{:,(dv_cols(1)+dv-1)}, statAtDelta, 'Type', Config.DynBLCorrMap.CorrelMethod, 'rows','complete');
                    end
                catch ME
                    ErrorsEnc = true;
                    RHO = NaN; PVAL = NaN;
                end

                correl_map_rho(blAt -blFrom+1, cAt) = RHO;
                correl_map_pval(blAt -blFrom+1, cAt) = PVAL;

            end
            clear statAtDelta;
            
            steptime=toc(singleMapTic); % step time
            
            if ( blAt == round(Config.AnalyzeLenSample/50) || mod(blAt, round(Config.AnalyzeLenSample/5) )==0 )
                log_i([ num2str(dv) '@ ' 'Processing at: ' num2str( round(blAt/Config.AnalyzeLenSample*100) ) '%, estimated time remaining: ' num2str( (Config.AnalyzeLenSample-blAt)*steptime ) ' seconds' ]);
            end
            
        end
        clear singleMapTic steptime;

        hck = pcolor(correl_map_rho);
    %     hck = pcolor(correl_map_pval);

        set(hck,'EdgeColor','none');
        set(gca, 'Layer', 'top');
    %     ylim([-1 1]);
        
        xticks_desired = 0:Config.Plot.DynBLCorrMap.XTickInt:( (Config.AnalyzeLenSample/Meta.NomSRate)-mod( (Config.AnalyzeLenSample/Meta.NomSRate), Config.Plot.DynBLCorrMap.XTickInt));
        xticks_sampleMapped = zeros(1, length(xticks_desired));
        for i=1:length(xticks_desired)
            xticks_sampleMapped(i) = (xticks_desired(i)/(Config.AnalyzeLenSample/Meta.NomSRate) *Config.AnalyzeLenSample);
        end
        xticks_sampleMapped = xticks_sampleMapped + abs(xticks_sampleMapped(1)/2) -Config.AnalyzeFromSample;
        
%         for i=1:length(xticks_sampleMapped)
%             xp = [xticks_sampleMapped(i) xticks_sampleMapped(i)];
%             yp = [xticks_sampleMapped(i) Config.AnalyzeLenSample];
%             line(xp, yp, 'Color', [0.8 0.8 0.8], 'LineWidth', 1);
% %             xticks_sampleMapped(i) = (xticks_desired(i)/(Config.AnalyzeLenSample/Meta.NomSRate) *Config.AnalyzeLenSample);
%         end

        if Config.Plots.Markings.Enabled == true
            grayB = 0.7;
            for s = 0:(Config.AnalyzeLenSample-1)
                % NOTE: BUG FOUND HERE ON 2025.12.14.: "s-" was used instead of "s+" ... I do not know why.
                if mod(s+Config.AnalyzeFromSample, Config.ISISample) == 0 

                    if Config.AlignToStimOrResp == true % STIMULUS ALIGNED
                        xline(s, 'Color', [grayB grayB grayB]);
                        yline(s, 'Color', [grayB grayB grayB]);
                        text((s)-round(Config.AnalyzeLenSample/40),(s)+round(Config.AnalyzeLenSample/40),'S', 'Color', [grayB grayB grayB])

                        xline(s-Config.FixBeforeStimSample, 'Color', [grayB grayB grayB]);
                        yline(s-Config.FixBeforeStimSample, 'Color', [grayB grayB grayB]);
                        text((s-Config.FixBeforeStimSample)-round(Config.AnalyzeLenSample/40),(s-Config.FixBeforeStimSample)+round(Config.AnalyzeLenSample/40),'T', 'Color', [grayB grayB grayB])

                    else % RESPONSE ALIGNED
                        xline(s, 'Color', [grayB grayB grayB]);
                        yline(s, 'Color', [grayB grayB grayB]);
                        text((s)-round(Config.AnalyzeLenSample/40),(s)+round(Config.AnalyzeLenSample/40),'R', 'Color', [grayB grayB grayB])
                    end

                    
                end

            end
        end
        
        if ErrorsEnc
            log_w(['Could not compute correlation in at least one point']);
        end
        
        
        xticks(xticks_sampleMapped);
        xticklabels(xticks_desired);
        xlabel(['Timepoint of value correlated [sec]']);

        yticks(xticks_sampleMapped);
        yticklabels(xticks_desired);
%         yline(stimPresentedAtSec *Meta.NomSRate);
        ylabel(['Timepoint of baseline [sec]']);

        % if y axis is better on the right
%         set(gca, 'YAxisLocation', 'right');
        
        hcb = colorbar;
        % if color bar on the left
%         set(hcb, 'Location', 'westoutside');
        colormap(parula(256));
        caxis([-0.8 0.8]);

        hold on
        visboundaries(correl_map_pval<=0.05, 'Color', [0.8500 0.3250 0.0980], 'EnhanceVisibility',false);
        visboundaries(correl_map_pval<=0.01, 'Color', [0.4660 0.6740 0.1880], 'EnhanceVisibility',false);
        visboundaries(correl_map_pval<=0.001, 'Color', [0.6350 0.0780 0.1840], 'EnhanceVisibility',false);
        hold off
        
        title(strrep(['Baseline corrected TEPR value (' Config.Filter.Behav.FriendlyName ') x ' T.Properties.VariableNames{Config.DynBLCorrMap.DVFrom+dv-1}],'_','-'));
        OutFilePath = ['~RESULTS/' Meta.RootDirTag '/' 'TEPR dyn baseline corr maps' ' AlignSR=' num2str(Config.AlignToStimOrResp) ' filt=' num2str(Config.Filter.Behav.Enabled) ' (' Config.Filter.Behav.FriendlyName ')'  '/' ];
        OutFileName = ['TEPR-corrmap' '-' Config.DynBLCorrMap.CorrelMethod '_' 'dep-var=' T.Properties.VariableNames{Config.DynBLCorrMap.DVFrom+dv-1} ' filt=' num2str(Config.Filter.Behav.Enabled) ' (' Config.Filter.Behav.FriendlyName ')'  '.png'];
                

        % DEV
        % dirty trick to only show time section beginning from 0 to end
        % TODO. only calculate to-be-shown region in order to spare CPU and time
        xlim([-Config.AnalyzeFromSample Config.AnalyzeLenSample])
        ylim([-Config.AnalyzeFromSample Config.AnalyzeLenSample])
        % IMPORTANT
        % TODO:
        % the "whole" map verison might be wrong currently! (does it use
        % analytic from sample or from 0 ?)


        mkdir(OutFilePath);
        
        set(gcf, 'Position', get(0, 'Screensize')*0.9);
%         set(gcf, 'Position', get(0, 'Screensize')*Config.Plots.ScaleFactor);
        pbaspect([1 1 1]) % looks like a square, better readable
        saveas(gcf,[OutFilePath OutFileName]);

    end
    
end