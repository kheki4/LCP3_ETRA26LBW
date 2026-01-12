function support_Plot2D(xdata, ydata, participantName, plotYdim, plotYrange, movAvg)

    experimentDurMinutes = (xdata(length(xdata)) - xdata(1)) /1000 /1000 /60;
    
    % Kell, mert egyelőre a support_drawPlotMinute csak akkor mutat jó számokat, 
    % ha az adatok 0 xdatatől kezdődnek
%     xdata = dataQuality_alignTimeStart(xdata, 0);
    xdata = xdata - xdata(1);
    
    
    support_drawPlot2D(xdata, ydata, experimentDurMinutes, plotYdim, plotYrange); %y tengely felirata jelezhetné, hogy csak relatív pixelméret
%     outFileName = char(strcat(participantName, '_', plotYdim, '_full.png'));
    
    if isnumeric(movAvg) && length(movAvg) == 1 && movAvg ~= 0
        hold on;
        plot(xdata, movmean(ydata, movAvg));
        hold off;
%         outFileName = char(strcat(participantName, '_', plotYdim, '_full_movAvg=', num2str(movAvg), '.png'));
    end
    
    grid on;
    %grid minor;
	set(gca,'XGrid','on','YGrid','on')
	set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on')
%     set(gcf, 'Position', get(0, 'Screensize')*0.6);
%     saveas(gcf,outFileName);
    
end