function [timestamp, pupdil, conf, uniq_tr_fixed, ts_abs, b_start, b_end, s_start, s_end, s_startX, s_startY, s_endX, s_endY, s_magnitude] = Parser_Tobii(directory, participantName)

    % TODO: make auto-detect code for column index numbers based on column
    % name strings. and be vararg not fixed signature

    % TODO: also handle well when the input is not a directory but an
    % aggragated file like in case of tobii

    fileListTXT = dir(fullfile(directory, '*.txt'));
    fileListMAT = dir(fullfile(directory, '*.mat'));

    aggrFilename = strcat(directory, '/aggregatedData.txt'); 
    if exist(aggrFilename, 'file')

        delimiter = '\t';
        
        %make the formatSpec parameter for textscan() automatically
        formatSpec = '%f%*s%s%s%*s%*f%f%s%s%s%s%s%s%s%s%f%f%*f%*f%[^\n\r]';
    % %     num2str(zeros(1, max(coli)+1), '%i');
    % %     formatSpec(coli) = '1';
    % %     formatSpec = strrep(formatSpec, '1', '%f');
    % %     formatSpec = strrep(formatSpec, '0', '%*s');
    % %     formatSpec = strcat(formatSpec, '%[^\n\r]');
    % %     %TODO: find the column indices(of textscan output) that correspond to the requested columns(of textscan input)
    % %     newcoli_ts = 1; %coli(coli==coli_ts)
    % %     newcoli_tr = 2; %coli(coli==coli_tr)
    % %     newcoli_p = 3; %coli(coli==coli_p)
        
        fileID = fopen(aggrFilename,'r');
        % NOTE: had to use string for puip.dil columns (originally (before skipping) numbered:) 9, 10 and 11 due to read failures (R2021b)
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,1, 'ReturnOnError', true);
        dataArray{8} = regexprep(dataArray{8},',','.'); % THEY USE COMMA AS DECIMAL POINT.. BUT ONLY IN THIS COLUMN. PAY ATTENTION
        fclose(fileID);
        
        participantToLookFor = participantName;
    
        base_mask = 1:length(dataArray{1});
    
        % SKIPPED COLUMNS DO NOT COUNT INTO READ DATA AT ALL 
        % (THEY DECREASE COLUMN INDEX NUMBERS)
        
        c_participantName_mask = strcmp(dataArray{3}, participantToLookFor);
        
        sensor_mask = strcmp(dataArray{2}, 'Eye Tracker');
    
        % pass only where ANY or BOTH of the two are valid
        c_validityL_mask = strcmp(dataArray{9}, 'Valid');
        c_validityR_mask = strcmp(dataArray{10}, 'Valid');
    
        % unify masks
        mask = c_participantName_mask & (c_validityL_mask & c_validityR_mask) & sensor_mask;
    
        c_relTs = dataArray{1}(mask);
        c_pupdilProcessed = dataArray{8}(mask);
        c_eyeEventType = dataArray{12}(mask);
    
        c_gazeX = dataArray{13}(mask);
        c_gazeY = dataArray{15}(mask);
    
        % 
    
        timestamp = c_relTs;
        pupdil = str2double(c_pupdilProcessed);
    
        c_dataEventType_helper1 = dataArray{5}(c_participantName_mask); % data event names for all
        c_dataEventType_helper2 = dataArray{1}(c_participantName_mask); % rel timestamps for all.. has to be rel due to data structure
    
        ts_abs_mask1 = strcmp(c_dataEventType_helper1, 'RecordingStart') | strcmp(c_dataEventType_helper1, 'ImageStimulusStart');
        ts_abs = c_dataEventType_helper2(ts_abs_mask1); % abs (rel in fact) timestamps for trial starts
        uniq_tr_fixed = 1:length(ts_abs); % trials, but not for all samples
    
        b_start= NaN;
        b_end = NaN;
        s_start= NaN;
        s_end = NaN;
        s_startX = NaN;
        s_startY = NaN;
        s_endX = NaN; 
        s_endY = NaN;
        s_magnitude = NaN;
        
        conf = ones(length(timestamp), 1);

    elseif sum(ismember(erase({fileListMAT.name}, '.mat'), participantName)) > 0
        disp(participantName)

        data = load(fullfile(directory, [participantName '.mat']));

        timestamp = data.data.gaze.systemTimeStamp; % sure? not deviceTimeStamp?
        pupdil = data.data.gaze.left.pupil.diameter;

        c_gazeX = data.data.gaze.left.gazePoint.onDisplayArea(1,:);
        c_gazeY = data.data.gaze.left.gazePoint.onDisplayArea(2,:);

        usableSamplesMask = (data.data.gaze.left.pupil.available & data.data.gaze.left.pupil.valid) & ...
            c_gazeY > 0.4 & ...
            c_gazeY < 0.6 & ...
            c_gazeX > 0.4 & ...
            c_gazeX < 0.6 & ...
            data.data.gaze.left.gazePoint.available & data.data.gaze.left.gazePoint.valid ;

        timestamp = double(timestamp(usableSamplesMask));
        pupdil = double(pupdil(usableSamplesMask));



        msg_ts = double(cell2mat(data.messages(:,1)));
        msg_texts = data.messages(:,2);
        
        % The start of the recording gets a trial number 1 by default
        ww = startsWith(msg_texts, "STIM_PRES_") | startsWith(msg_texts, "RECORDING STARTED");
        msg_ts = msg_ts(ww);
        msg_texts = msg_texts(ww);

        uniq_tr_fixed = 1:length(msg_ts);
        ts_abs = msg_ts;

%         roughConf = data.data.gaze.left.eyeOpenness.diameter;
%         usableSamplesMask = (data.data.gaze.left.eyeOpenness.available & data.data.gaze.left.eyeOpenness.valid & ...
%             data.data.gaze.left.eyeOpenness.diameter > data.data.gaze.left.pupil.diameter & ...
%             data.data.gaze.left.pupil.available & data.data.gaze.left.pupil.valid);
%         base_mask = 1:length(timestamp);
        
        b_start= NaN;
        b_end = NaN;
        s_start= NaN;
        s_end = NaN;
        s_startX = NaN;
        s_startY = NaN;
        s_endX = NaN; 
        s_endY = NaN;
        s_magnitude = NaN;

        conf = ones(length(timestamp), 1);
    end
    
end