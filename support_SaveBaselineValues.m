function support_SaveBaselineValues(BaselineValues, BaselineValuesCV, BaselineValuesEveryTrial, Config, Meta, Participants)
    
    col_Participants = transpose([{ [Meta.CfPrefix '_' 'Participant'] }  Participants]);
    cols_sub_vals = cell(length(Participants)+1, 3);
    cols_sub_vals(1, 1) = { [Meta.CfPrefix '_' 'PD baseline']};
    cols_sub_vals(1, 2) = { [Meta.CfPrefix '_' 'PD baseline CV']};
    cols_sub_vals(1, 3) = { [Meta.CfPrefix '_' 'PD baseline slope']};
    cols_sub_vals(2:length(Participants)+1, 1) = num2cell(BaselineValues);
    cols_sub_vals(2:length(Participants)+1, 2) = num2cell(BaselineValuesCV);
    
    for ncn = 1:length(Participants)
        backbone = 1:size(BaselineValuesEveryTrial,2); % num trials
        backbone = backbone(~isnan(BaselineValuesEveryTrial(ncn,:)));
        yvals = BaselineValuesEveryTrial(ncn,:);
        yvals = yvals(~isnan(BaselineValuesEveryTrial(ncn,:)));
        coefficients = polyfit(backbone, yvals, 1);
        BaselineValuesSlope(ncn) = coefficients(1);
    end
    
    cols_sub_vals(2:length(Participants)+1, 3) = num2cell(BaselineValuesSlope);
    outputMatrix = [col_Participants cols_sub_vals];

    % hack to force Matlab output numbers instead of scientific notation
    outputMatrix(cellfun(@isnumeric,outputMatrix)) = compose('%.10f', [outputMatrix{cellfun(@isnumeric,outputMatrix)}]);

    OutFilePath = char([ ...
        '~RESULTS/' Meta.RootDirTag '/' ...
        'TEPR csv' ...
        ' alignSR=' num2str(Config.AlignToStimOrResp) ...
        ' filt=' num2str(Config.Filter.Behav.Enabled) ...
        ' (' Config.Filter.Behav.FriendlyName ')'...
        '/']);
    
    if ~exist(OutFilePath, 'dir')
        mkdir(OutFilePath);
    end

    OutFileName = char([ ...
        'PD_Baseline-values' ...
        ' BL=[' num2str(Config.BaselineFromSec) ' ' num2str(Config.BaselineToSec) ']' ...
        ' alignSR=' num2str(Config.AlignToStimOrResp) ...
        ' filt=' num2str(Config.Filter.Behav.Enabled) ' (' Config.Filter.Behav.FriendlyName ')' ...
        ]);

%     OutFileName = [ Meta.CfPrefix '_' 'PD_Baseline-values' ' BLfromSec=' num2str(Config.BaselineFromSec) '; BLtoSec=' num2str(Config.BaselineToSec) ' Config.AlignToStimOrResp=' num2str(Config.AlignToStimOrResp) ' filt=' num2str(Config.Filter.Behav.Enabled) ' (' Config.Filter.Behav.FriendlyName ')' ];

    writecell(outputMatrix,[OutFilePath OutFileName '.csv'],'Delimiter',';'); % writematrix nem jĂł cell mĂˇtrixra

end