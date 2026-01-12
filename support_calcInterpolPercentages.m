function interpolPercentages = support_calcInterpolPercentages(ts, origSamplesTs, triggersForAlignment, ISISec, srate, origSrate)

    % TODO: calculate with better precision, also considering original srate?

    % NOTE: ISI is not used here, but could be implemented as a safety check

    interpolPercentages = nan(length(triggersForAlignment),1);

    for v = 1:length(triggersForAlignment)

        % E.g. when we are making a response-aligned analysis, and the subject has no response in a trial (or in the next trial !)
        if isnan(triggersForAlignment(v)) || ...
            (v < length(triggersForAlignment) && isnan(triggersForAlignment(v+1)))
            interpolPercentages(v) = NaN;
            continue;
        end


%         actualFromSample = find(ts >= triggersForAlignment(v), 1, 'first');
        actualFromSample = find(origSamplesTs >= triggersForAlignment(v), 1, 'first');
        if length(actualFromSample) ~= 1
            actualFromSample = NaN;
        end

        if v < length(triggersForAlignment)
%             actualToSample = find(ts <= triggersForAlignment(v+1), 1, 'last');
            actualToSample = find(origSamplesTs <= triggersForAlignment(v+1), 1, 'last');
            
            % invalid if the whole duration of this trial is before the
            % beginning of the recording
            if actualToSample == 1
                actualTosample = NaN;
            end
        else
%             actualToSample = length(origSamplesTs);
            actualToSample = find(origSamplesTs <= (triggersForAlignment(v)+ISISec*1000*1000), 1, 'last');
        end

% % %         actualFromSample
% % %         actualToSample
% % %         ~isnan(actualFromSample)
% % %         ~isnan(actualToSample)

        if ~isnan(actualFromSample) && ~isnan(actualToSample)
            actualLen = actualToSample - actualFromSample + 1;

            % IMPORTANT: we cannot beleive that the original timestamps and
            % samples vectors really contained all the needed samples

            %{
            if v < length(triggersForAlignment)
                theorLen = ceil( (triggersForAlignment(v+1) - triggersForAlignment(v) +1 ) / 1000 /1000 * srate );
            else
                theorLen = ceil( (origSamplesTs(end) - triggersForAlignment(v) +1 ) / 1000 /1000 * srate );
            end

            interpolRatios(v) = (1-(actualLen / theorLen)) *100;
            %}

            % NEM JÓ: mert azt kellene megtudnunk, hogy az új srate által
            % nézve, hány sample lenne a régi, ha nem lenne benne kivágás
            % sehol, és ehhez kell viszonyítani a kivágásos változatot

% %             actualLenSec = (ts(actualToSample)-ts(actualFromSample)) /1000 /1000;
%             actualLenSec = (origSamplesTs(actualToSample)-origSamplesTs(actualFromSample)) /1000 /1000;
            actualLenSecChk = actualLen / origSrate;
            if v < length(triggersForAlignment)
                theorLen = ceil((triggersForAlignment(v+1) - triggersForAlignment(v) +1 ) / 1000 /1000 * origSrate);
                theorLenSec = (triggersForAlignment(v+1) - triggersForAlignment(v) +1 ) / 1000 /1000;
            else
%                 % NOTE: We do not know the end of the last trial, but
%                 % assume it as the end of the recording, as there came no
%                 % new trial number changes after it
%                 theorLen = ceil((origSamplesTs(end) - triggersForAlignment(v) +1 ) / 1000 /1000 * origSrate);
%                 theorLenSec = (origSamplesTs(end) - triggersForAlignment(v) +1 ) / 1000 /1000;

                theorLen = NaN;
                theorLenSec = NaN;
                
                % NOTE: the last trial does not have a specific end, but
                % instead we can only rely on an expected endpoint, based
                % on the ISI. Let us use that here
                theorLen = ceil(ISISec * origSrate);
                theorLenSec = ISISec;

            end

%             disp("------------------")
% %             disp(actualLenSec)
%             disp(actualLenSecChk)
%             disp(theorLenSec)
%             disp(actualLen)
%             disp(theorLen)
%             disp("------------------")

            interpolPercentages(v) = (1-(actualLenSecChk / theorLenSec)) *100;
            
        end
    end

%     check1 = length(ts) == find(ts >= triggersForAlignment(end), 1, 'last');

end