function support_SaveTEPREveryParticipant(TEPREveryParticipant, Config, Meta, Participants)

    col_Participants = transpose([{ [Meta.CfPrefix '_' 'Participant'] }  Participants]);
    
    TEPREveryParticipantCSVheader = cell( 1, Config.AnalyzeLenSample );
%     for bfc = 1:Config.AnalyzeLenSample
%         TEPREveryParticipantCSVthisCol = [ Meta.CfPrefix '_' 'Sample' ' ' num2str(bfc) ];
%         TEPREveryParticipantCSVheader{1, bfc} = TEPREveryParticipantCSVthisCol;
%     end
    
    TEPREveryParticipantCSVheader(1, 1:Config.AnalyzeLenSample) = num2cell(linspace(round(Config.AnalyzeFromSec*1000), round(Config.AnalyzeToSec*1000), Config.AnalyzeLenSample));

    cols_sub_vals = cell(length(Participants)+1, Config.AnalyzeLenSample);
    cols_sub_vals(1, 1:Config.AnalyzeLenSample) = TEPREveryParticipantCSVheader;
    cols_sub_vals(2:length(Participants)+1, 1:Config.AnalyzeLenSample) = num2cell(TEPREveryParticipant);
    outputMatrix = [col_Participants cols_sub_vals];
    % %     OutFilePath = ['~RESULTS/' Meta.RootDirTag '/' 'TEPR csv' '/' ];
    % %     mkdir(OutFilePath);
    % OutFileName = [ 'TEPREveryParticipant' ' fromSmp=' num2str(1) '; toSmp=' num2str(Config.AnalyzeLenSample) ' alignSR=' num2str(Config.AlignToStimOrResp) ' filt=' num2str(Config.Filter.Behav.Enabled) ' (' Config.Filter.Behav.FriendlyName ')' ];

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
        'TEPREveryParticipant' ...
        'Smp=[' num2str(1) ' ' num2str(Config.AnalyzeLenSample) ']' ...
        ' alignSR=' num2str(Config.AlignToStimOrResp) ...
        ' filt=' num2str(Config.Filter.Behav.Enabled) ' (' Config.Filter.Behav.FriendlyName ')' ...
        ]);

    writecell(outputMatrix,[OutFilePath OutFileName '.csv'],'Delimiter',';');

end