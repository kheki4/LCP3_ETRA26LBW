function support_drawSpect_own_colorlim(P, winsize, noverlap, srate, numSamples, lengthTimeFull, inLogScale, colorBounds)

    %% setting Z (alias C) axis (= color axis)
    cb = colorbar;
%     if inLogScale
%         caxis(colorBoundsLOG);
%     else
%         caxis(colorBoundsLIN);
%     end
%     caxis([-150 30]);
    ylabel(cb, 'Power / frequency [dBmm / Hz]');
%     ylabel(cb, 'Teljesítmény / frekvencia [dBpx / Hz]');
    
    
    %1. figure mentése
%     ylim([0 2]);
    if inLogScale == true
        colormap parula;
        set(gca,'ColorScale','log'); %TALÁN CSAK AZ ERDETI spectrogram() esetén volt rá szükség ??
        ch = colorbar;
%         ch.Ticks = [5, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100, 150, 200]; % nagyon régi
        ch.Ticks = [0.5, 1, 2, 2.5, 5, 8, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100, 150, 200]; % MST régi tornyos
%         ch.Ticks = [0.5, 1, 2, 5, 8, 10]; % MST dip
        colorTitleHandle = get(ch,'Label'); %másként eltünteti (egyszerűen kiüríti a változót, és eltünteti a feliratot a plotról, amint lekérdezem változóként)
% %         set(colorTitleHandle ,'String','Teljesítmény / frekvencia [dBpx / Hz]');
%         set(colorTitleHandle ,'String','Power / frequency [dBpx / Hz]');
        set(colorTitleHandle ,'String','Power / frequency [dBmm / Hz]');
        
        %caxis([0 0.5]); % nem tornyos esetén jobb
%         caxis(colorBoundsLOG);
     %   caxis([0 25]); % fontos, hogy az összes generált plot azonos színskála határok közt legyen
%     else
%         caxis(colorBoundsLIN);
     %   caxis([-150 30]);
    end
    
    caxis(colorBounds);
end