function [TrialsArray, ConfsArray] = support_SplitIntoSweeps(Samples, SearchBaseMask, TrigsForAlignment, TimeDefs, PerformTJC)

    % NOTE: first index is trial length in samples, second is number of trials
    TrialsArray = NaN(TimeDefs.AnalyzeLenSample, length(TrigsForAlignment));
    ConfsArray = NaN(TimeDefs.AnalyzeLenSample, length(TrigsForAlignment));
    
    for i = 1:length(TrigsForAlignment)
        
        if ~SearchBaseMask(i)
           continue;
        end
        
        BeginAtSample = find(Samples.Ts >= TrigsForAlignment(i), 1, 'first') + TimeDefs.AnalyzeFromSample;

        if ~PerformTJC
%             disp(i)
%             disp(BeginAtSample:(BeginAtSample+TimeDefs.AnalyzeLenSample-1))
            if(BeginAtSample < 1)
                log_e('Wrongly specified trigger timestamps and/or variable-baseline (VBL) timestamps');
            end
            TrialsArray(:,i) = Samples.Pupdil( BeginAtSample:(BeginAtSample+TimeDefs.AnalyzeLenSample-1) );

        else

            % will work only if the eye data sampling rate is at least 10hz
            PastConsideredSec = 0.1; 
            PastConsideredSample = ceil(PastConsideredSec * Samples.Srate);
            
            Mask = (BeginAtSample-PastConsideredSample):(BeginAtSample+analyzeLenSample-1);

            SweepSamples = Samples.Pupdil(Mask);
            SweepTimestampsAbs = Samples.Ts(Mask);
            SweepTimestampsRel = SweepTimestampsAbs - TrigsForAlignment(i) - TimeDefs.AnalyzeFromSample/Samples.Srate*1000*1000; % + pastConsideredSec*1000*1000; 
            JitterToRemove = SweepTimestampsRel(1) + PastConsideredSample/Samples.Srate*1000*1000;

            % this is needed because interp1 can only query points of a positive range when the interpolant was 
            % made on a positive ranging vector (idk why, but it appears to be like this)
            ShiftInput = SweepTimestampsRel(1);
            SweepTimestampsRel = SweepTimestampsRel - ShiftInput;
            
            NewX = linspace(0, TimeDefs.AnalyzeLenSample/Samples.Srate*1000*1000, TimeDefs.AnalyzeLenSample); % microsec
            NewX = NewX - ShiftInput;
            NewY = interp1(SweepTimestampsRel, SweepSamples, NewX, 'pchip');

%             % NOTE: this is just left here if you want to inspect how it works
%             plot(SweepTimestampsRel, SweepSamples, 'b-');
%             hold on
%             xline(0 - ShiftInput + JitterToRemove, 'b-')
%             plot(NewX, NewY, 'g-')
%             xline(0 - ShiftInput, 'g-')
%             hold off
    
            TrialsArray(:,i) = NewY;
        end
        
        % -------------------------------------
        % also calculate confidence metric 
        %
        % TODO: NOT ONLY AVERAGE BUT VAR/SD TOO !! ("which is the most
        % variable part of the event related curve, regarding its pupil
        % confidence")
        %
        % TODO: make lowFPS trigger jitter corrected version
        
        if ~isnan(Samples.QualityValues.Conf)
            ConfsArray(:,i) = Samples.QualityValues.Conf( BeginAtSample:(BeginAtSample+TimeDefs.AnalyzeLenSample-1) );
        else
            ConfsArray(:,i) = NaN;
        end
    end

end