function [interpol_ratio] = DQ_CalcInterpLossAnalogWhole(timestamp, orig_srate, trig_trial, trig_timestamp, ISIsec, StimOnScreenSec)

    startTime = trig_timestamp(1);
    if isnan(ISIsec) || isnan(StimOnScreenSec)
        log_w(['ISIsec or StimOnScreenSec parameter was found to be NaN. The end timestamp of the last trial could not be estimated accordingly.' newline() 'The last valid timestamp of all samples will be used instead.'])
        endTime = timestamp(end);
    else
        endTime = trig_timestamp(end) + (ISIsec+StimOnScreenSec)*1000*1000; % microsec
    end
    recDuration = endTime-startTime;

    log_d(['Cleaned recording begin timestamp: ' sprintf('\t') num2str( min(timestamp) ) ]);
    log_d(['Cleaned recording end timestamp: ' sprintf('\t') num2str( min(timestamp) ) ]);
    %
    log_d(['1 st trigger timestamp: ' sprintf('\t\t\t\t') num2str( trig_timestamp(1) ) ]);
    log_d(['Last trigger timestamp: ' sprintf('\t\t\t\t') num2str( trig_timestamp(end) ) ]);
    %
    log_d(['1 st trial begin timestamp: ' sprintf('\t\t\t') num2str( trig_timestamp(1) ) ]);
    log_d(['Last trial end timestamp: ' sprintf('\t\t\t') num2str( endTime ) ]);
    %
    log_d(['Duration of all trials, given the ISI considered (meaningful recording section): ' num2str( recDuration /1000 /1000) ' seconds' ]);
            

    theoreticalNumSamples = ceil( recDuration / 1000 /1000 * orig_srate );

    actualNumSamples = sum(timestamp>=startTime & timestamp<=endTime);

    interpol_ratio = (theoreticalNumSamples-actualNumSamples) / theoreticalNumSamples; % *100;

    log_i(['Interpolation percent of the meaningful recording section: ' num2str( interpol_ratio *100 ) ' %' ]);

end