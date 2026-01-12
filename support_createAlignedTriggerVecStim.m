function [numTriggers, trials, stimTs] = support_createAlignedTriggerVecStim(stim_trial, stim_timestamp, Config_FilterTrials, Config_SkipRawTrials, Config_EveryWhichTrial)

% % %     numTriggers = ceil((Config_FilterTrials(2) - Config_FilterTrials(1)) /Config_EveryWhichTrial + 1);
% %     numTriggers = ceil((Config_FilterTrials(2) - Config_FilterTrials(1) + 1) /Config_EveryWhichTrial);
% %     numTriggers = numTriggers - length(Config_SkipRawTrials)/Config_EveryWhichTrial;
%     numTriggers = ceil((Config_FilterTrials(2) - Config_FilterTrials(1) + 1 - sum(~isnan(Config_SkipRawTrials))) /Config_EveryWhichTrial);
    numTriggers = ceil((Config_FilterTrials(2) - Config_FilterTrials(1) + 1 - sum(~isnan(Config_SkipRawTrials(Config_SkipRawTrials<=Config_FilterTrials(2) & Config_SkipRawTrials>=Config_FilterTrials(1))))) / Config_EveryWhichTrial);
    
    if ~isnan(Config_SkipRawTrials) & ~isempty(Config_SkipRawTrials) & isnumeric(Config_SkipRawTrials)
        stim_trial(Config_SkipRawTrials) = [];
        
        stim_trial = stim_trial(1:length(stim_trial)); 
        
        stim_timestamp(Config_SkipRawTrials) = [];
    end
            
    trials = nan(numTriggers,1);
    stimTs = nan(numTriggers,1);

    c = 1;
    for i = 1:length(stim_timestamp)
        
%         if sum(Config_SkipRawTrials == i) > 0
%             log_d('CHECK');
%         end
%         if sum(Config_SkipRawTrials == i+1) > 0
%             log_d('CHECK');
%         end

%         % failsafe
%         lastReadableStartTimestamp = stim_timestamp(i);
%         lastTrialNrCandidate = c-1;

        if stim_trial(i) >= Config_FilterTrials(1) && stim_trial(i) <= Config_FilterTrials(2) && mod(stim_trial(i)-Config_FilterTrials(1), Config_EveryWhichTrial) == 0
            if isnan(stim_timestamp(i))
                stimTs(c) = NaN;
                % ...
            else
                stimTs(c) = stim_timestamp(i);
            end
            trials(c) = c; % TODO: remove?
            c = c+1;
        else
%             disp(i)
        end
    end

    if isnan(trials(end))
        log_w(['We could not safely assign a trial number to the end of meaningful-trials section.' newline() 'This is likely because the number of trials to align and renumber is not divisible by the Config_EveryWhichTrial parameter specified.' newline() 'Using a dummy value now.'])
        stimTs(end) = stimTs(c-1);
        trials(end) = c-1;
    end
    
    interStimIntervals = zeros(1); % failsafe
    for i = 1:(length(stimTs)-1)
        interStimIntervals(i) = stimTs(i+1) - stimTs(i);
%         log_d(['Length of renumbered trial nr. ' num2str(trials(i)) ' in seconds: ' num2str(interStimIntervals(i)/1000/1000)]);
    end

    log_i(['Mean inter-stimulus-interval in seconds: ' num2str(mean(interStimIntervals, 'omitnan')/1000/1000)]);
    log_i(['SD of inter-stimulus-interval in seconds: ' num2str(std(interStimIntervals, 'omitnan')/1000/1000)]);

    log_d(['Trial vector realigned to start from first relevant trial trigger, with respect to Config_EveryWhichTrial param:']);
    log_d(['   Original numbering: ' sprintf('\t') '[' num2str(stim_trial(1)) ' ' num2str(stim_trial(end)) ']']);
    log_d(['   FilterTrials: ' sprintf('\t\t') '[' num2str(Config_FilterTrials(1)) ' ' num2str(Config_FilterTrials(2)) ']']);
    log_d(['   Realigned: ' sprintf('\t\t\t') '[' num2str(trials(1)) ' ' num2str(trials(end)) ']']);

end