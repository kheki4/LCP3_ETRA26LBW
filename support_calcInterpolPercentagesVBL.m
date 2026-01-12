function [interpolPercentages_fromVBLToStimOnset, interpolPercentages_fromStimOnsetToStimOffset]  = support_calcInterpolPercentagesVBL(ts, origSamplesTs, triggersForAlignment, triggersVBL, ISISec, StimOnScreenSec, srate, origSrate)

    % TODO: calculate with better precision, also considering original srate?

    % NOTE: ISI is not used here, but could be implemented as a safety check

    interpolPercentages_fromVBLToStimOnset = nan(length(triggersForAlignment),1);
    interpolPercentages_fromStimOnsetToStimOffset = nan(length(triggersForAlignment),1);

    for v = 1:length(triggersForAlignment)

        % E.g. when we are making a response-aligned analysis, and the subject has no response in a trial (or in the next trial !)
        if isnan(triggersForAlignment(v)) || ...
            (v < length(triggersForAlignment) && isnan(triggersForAlignment(v+1)))
            interpolPercentages(v) = NaN;
            continue;
        end

        % NOTE: legujabban hozzaadott resz ez. Ha ket vektor ugyanaz, akkor
        % eleg az egymast koveto triggersForAlignment-ek kozti idot nezni,
        % és ekkor az elso triggersForAlignment elem a legelso inger
        % prezentalasa, egy egyben a legelso BL corr timestampjenek
        % meghatarozoja. Ha nem egyenlok, akkor a triggrsVBL elso eleme a
        % legelso kronologiai sorrendben, majd utana valamikor az inger
        % bemutatasat jelzi a triggersForAlignment elso eleme.
        if isequal(triggersVBL, triggersForAlignment)
            thisFirstTs_A = triggersForAlignment(v);
%             thisFirstTs_B = triggersForAlignment(v+1);
            if(v < length(triggersForAlignment))

                thisFirstTs_B = triggersForAlignment(v+1);

                thisLastTs_A = triggersForAlignment(v+1);
                thisLastTs_B = triggersForAlignment(v+1) + StimOnScreenSec*1000*1000;
            end
        else
            thisFirstTs_A = triggersVBL(v);
            thisFirstTs_B = triggersForAlignment(v);
            thisLastTs_A = triggersForAlignment(v);
            thisLastTs_B = triggersForAlignment(v) + StimOnScreenSec*1000*1000;
        end


%         actualFromSample = find(ts >= triggersForAlignment(v), 1, 'first');
        actualFromSample_A = find(origSamplesTs >= thisFirstTs_A, 1, 'first');
        actualFromSample_B = find(origSamplesTs >= thisFirstTs_B, 1, 'first');
        
        if length(actualFromSample_A) ~= 1
            actualFromSample_A = NaN;
        end
        if length(actualFromSample_B) ~= 1
            actualFromSample_B = NaN;
        end

        if      (isequal(triggersVBL, triggersForAlignment) && v < length(triggersForAlignment)) || ...
                (~isequal(triggersVBL, triggersForAlignment) && v <= length(triggersForAlignment))

%             actualToSample = find(ts <= triggersForAlignment(v+1), 1, 'last');
            actualToSample_A = find(origSamplesTs <= thisLastTs_A, 1, 'last');
            actualToSample_B = find(origSamplesTs <= thisLastTs_B, 1, 'last');
            
            % invalid if the whole duration of this trial is before the
            % beginning of the recording
            if actualToSample_A == 1
                actualTosample_A = NaN;
            end
            if actualToSample_B == 1
                actualTosample_B = NaN;
            end
        else
%             actualToSample = length(origSamplesTs);
            actualToSample_A = find(origSamplesTs <= (triggersForAlignment(v)+(ISISec)*1000*1000), 1, 'last');
            actualToSample_B = find(origSamplesTs <= (triggersForAlignment(v)+(ISISec+StimOnScreenSec)*1000*1000), 1, 'last');
        end

% % %         actualFromSample
% % %         actualToSample
% % %         ~isnan(actualFromSample)
% % %         ~isnan(actualToSample)

        if ~isnan(actualFromSample_A) && ~isnan(actualFromSample_B) && ~isnan(actualToSample_A) && ~isnan(actualToSample_B)
%             %actualLen = actualToSample - actualFromSample + 1; % NÉHA TÖBBET HOZ KI MINT KÉNE
%             actualLen = actualToSample - actualFromSample + 0.5; % tegyük fel hogy 50-50 eséllyel lövünk alá és felé az új alacsonyabb FPS rate által a trigger timestampek helyére
            actualLen_A = actualToSample_A - actualFromSample_A; % pol.korrekt változat
            actualLen_B = actualToSample_B - actualFromSample_B; % pol.korrekt változat            

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
            actualLenSecChk_A = actualLen_A / origSrate;
            actualLenSecChk_B = actualLen_B / origSrate;
            if      (isequal(triggersVBL, triggersForAlignment) && v < length(triggersForAlignment)) || ...
                    (~isequal(triggersVBL, triggersForAlignment) && v <= length(triggersForAlignment))

                theorLen_A = ceil((thisLastTs_A - thisFirstTs_A +1 ) / 1000 /1000 * origSrate);
                theorLenSec_A = (thisLastTs_A - thisFirstTs_A +1 ) / 1000 /1000;
                theorLen_B = ceil((thisLastTs_B - thisFirstTs_B +1 ) / 1000 /1000 * origSrate);
                theorLenSec_B = (thisLastTs_B - thisFirstTs_B +1 ) / 1000 /1000;
                
            else
%                 % NOTE: We do not know the end of the last trial, but
%                 % assume it as the end of the recording, as there came no
%                 % new trial number changes after it
%                 theorLen = ceil((origSamplesTs(end) - triggersForAlignment(v) +1 ) / 1000 /1000 * origSrate);
%                 theorLenSec = (origSamplesTs(end) - triggersForAlignment(v) +1 ) / 1000 /1000;

                theorLen_A = NaN;
                theorLenSec_A = NaN;
                theorLen_B = NaN;
                theorLenSec_B = NaN;
                
                % NOTE: the last trial does not have a specific end, but
                % instead we can only rely on an expected endpoint, based
                % on the ISI. Let us use that here
                theorLen_A = ceil(ISISec * origSrate);
                theorLenSec_A = ISISec;
                theorLen_B = ceil(StimOnScreenSec * origSrate);
                theorLenSec_B = StimOnScreenSec;

            end

%             disp("------------------")
% %             disp(actualLenSec)
%             disp(actualLenSecChk)
%             disp(theorLenSec)
%             disp(actualLen)
%             disp(theorLen)
%             disp("------------------")

            interpolPercentages_fromVBLToStimOnset(v) = (1-(actualLenSecChk_A / theorLenSec_A)) *100;
            interpolPercentages_fromStimOnsetToStimOffset(v) = (1-(actualLenSecChk_B / theorLenSec_B)) *100;

            if interpolPercentages_fromVBLToStimOnset(v) < 0 || interpolPercentages_fromStimOnsetToStimOffset(v) < 0
                log_w('Imprecision')
            end
            
        end
    end

%     check1 = length(ts) == find(ts >= triggersForAlignment(end), 1, 'last');

end