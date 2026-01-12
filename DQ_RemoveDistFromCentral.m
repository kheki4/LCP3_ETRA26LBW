function [p_timestamp, p_pupdil] = DQ_RemoveDistFromCentral(timestamp, pupdil, method, threshold)

    if method == 0 
        centralValue = mean(pupdil, 'omitnan');
        differenceUnit = std(pupdil, 'omitnan');
    elseif method == 1
        centralValue = median(pupdil, 'omitnan');
        differenceUnit = abs(quantile(pupdil, 0.25) - quantile(pupdil, 0.75));
    else
        log_e(['Invalid method specified for DQ script DQ_RemoveDistFromCentral'])
    end

    % NOTE: inclusive boundaries
    mask = ~isnan(timestamp) & ...
        pupdil <= centralValue + differenceUnit*threshold & ...
        pupdil >= centralValue - differenceUnit*threshold;
  
%     disp(DEBUG_counter);
%     disp( sum(isnan(pupdil)) );
  
    p_timestamp = timestamp(mask);
    p_pupdil = pupdil(mask);
    
end
