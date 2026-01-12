function [timestamp, pupdil, conf, outlineConf, uniq_tr, ts_abs, b_start, b_end, s_start, s_end, s_startX, s_startY, s_endX, s_endY, s_magnitude] = Parser_PupilEXT_new(directory, participantName, PXorMM)

    % DEV
    s_startX = NaN;
    s_startY = NaN;
    s_endX = NaN;
    s_endY = NaN;
    s_magnitude = NaN;

    filename = strcat(directory, '/', participantName,'.csv'); 
    
    delimiter = Parser_PupilEXT_determineDelimiter(filename);

    % TODO: mm?
    colNamesToGet = {'timestamp_ms', 'trial', 'pupilDiameter_px_L_M', 'pupilConfidence_L_M', 'pupilOutlineConfidence_L_M'};
    [coli_ts, coli_tr, coli_p, coli_c, coli_oc, startRow] = Parser_PupilEXT_getHeaderColNrs(filename, colNamesToGet, delimiter);
    
    coli = [coli_ts coli_tr coli_p coli_c coli_oc];
    % TODO: make the formatSpec parameter for textscan() automatically
    formatSpec = num2str(zeros(1, max(coli)+1), '%i');
    formatSpec(coli) = '1';
% % %     newcoli_ts = coli(coli==coli_ts);
% % %     newcoli_tr = coli(coli==coli_tr);
% % %     newcoli_p = coli(coli==coli_p);
% % %     newcoli_c = coli(coli==coli_c);
% % %     newcoli_oc = coli(coli==coli_oc); 
    %
    formatSpec(coli_ts) = '1';
    formatSpec(coli_tr) = '1';
    formatSpec(coli_p) = '1';
    formatSpec(coli_c) = '1';
    formatSpec(coli_oc) = '1';
    %
    formatSpec = strrep(formatSpec, '1', '%f');
%     formatSpec = strrep(formatSpec, '1', '%f');
%     formatSpec = strrep(formatSpec, '0', '%c');
    formatSpec = strrep(formatSpec, '0', '%*s');
    formatSpec = strcat(formatSpec, '%[^\n\r]');
    %
    %TODO: find the column indices(of textscan output) that correspond to the requested columns(of textscan input)
    newcoli_ts = 1; 
    newcoli_tr = 5; 
    newcoli_p = 2; 
    newcoli_c = 3;
    newcoli_oc = 4; 
    
    % --------------------------------------------------
    % SAMPLES
    
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', true);
    fclose(fileID);

    % FONTOS: HIBÁT TUD DOBNI, CSAK AZ ELSŐ 2 oszlopot olvassa be, ha a
    % timestamp nem teljes számként hanem scientific formátumban
    % (stringként) szerepel az excel/csv fájlban
    
    % sometimes columns have different length, check for that
    lengths = [length(dataArray{newcoli_ts}) length(dataArray{newcoli_tr}) length(dataArray{newcoli_p})];
    timestamp = dataArray{newcoli_ts}(1:min(lengths));
    tr = dataArray{newcoli_tr}(1:min(lengths));
    pupdil = dataArray{newcoli_p}(1:min(lengths));
    conf = dataArray{newcoli_c}(1:min(lengths));
    outlineConf = dataArray{newcoli_oc}(1:min(lengths));

    % fix for newer data format where invalid is kept -1
    deleteMask = (pupdil==-1) | (conf==-1) | (outlineConf==-1);
    timestamp(deleteMask) = [];
    tr(deleteMask) = [];
    pupdil(deleteMask) = [];
    conf(deleteMask) = [];
    outlineConf(deleteMask) = [];

    % NOTE: TIMESTAMP VALUES are in ms in case of PupilEXT, as instead SMI
    % has it in microsec, so we artificially increase temporal resolution
    % by multiplying PupilEXT values by 1000
    timestamp = timestamp.*1000;

    % --------------------------------------------------
    % TRIALS BASED ON SAMPLES
    
    % TODO: READ EVENTS XML

    uniq_tr = unique(tr);
    ts_abs = zeros(length(uniq_tr), 1);

    if length(timestamp) < 10
        log_e('The length of this recording is less than 10 samples. Please check your data')
    end
    
    ts_abs(1) = timestamp(1);
    tr_prev = tr(1);

    changeC = 2;
    iterC = 1;
    while(iterC < length(timestamp)) %% && changeC < 10)
        tr_curr = tr(iterC);
        
        if tr_curr < tr_prev && tr_curr > tr(1)
            log_e(['Trial numbering restarted during recording. Please fix the data file and try again']);
        end
        
        if tr_curr > tr_prev
            ts_abs(changeC) = timestamp(iterC);
            changeC = changeC + 1;
        end
        iterC = iterC + 1;
        tr_prev = tr_curr;
    end
    
    % DUMMY VARIABLES: reserved for future
    b_start = NaN;
    b_end = NaN;
    s_start = NaN;
    s_end = NaN;
    
    % DEV
  %  timestamp(1:20)
  %  pupdil(1:20)

end