function TrialsArray = support_DisregardTrialSections(TrialsArray, Config, Meta)
    
    for v = 1:size(Config.DisregardTrialSections, 1)
        trialToBother = Config.DisregardTrialSections{v, 1};
        disregardSectionSample = (Config.DisregardTrialSections{v, 2} * Meta.NomSRate);
        disregardSectionSample = disregardSectionSample - Config.AnalyzeFromSample; 
        TrialsArray(disregardSectionSample(1):disregardSectionSample(2), trialToBother) = NaN(disregardSectionSample(2)-disregardSectionSample(1)+1, 1);
    end
    log_d(['Number of NaNs after disregarding selected trial sections ' num2str(sum(sum(isnan(TrialsArray))))])

end