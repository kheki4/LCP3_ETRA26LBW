function support_SaveEveryTrial(TrialsArray, Meta, Config, Participant)
    
    % TODO: remove this?
    for ytr = 1:size(TrialsArray, 2)
        TrialsArray(:, ytr) = TrialsArray(:, ytr) - mean(TrialsArray(Config.BaselineFromSampleMapped:Config.BaselineToSampleMapped, ytr), 'omitnan');
    end
    
%     timepoints = (0:size(TrialsArray, 1)-1)/Meta.NomSRate *1000;
    trnum = num2cell(1:size(TrialsArray, 2));
    
    col_headerHoriz = [{ [''] }  trnum];
    
    % Sweeps (Trials) are columns
    % Timepoints are rows (in ms)
    
    cols_sub_vals = cell(Config.AnalyzeLenSample, size(TrialsArray, 2)+1);
%     cols_sub_vals(1:Config.AnalyzeLenSample, 1) = num2cell(timepoints);
    cols_sub_vals(1:Config.AnalyzeLenSample, 1) = num2cell(transpose(linspace(round(Config.AnalyzeFromSec*1000), round(Config.AnalyzeToSec*1000), Config.AnalyzeLenSample)));
    cols_sub_vals(1:Config.AnalyzeLenSample, 2:size(TrialsArray, 2)+1) = num2cell(TrialsArray);
    outputMatrix = [col_headerHoriz; cols_sub_vals];
    
    OutFilePath = char([ ...
        '~RESULTS/' Meta.RootDirTag '/' ...
        'ERPD everyTrial csv' '/']);
        
    if ~exist(OutFilePath, 'dir')
        mkdir(OutFilePath);
    end
    
    OutFileName = char([ ...
        Participant.ID ' Smp=[' num2str(1) ' ' num2str(Config.AnalyzeLenSample) ']' ...
        ' alignSR=' num2str(Config.AlignToStimOrResp) ...
        ' filt=' num2str(Config.Filter.Behav.Enabled) ' (' Config.Filter.Behav.FriendlyName ')' ...
        ]);
    writecell(outputMatrix,[OutFilePath OutFileName '.csv'],'Delimiter',';');

end