function NewTrialsArray = support_ZNormSweeps(Samples, TrialsArray, SearchBaseMask, Z_norm_method)
    
    NewTrialsArray = NaN(size(TrialsArray));
    
    if Z_norm_method == 1
        log_i('Using Z-normalization referenced to whole recording');
    elseif Z_norm_method == 2
        log_i('Using Z-normalization referenced to all each trial on its own');
    elseif Z_norm_method == 3
        log_i('Using Z-normalization referenced to all existing trials');
    elseif Z_norm_method == 4
        log_i('Using Z-normalization referenced to all non-rejected trials');
    else
        log_e('Invalid Z-normalization method defined');
    end
        
    for i = 1:size(TrialsArray,2)
        if ~SearchBaseMask(i)
            continue
        end
            
        if Z_norm_method == 1
            z_norm_reference = std(Samples.Pupdil, 'omitnan');
        elseif Z_norm_method == 2
            z_norm_reference = std(TrialsArray(:,i), 'omitnan');
        elseif Z_norm_method == 3
            z_norm_reference = std(reshape(TrialsArray(:,1:numTrials),1,[]), 'omitnan');  % convert matrix to row vector
        elseif Z_norm_method == 4
            z_norm_reference = std(reshape(TrialsArray(SearchBaseMask,i),1,[]), 'omitnan');  % convert matrix to row vector
        %else
        %    log_e('Invalid Z-normalization method defined');
        end
            
        NewTrialsArray(:,i) = (TrialsArray(:,i) - mean(z_norm_reference, 'omitnan'))./z_norm_reference;
    end

end