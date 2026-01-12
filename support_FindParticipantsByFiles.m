function Participants = support_FindParticipantsByFiles(Config, isProcessed)

    

    if isProcessed
        % TODO: clarify this...
        Config.ETDataFileNameEnding = '.mat';
        LookupDir = ['~PREPDATA/' Config.ETDSDirName '/*' Config.ETDataFileNameEnding];
    else
        if strcmp(Config.ETDataFormat, 'Tobii')
            Participants = support_enumParticipants_Tobii(['~RAWDATA/' Config.ETDeviceDirName '/' Config.ExpDirName]);
            % DEV
            % exclude participants from processing if they have a non-numeric name
            % not necessary. there should be an excl. list later
%             Participants = Participants(~isnan(str2double(Participants)));
            % DEV
            return;
        elseif strcmp(Config.ETDataFormat, 'GGProcessed')
            Participants1 = support_enumParticipants_GGProcessed(['~RAWDATA/' Config.ETDeviceDirName '/' Config.ExpDirName]);
            % DEV
            % exclude participants from processing if they have a non-numeric name
            % not necessary. there should be an excl. list later
%             Participants = Participants(~isnan(str2double(Participants)));
            Participants = string(Participants1(~isnan(Participants1)));
            % DEV
            return;
        end

        LookupDir = ['~RAWDATA/' Config.ETDeviceDirName '/' Config.ExpDirName '/*' Config.ETDataFileNameEnding];
    end

    % Following code works for eye trackers that do not aggragate data of
    % all participants into one file (or only support that)

    dfn = dir(char(LookupDir));
    Participants = regexprep({dfn.name}, Config.ETDataFileNameEnding, '', 'once');
    Participants = Participants(~strcmp(Participants, '.') & ~strcmp(Participants, '..')); % remove faulty ones called '.'. and '..'
    if length(Participants) < 1
        log_e(['The directory you specified does not contain any data file with this ending: ' Config.ETDataFileNameEnding ' Do you have your eyetracker data format set correctly?']);
    end
    Participants(ismember(Participants, 'Metafile')) = []; 
    log_i('Automatically detected participant names in the order of processing:')
    disp(Participants');
    clearvars dfn;

    % TODO: less C-like?
    if isfield(Config, 'SkipParticipants') && length(Config.SkipParticipants) ~= 1
        for skp = 1:length(Config.SkipParticipants)
            acp = 1;
            while acp <= length(Participants)
                if strcmp(Config.SkipParticipants(skp), Participants(acp))
                    Participants(acp) = []; % delete the cell entry (because participants{acp} = []; would only change that cell to an empty one
                end
                acp = acp + 1;
            end
        end
    end

end