function [ExcludedMask, InterpolPercentages] = FiltSweepsOnInterpolVBL(Samples, SearchBaseMask, TrigsForAlignment, TrigsVBL, ISISec, FilterConfig)

    ExcludedMask = false(length(TrigsForAlignment), 1);
    InterpolPercentages = support_calcInterpolPercentagesVBL(Samples.Ts, Samples.OrigSamplesTs, TrigsForAlignment, TrigsVBL, ISISec, Samples.SRate, Samples.OrigSRate);
        
    for i = 1:length(TrigsForAlignment)
        if ~SearchBaseMask(i)
            continue
        end

        if InterpolPercentages(i) > FilterConfig.Threshold
            ExcludedMask(i) = true;
        end

        if ExcludedMask(i)
            log_d(['Excluded trial nr. ' num2str(i)]);
        end
    end

end