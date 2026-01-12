%function support_drawSpect_own(P, noverlap, srate, lengthTimeFull, inLogScale, colorBoundsLIN, colorBoundsLOG)
function support_drawSpect_own(P, winsize, noverlap, srate, numSamples, lengthTimeFull, inLogScale)

    
%     expectedSTFToutSize = floor( (numSamples - noverlap)/(winsize - noverlap) );
%     disp(expectedSTFToutSize);
    
    
    
    % FONTOS! A Matlab nem adja ki azokat az oszlopokat az STFT eredménymátrixában, 
    % amiknél az ablak még nincs teljesen rácsúszva az adatra, vagy már egy eltolásnyival is lecsúszott róla
    % emiatt a spektrogram időtengelye nem 0-tól kezdődik és a jel idővégéig tart, hanem 0+shiftideje -kor kezdődik
    % és idővég-shiftideje -ig tart...
    
    %% draw Spectrogram
    if inLogScale
        % Matlab 'bug': pcolor draws the spectrum heatmap over the ticks and grid.. so we need to bring those to the top later
        h = pcolor(1/2*P); %amúgy csak simán P, ez az 1/2 csak kísérletezés
    else
        h = pcolor(10*log10(P));
    end
    
    set(h,'EdgeColor','none');
    set(gca, 'Layer', 'top');
    
    
    
%     %% mapping Y
% %     ylim_desired = [0 2];
%     ylim_mapped = ylim_desired.*(size(P,1)/(srate/2))+1; %azert kell a +1 mert a tomb elemeit indexeli, es az a matlabban 1-gyel kezdodik
%     ylim(ylim_mapped);
%     
%     yticks_desired = linspace(ylim_desired(1), ylim_desired(2), 9); %0:0.5:2;
%     yticks_mapped = yticks_desired.*(size(P,1)/(srate/2))+1; %azert kell a +1 mert a tomb elemeit indexeli, es az a matlabban 1-gyel kezdodik
%     yticks(yticks_mapped);
%     
%     yticklabels(yticks_desired);
%     ylabel('Frequency [Hz]');
    
%     %% setting Z (alias C) axis (= color axis)
%     cb = colorbar;
% %     if inLogScale
% %         caxis(colorBoundsLOG);
% %     else
% %         caxis(colorBoundsLIN);
% %     end
% %     caxis([-150 30]);
%     ylabel(cb, 'Power/frequency [dB/Hz]');
    
    
    
    
    
    
%     %% mapping X
% %     xlim_desired = [0 lengthTimeFull]; %in seconds
%     
%     if xlim_desired(2)-xlim_desired(1) < 60
%         xticks_desired = 0:0.2:(lengthTimeFull-mod(lengthTimeFull, 0.2));
%     elseif xlim_desired(2)-xlim_desired(1) >= 60 && xlim_desired(2)-xlim_desired(1) < 60*7
%         xticks_desired = 0:30:(lengthTimeFull-mod(lengthTimeFull, 30));
%     elseif xlim_desired(2)-xlim_desired(1) >= 60*7 && xlim_desired(2)-xlim_desired(1) < 60*15
%         xticks_desired = 0:60:(lengthTimeFull-mod(lengthTimeFull, 60));
%     elseif xlim_desired(2)-xlim_desired(1) >= 60*15
%         xticks_desired = 0:120:(lengthTimeFull-mod(lengthTimeFull, 120));
%     else
%         xticks_desired = [0 lengthTimeFull];
%     end
% %     xticks_desired = 0:30:(lengthTimeFull-mod(lengthTimeFull, 60));
%     xticks_sampleMapped = zeros(1, length(xticks_desired));
%     xticks_mapped = zeros(1, length(xticks_desired));
%     for i=1:length(xticks_desired)
%         xticks_sampleMapped(i) = (xticks_desired(i)/lengthTimeFull*numSamples);
%         xticks_mapped(i) = (xticks_sampleMapped(i)-noverlap)/(winsize-noverlap); %azert kell a +1 mert a tomb elemeit indexeli, es az a matlabban 1-gyel kezdodik
%     end
%     xticks_mapped = xticks_mapped + abs(xticks_mapped(1)/2);
%     xticks(xticks_mapped);
%     
%     xticklabels(xticks_desired);
%     xlabel('Time [sec]');
    

end
