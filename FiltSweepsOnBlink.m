function ExcludedMask = FiltSweepsOnBlink(Blinks, SearchBaseMask, TrigsForAlignment, FilterConfig)

    ExcludedMask = false(length(TrigsForAlignment), 1);
    for i = 1:length(TrigsForAlignment)
        if ~SearchBaseMask(i)
            continue
        end

        if sum(Blinks.StartTs>=(TrigsForAlignment(i)+(FilterConfig.FromSec*1000*1000)) & Blinks.StartTs<=(TrigsForAlignment(i)+(FilterConfig.ToSec*1000*1000))) > 0 || ...
            sum(Blinks.EndTs>=(TrigsForAlignment(i)+(FilterConfig.FromSec*1000*1000)) & Blinks.EndTs<=(TrigsForAlignment(i)+(FilterConfig.ToSec*1000*1000))) > 0 || ...
            sum(Blinks.StartTs<(TrigsForAlignment(i)+(FilterConfig.FromSec*1000*1000)) & Blinks.EndTs>(TrigsForAlignment(i)+(FilterConfig.ToSec*1000*1000))) > 0
        
            % NOTE: MICROSEC
            ExcludedMask(i) = true;
        end

        if ExcludedMask(i)
            log_d(['Excluded trial nr. ' num2str(i)]);
        end
    end

end