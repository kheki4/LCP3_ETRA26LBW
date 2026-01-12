function T = support_findTrialChanges(tr, trial_ts)

    %format longG;
    
    % TODO: Olyan mintha SMI és PupilEXT esetén vagy kéne vagy sem
    uniq_tr = unique(tr);
    uniq_tr = reshape(uniq_tr, [length(uniq_tr) 1]);
%     uniq_tr = transpose(unique(tr));
% %     uniq_tr = unique(tr);

    if uniq_tr ~= tr 
        log_e('Non-unique trial vector')
    end

    ts_abs = zeros(length(uniq_tr), 1);
    ts_end_abs = zeros(length(uniq_tr), 1);
    deltat_ms = zeros(length(uniq_tr), 1);
    
    for k = 1:length(tr)
        ts_abs(k) = trial_ts(k);

        if k < length(tr)
            % todo: remove
            ts_end_abs(k) = trial_ts(k+1);
        
            if k > 1
                deltat_ms(k) = (trial_ts(k) - trial_ts(k-1)) /1000;
            end
        end
    end

    duration = round((ts_end_abs - ts_abs) ./1000, 3);
    ts_rel_sec = round((ts_abs-ts_abs(1))./1000./1000, 3);
    ts_rel_min = round(ts_rel_sec./60, 3);
    deltat_sec = deltat_ms./1000;
    
    errT = zeros(length(uniq_tr), 1);
    for hgg = 1:(length(duration)-1)
        errT(hgg, 1) = round((ts_abs(hgg+1) - ts_end_abs(hgg)) /1000, 3);
    end
    
    T = table(uniq_tr, ts_abs, ts_rel_sec, ts_rel_min, deltat_ms, deltat_sec, ts_end_abs, duration, errT);
    header={'Trial', 'Start_abs_timestamp', 'Start_rel__sec', 'Start_rel__min', 'Start_deltat__ms', 'Start_deltat__sec', 'End_abs_timestamp', 'Start_to_end_duration_in_raw_data__ms', 'End_to_start_dead_time_of_raw_data__ms'};
    T.Properties.VariableNames = header;
    
end