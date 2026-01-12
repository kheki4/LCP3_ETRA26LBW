function participantNames = support_enumParticipants_GGProcessed(directory)

    % TODO: make auto-detect code for column index numbers based on column
    % name strings. and be vararg not fixed signature

%     filename = 'Tobii_PETI_EMO_minden_ksz.txt'; 

    fileListMAT = dir(fullfile(directory, '*.csv'));

    aggrFilename = strcat(directory, '/aggregatedData.csv'); 
    if exist(aggrFilename, 'file')
    
        delimiter = ',';
        
        %make the formatSpec parameter for textscan() automatically
        formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%s%[^\n\r]';
        
        fileID = fopen(aggrFilename,'r');
        % NOTE: had to use string for puip.dil columns (originally (before skipping) numbered:) 9, 10 and 11 due to read failures (R2021b)
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,1, 'ReturnOnError', true);
        fclose(fileID);
    
        % SKIPPED COLUMNS DO NOT COUNT INTO READ DATA AT ALL 
        % (THEY DECREASE COLUMN INDEX NUMBERS)
    
        participantNames = transpose( unique(dataArray{2}) );

    elseif(~isempty(fileListMAT.name))

        Participants = {fileListMAT.name};
        if length(Participants) < 1
            log_e(['The directory you specified does not contain any data file with .mat ending.']);
        end
        % Participants(ismember(Participants, 'Metafile')) = []; 
        % log_i('Automatically detected participant names in the order of processing:')
        % disp(Participants');
        % clearvars dfn;

    end

end
