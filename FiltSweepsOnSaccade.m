function ExcludedMask = FiltSweepsOnSaccade(Saccades, SearchBaseMask, TrigsForAlignment, FilterConfig)

    ExcludedMask = false(length(TrigsForAlignment), 1);
    for i = 1:length(TrigsForAlignment)
        if ~SearchBaseMask(i)
            continue
        end

        if sum(Saccades.Magnitude(i) >= FilterConfig.Magnitude & Saccades.StartTs>=(TrigsForAlignment(i)+(FilterConfig.FromSec*1000*1000)) & Saccades.StartTs<=(TrigsForAlignment(i)+(FilterConfig.ToSec*1000*1000))) > 0 || ...
            sum(Saccades.Magnitude(i) >= FilterConfig.Magnitude & Saccades.EndTs>=(TrigsForAlignment(i)+(FilterConfig.FromSec*1000*1000)) & Saccades.EndTs<=(TrigsForAlignment(i)+(FilterConfig.ToSec*1000*1000))) > 0 || ...
            sum(Saccades.Magnitude(i) >= FilterConfig.Magnitude & Saccades.StartTs<(TrigsForAlignment(i)+(FilterConfig.FromSec*1000*1000)) & Saccades.EndTs>(TrigsForAlignment(i)+(FilterConfig.ToSec*1000*1000))) > 0
            % NOTE: MICROSEC
            
            ExcludedMask(i) = true;
        end

        if ExcludedMask(i)
            log_d(['Excluded trial nr. ' num2str(i)]);
        end
    end
    
end