function support_drawSpect_own_xlim(P, winsize, noverlap, srate, numSamples, lengthTimeFull, inLogScale, xlim_desired)

    %% mapping X
%     xlim_desired = [0 lengthTimeFull]; %in seconds
    
    if xlim_desired(2)-xlim_desired(1) < 60
        xticks_desired = 0:0.2:(lengthTimeFull-mod(lengthTimeFull, 0.2));
    elseif xlim_desired(2)-xlim_desired(1) >= 60 && xlim_desired(2)-xlim_desired(1) < 60*7
        xticks_desired = 0:30:(lengthTimeFull-mod(lengthTimeFull, 30));
    elseif xlim_desired(2)-xlim_desired(1) >= 60*7 && xlim_desired(2)-xlim_desired(1) < 60*15
        xticks_desired = 0:60:(lengthTimeFull-mod(lengthTimeFull, 60));
    elseif xlim_desired(2)-xlim_desired(1) >= 60*15
        xticks_desired = 0:120:(lengthTimeFull-mod(lengthTimeFull, 120));
    else
        xticks_desired = [0 lengthTimeFull];
    end
%     xticks_desired = 0:30:(lengthTimeFull-mod(lengthTimeFull, 60));
    xticks_sampleMapped = zeros(1, length(xticks_desired));
    xticks_mapped = zeros(1, length(xticks_desired));
    for i=1:length(xticks_desired)
        xticks_sampleMapped(i) = (xticks_desired(i)/lengthTimeFull*numSamples);
        xticks_mapped(i) = (xticks_sampleMapped(i)-noverlap)/(winsize-noverlap); %azert kell a +1 mert a tomb elemeit indexeli, es az a matlabban 1-gyel kezdodik
    end
    xticks_mapped = xticks_mapped + abs(xticks_mapped(1)/2);
    xticks(xticks_mapped);
    
    xticklabels(xticks_desired);
%     xlabel('Idő [sec]');
    xlabel('Time [sec]');
end