% function support_drawSpect(pupdil, winfun, winsize, srate)
function support_drawSpect(pupdil, winfun, winsize, noverlap, srate)

%     winfun = 'rectwin';
%     winsize = 5000; %% [samples]
%     srate = 500; %% [Hz]

    % ha az overlap winsize-1000, akkor 
    % ha 1 [sec] adat 500 mintavételben van tárolva, akkor
    % 1000/500 = 2 [sec] nem lóg egybe az ablakok közt, és
    % (winsize-1000)/500 [sec] az overlap által felölelt idő
    
%     shift = ceil(length(pupdil)/150);
%     %shift = 5;
%     noverlap = winsize-shift;
    nfft = winsize;
    
    spectrogram(pupdil, feval(winfun, winsize), noverlap, nfft, srate, 'yaxis');
    % % ylim([0 2]);
    
end