function [ETData] = GetData(Directory, ParticipantName, ETDataFormat, PXorMM)
    
    % TODO: map fixations ?
    % TODO: discard fixations shorter than 100ms ?

%     ETData.QualityValues.Conf = NaN;
%     ETData.QualityValues.OutlineConf = NaN;
%     ETData.Samples.Conf = NaN;
%     ETData.Samples.OutlineConf = NaN;
    ETData.Samples.QualityValues.Conf = NaN;
    ETData.Samples.QualityValues.OutlineConf = NaN;
    ETData.Saccades.StartTs = NaN;
    ETData.Saccades.EndTs = NaN;
    ETData.Saccades.StartX = NaN;
    ETData.Saccades.StartY = NaN;
    ETData.Saccades.EndX = NaN;
    ETData.Saccades.EndY = NaN;
    ETData.Saccades.Magnitude = NaN;

    if(strcmp(ETDataFormat, 'SMI'))
        [ETData.Samples.Ts, ETData.Samples.Pupdil, ETData.Samples.QualityValues.Conf, ETData.Triggers.Trial, ETData.Triggers.Ts, ETData.Blinks.Start, ETData.Blinks.End, ETData.Saccades.Start, ETData.Saccades.End, ETData.Saccades.StartX, ETData.Saccades.StartY, ETData.Saccades.EndX, ETData.Saccades.EndY, ETData.Saccades.Magnitude] = Parser_SMI(Directory, ParticipantName, PXorMM);
    elseif(strcmp(ETDataFormat, 'PupilEXT'))
        % old
%         [ETData.Samples.Ts, ETData.Samples.Pupdil, ETData.Samples.QualityValues.Conf, ETData.Samples.QualityValues.OutlineConf, ETData.Triggers.Trial, ETData.Triggers.Ts, ETData.Blinks.Start, ETData.Blinks.End, ETData.Saccades.Start, ETData.Saccades.End, ETData.Saccades.StartX, ETData.Saccades.StartY, ETData.Saccades.EndX, ETData.Saccades.EndY, ETData.Saccades.Magnitude] = Parser_PupilEXT(Directory, ParticipantName, PXorMM);
        % new
        [ETData.Samples.Ts, ETData.Samples.Pupdil, ETData.Samples.QualityValues.Conf, ETData.Samples.QualityValues.OutlineConf, ETData.Triggers.Trial, ETData.Triggers.Ts, ETData.Blinks.Start, ETData.Blinks.End, ETData.Saccades.Start, ETData.Saccades.End, ETData.Saccades.StartX, ETData.Saccades.StartY, ETData.Saccades.EndX, ETData.Saccades.EndY, ETData.Saccades.Magnitude] = Parser_PupilEXT_new(Directory, ParticipantName, PXorMM);
    elseif(strcmp(ETDataFormat, 'EyeLink'))
        Filename = strcat(Directory, '/', ParticipantName,'.asc'); 
%         [coli_ts, coli_tr, coli_p, coli_c, coli_oc, StartRow] = support_EyeLink_GetHeaderColNrs(filename, colNamesToGet);
% %         [ETData.Samples.Ts, ETData.Samples.Pupdil, ETData.Triggers.Trial, ETData.Triggers.Ts, ETData.Blinks.Start, ETData.Blinks.End, ETData.Saccades.Start, ETData.Saccades.End, ETData.Saccades.StartX, ETData.Saccades.StartY, ETData.Saccades.EndX, ETData.Saccades.EndY, ETData.Saccades.Magnitude] = Parser_EyeLink(Filename);
        [ETData.Samples.Ts, ETData.Samples.Pupdil, ETData.Triggers.Trial, ETData.Triggers.Ts, ETData.Blinks.Start, ETData.Blinks.End, ETData.Saccades.Start, ETData.Saccades.End] = Parser_EyeLink(Filename);
% %         [timestamp, pupdil, trig_trial, trig_trial_ts, blinks_start, blinks_end, saccades_start, saccades_end]
    elseif(strcmp(ETDataFormat, 'Tobii'))
        % NOTE: only MM mapped data available
%         Filename = strcat(Directory, '/', ParticipantName,'.txt'); 
        [ETData.Samples.Ts, ETData.Samples.Pupdil, ETData.Samples.QualityValues.Conf, ETData.Triggers.Trial, ETData.Triggers.Ts, ETData.Blinks.Start, ETData.Blinks.End, ETData.Saccades.Start, ETData.Saccades.End, ETData.Saccades.StartX, ETData.Saccades.StartY, ETData.Saccades.EndX, ETData.Saccades.EndY, ETData.Saccades.Magnitude] = Parser_Tobii(Directory, ParticipantName);
%         log_e('Not yet supported');
    elseif(strcmp(ETDataFormat, 'GGProcessed'))
        [ETData.Samples.Ts, ETData.Samples.Pupdil, ETData.Samples.QualityValues.Conf, ETData.Triggers.Trial, ETData.Triggers.Ts, ETData.Blinks.Start, ETData.Blinks.End, ETData.Saccades.Start, ETData.Saccades.End, ETData.Saccades.StartX, ETData.Saccades.StartY, ETData.Saccades.EndX, ETData.Saccades.EndY, ETData.Saccades.Magnitude] = Parser_GGProcessed(Directory, ParticipantName);
    elseif(strcmp(ETDataFormat, 'Other'))
        Filename = strcat(Directory, '/', ParticipantName,'.xlsx');
        [ETData.Samples.Ts, ETData.Samples.Pupdil] = Parser_Other(Filename, FilterTrials);
    end
    
end