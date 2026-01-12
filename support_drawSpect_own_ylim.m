function support_drawSpect_own_ylim(P, winsize, noverlap, srate, numSamples, lengthTimeFull, inLogScale, ylim_desired)

    %% mapping Y
%     ylim_desired = [0 2];

%Azert kell a +1 mert a tomb elemeit indexeli, es az a matlabban 1-gyel kezdodik
%És azért kell +0.5, mert az elemeket elcsúsztatva mutatja a matlab,
% eredetileg is, a frek. tengelyen (a színes téglalap ami egy pontnak felel
% meg, pl a ~0 hz-nél az x tengelyre kell essen (központosan) 
    ylim_mapped = ylim_desired.*(size(P,1)/(srate/2)) +1 +0.5; 
    ylim(ylim_mapped);
    
%     yticks_desired = linspace(ylim_desired(1), ylim_desired(2), 17); %0:0.5:2; %régen 9-re osztottam
    yticks_desired = linspace(ylim_desired(1), ylim_desired(2), 11); %0:0.5:2; %régen 9-re osztottam
    yticks_mapped = yticks_desired.*(size(P,1)/(srate/2))+1; %azert kell a +1 mert a tomb elemeit indexeli, es az a matlabban 1-gyel kezdodik
    yticks(yticks_mapped);
    
    yticklabels(yticks_desired);
%     ylabel('Frekvencia [Hz]');
    ylabel('Frequency [Hz]');
end