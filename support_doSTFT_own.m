function [S,F,T,P] = support_doSTFT_own(xdata, ydata, srate)

    winsize = ceil(length(xdata)/10);
    %elemenként kivonjuk az átlagot, ez eltűnteti a hatalmas DC komponenst az FFT-ből. 
    % (az olyan jel esetén, ahol valami kiugrás, adat hibája adott szakaszon kitolja a jel átlagját, 
    % a 0 közeli frekvencián továbbra is max magnitúdójú komponens lesz látható)
    ydata = ydata-mean(ydata); 
    
%     winfun = 'rectwin';
%     winsize = 5000; %% [samples]
%     srate = 500; %% [Hz]

    % ha az overlap winsize-1000, akkor 
    % ha 1 [sec] adat 500 mintavételben van tárolva, akkor
    % 1000/500 = 2 [sec] nem lóg egybe az ablakok közt, és
    % (winsize-1000)/500 [sec] az overlap által felölelt idő
    
    shift = ceil(length(ydata)/150);
    noverlap = winsize-shift;
    nfft = winsize;
    [S,F,T,P] = spectrogram(ydata, rectwin(winsize), noverlap, nfft, srate, 'yaxis');
    
end