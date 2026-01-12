function [p_timestamp, p_pupdil, p_conf, p_outlineConf] = DQ_RemoveSamplesByConfidence(timestamp, pupdil, conf, outlineConf, confidenceThreshold, outlineConfidenceThreshold)

    mask = false(size(timestamp, 1), 1);

    regarded_c = true;
    regarded_oc = true;

    uniq_c = unique(conf);
    if length(uniq_c) == 1 && (isnan(uniq_c(1)) || uniq_c(1) == -1)
        regarded_c = false;
        log_w('Confidence values are invalid, thus we are not currently rejecting samples by confidence.')
    end

    uniq_oc = unique(outlineConf);
    if length(uniq_oc) == 1 && (isnan(uniq_oc(1)) || uniq_oc(1) == -1)
        regarded_oc = false;
        log_w('Outline confidence values are invalid, thus we are not currently rejecting samples by outline confidence.')
    end

% % %     log_i('Using the AND logic: if a sample fulfils ALL criteria, it will pass.')
% % %     for(j = 1:size(timestamp,1))
% % %         if regarded_c && conf(j) < confidenceThreshold
% % %             continue;
% % %         end
% % %         if regarded_oc && outlineConf(j) < outlineConfidenceThreshold
% % %             continue;
% % %         end
% % %         mask(j) = true;
% % %     end

    log_i('Using the OR logic: if a sample fulfils ANY criteria, it will pass.')
    for(j = 1:size(timestamp,1))
        if regarded_c && conf(j) >= confidenceThreshold
            mask(j) = true;
        end
        if regarded_oc && outlineConf(j) >= outlineConfidenceThreshold
            mask(j) = true;
        end
    end
  
    p_timestamp = timestamp(mask);
    p_pupdil = pupdil(mask);
    p_conf = conf(mask);
    p_outlineConf= outlineConf(mask);
    
end
