% Check trial timings on data in workspace

for i = 1:length(locDATA.timing.blockStart)-1
    trialLength(i) = locDATA.timing.blockStart(i+1)-locDATA.timing.blockStart(i);
end