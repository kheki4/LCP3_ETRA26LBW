function [ERLEveryTrial, ERLVEveryTrial] = support_CalcERL(Config, TrialsArray, Meta)

    ERLEveryTrial = nan(1, size(TrialsArray,2));
    ERLVEveryTrial = nan(1, size(TrialsArray,2));
    
    % TODO: check subsample precision for x and y too?

    for i=1:size(TrialsArray, 2)
        x = TrialsArray((Config.ERL.FromSample-Config.AnalyzeFromSample):(Config.ERL.ToSample-Config.AnalyzeFromSample), i);

        if Config.ERL.Method == 1
            [pks, locs] = findpeaks(x);
            if length(locs) < 1
                % likely only happens if signal is monotonously decreasing
                ERLEveryTrial(i) = 0 + Config.ERL.FromSample-Config.AnalyzeFromSample;
            else
                ERLEveryTrial(i) = locs(1) + Config.ERL.FromSample-Config.AnalyzeFromSample;
            end
        elseif Config.ERL.Method == 2
            [pks, locs] = findpeaks(-x);
            if length(locs) < 1
                % likely only happens if signal is monotonously increasing
                ERLEveryTrial(i) = length(x) + Config.ERL.FromSample-Config.AnalyzeFromSample;
            else
                ERLEveryTrial(i) = locs(1) + Config.ERL.FromSample-Config.AnalyzeFromSample;
            end
        elseif Config.ERL.Method == 3
            xd2 = diff(x,2);
            zc = find(xd2(1:end-1).*xd2(2:end) < 0);
            inflections = zc - xd2(zc) ./ (xd2(zc+1) - xd2(zc));  % linear interpolation
            ERLEveryTrial(i) = inflections(1) + Config.ERL.FromSample-Config.AnalyzeFromSample;
        end

        if floor(ERLEveryTrial(i)) == ceil(ERLEveryTrial(i)) % if integer
            ERLVEveryTrial(i) = TrialsArray(ERLEveryTrial(i), i);
        else % if float. A little simplified but ok
            ERLVEveryTrial(i) = (TrialsArray(floor(ERLEveryTrial(i)), i) + TrialsArray(ceil(ERLEveryTrial(i)), i)) /2;
        end

%         plot(TrialsArray(:, i))
%         xline(ERLEveryTrial(i), 'r-')
%         yline(ERLVEveryTrial(i), 'r-')
%         xline(-1*Config.AnalyzeFromSample, 'g--')
%         % xline(Config.AnalyzeToSample, 'g--')
%         disp('eee')

    end

    % transform on the spot to millisec, relative to stimulus onset
    ERLEveryTrial = ERLEveryTrial / Meta.NomSRate * 1000 + Config.AnalyzeFromSec*1000;

end