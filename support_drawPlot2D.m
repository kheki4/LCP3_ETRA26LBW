function support_drawPlot2D(xdata, ydata, minutes, plotYdim, plotYrange)
    %hold on;
    plot(xdata, ydata);
    
    
    
    
    
    xlim([ xdata(1) (xdata(1)+minutes*60*1000*1000) ]) %% így 1 perc anyagát látjuk

%     disp(xdata(1));
%     disp((xdata(1)+minutes*60*1000*1000));

    eredeti_xticks = xticks;
    step = eredeti_xticks(2) - eredeti_xticks(1);
    % a plotról épp lelógó, de kizoomoláskor láthatóvá váló osztásokat is meg kell csinálni,
    % szóval az épp láthatónak a 20szorosa számú tick csak elég kell legyen  
    nsteps = length(eredeti_xticks) * 20;

    ujtick = double(nsteps); %új stepeket tartalmazó cell array
    tval = eredeti_xticks(1);
    for i=1:nsteps
        ujtick(i) = tval;
        tval = tval + step;
    end
    xticks(ujtick);

    ujlabel = cell(nsteps); %új stepeket tartalmazó cell array
    cval = 0;
    for i=1:nsteps
        ujlabel(i) = num2cell(cval);
        cval = cval + step /1000 /1000;
    end
    xticklabels(ujlabel);

    %ylabel('mm');
    xlabel('Time [sec]');
    
    ylabel(plotYdim);
    if ~isnan(plotYrange)
        ylim(plotYrange);
    end
    
end
