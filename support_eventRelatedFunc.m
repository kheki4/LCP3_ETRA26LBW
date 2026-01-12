function result = support_eventRelatedFunc(trials_array, method)

    % This function does the "dimension reduction" by e.g. averaging all
    % trials samplewise, but it can utilize other functions too, e.g. SD
    % to be used for feature extraction purposes for ML, etc. DEV only

    result = NaN(size(trials_array, 1), 1);

    if method == 1 % ERPD
        result = mean(trials_array,2,'omitnan');
    elseif method == 2 % ERPD-SD
        result = std(trials_array, 0, 2,'omitnan');
    elseif method == 3 % ERPD-Ku
        result = kurtosis(trials_array, 1, 2);
    elseif method == 4 % ERPD-Sk
        result = skewness(trials_array, 1, 2);
    elseif method == 5 % ERPD-MAD
        result = mad(trials_array, 1, 2);
    elseif method == 6 % ERPD-Min
        result = min(trials_array,[],2,'omitnan');
    elseif method == 7 % ERPD-Max
        result = max(trials_array,[],2,'omitnan');
    elseif method == 8 % ERPD-KMax
        for chu = 1:size(trials_array, 1)
            [tempf, tempxi] = ksdensity(trials_array(chu,:));
            result(chu) = tempxi( tempf==max(tempf) );
        end
    elseif method == 9 % ERPD-KVal
        for chu = 1:size(trials_array, 1)
            [tempf, tempxi] = ksdensity(trials_array(chu,:));
            result(chu) = max(tempf);
        end
    elseif method == 10 % ERPD-CV /RSD (coefficient of variation, not in percentage)
        result = std(trials_array, 0, 2,'omitnan') ./ mean(trials_array,2,'omitnan');
    elseif method == 11 % TEPR-Sh - Shapiro
        for chu = 1:size(trials_array, 1)
            % NOTE: data has to be a column
            [H, pValue, W] = support_swtest(trials_array(chu,:));
            result = pValue;
        end
    elseif method == 12 % TEPR (Median)
        result = median(trials_array, 2, 'omitnan');
    end

end