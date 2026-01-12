function [p_timestamp, p_pupdil, new_srate] = DQ_Resample(timestamp, pupdil, target_srate)

    orig_srate = 1 / median(diff(timestamp))*1000*1000;
    
    dataLengthTime = max(timestamp) - min(timestamp); %% [microsec] = 1/1000 [millisec]
    
%   orig_srate = 250; %% [1/sec]
    orig_timeBetweenSamples = (1000000 / orig_srate); %% [microsec] = 1/1000 [millisec]
    orig_numTheoreticalPoints = dataLengthTime / orig_timeBetweenSamples;
    
%     new_numPoints = ceil(orig_numTheoreticalPoints); %% could be doubled to fully obey Shannon's law, but so high freq data is not important
    new_srate = target_srate; % new_numPoints / orig_numTheoreticalPoints * orig_srate;
    new_numPoints = (max(timestamp)-min(timestamp))/1000/1000 * new_srate;
    
    new_x = linspace (min(timestamp), max(timestamp), new_numPoints);
    
    % this avoids overshoot
    new_y = interp1(timestamp, pupdil, new_x, 'pchip');
    
    p_timestamp = transpose(new_x); %transzponálni kell, mert valamiért alapból nem oszlop hanem sor vektort csinál
    p_pupdil = transpose(new_y);
end
