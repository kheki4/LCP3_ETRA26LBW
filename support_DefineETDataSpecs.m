function Config = support_DefineETDataSpecs(Config)

    Config.ETDeviceDirName = '*';
    Config.ETDataFileNameEnding = '*';
    if(strcmp(Config.ETDataFormat, 'SMI'))

        Config.ETDeviceDirName = 'ET_SMI_TXT';
        Config.ETDataFileNameEnding = ' Samples.txt'; % the whitespace is needed

    elseif(strcmp(Config.ETDataFormat, 'PupilEXT'))

        Config.ETDeviceDirName = 'ET_PUPILEXT_CSV';
        Config.ETDataFileNameEnding = '.csv';

        log_w('PupilEXT only supports PX data yet')
        Config.PXorMM = true;

        Config.DQ.Hiccups.Apply = true;
        Config.DQ.Hiccups.WindowLengthFactor = 4;
        Config.DQ.Hiccups.Threshold = 10;

    elseif(strcmp(Config.ETDataFormat, 'EyeLink'))

        Config.ETDeviceDirName = 'ET_EYELINK_ASC';
        Config.ETDataFileNameEnding = '.asc';

        log_w('EyeLink processing code only supports PX/arbitrary unit data yet, no MM')
        Config.PXorMM = true;

        % 33 ms fits >=2 frames if recorded at 60 FPS
        Config.DQ.Zeros.CutBackMs = 40;
        Config.DQ.Zeros.CutForwardMs = 40;
        Config.DQ.Blinks.CutBackMs = 40; 
        Config.DQ.Blinks.CutForwardMs = 40;
        
%         Config.DQ.Zeros.CutBackMs = 3*17;
%         Config.DQ.Zeros.CutForwardMs = 3*17;
%         Config.DQ.Blinks.CutBackMs = 3*17; 
%         Config.DQ.Blinks.CutForwardMs = 3*17;

        Config.DQ.Hiccups.Apply = true;
        Config.DQ.Hiccups.WindowLengthFactor = 100; % 64; % 4, 8, 16, 32, 64
        Config.DQ.Hiccups.Threshold = 10;

        Config.DQ.DistFromCentral.Apply = true;
        Config.DQ.DistFromCentral.Method = 0; % 0 = mean-SD; 1 = median-IQR
        Config.DQ.DistFromCentral.Threshold = 2.5;
        Config.DQ.DistFromCentral.Method = 1; % 0 = mean-SD; 1 = median-IQR
%         Config.DQ.DistFromCentral.Threshold = 1.5;
        Config.DQ.DistFromCentral.Threshold = 2.0;

    elseif(strcmp(Config.ETDataFormat, 'Tobii'))

        Config.ETDeviceDirName = 'ET_TOBII_TXT_MAT';
        Config.ETDataFileNameEnding = '.txt';

    elseif(strcmp(Config.ETDataFormat, 'GGProcessed'))

        Config.ETDeviceDirName = 'GG_PROCESSED';
        Config.ETDataFileNameEnding = '.csv';

    elseif(strcmp(Config.ETDataFormat, 'Other'))

        Config.ETDeviceDirName = 'ET_OTHER_XLSX';
        Config.ETDataFileNameEnding = '.xlsx';

    end

end