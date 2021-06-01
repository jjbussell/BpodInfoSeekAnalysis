a.trial = [];

for f = 1:max(a.file)
   trialCt = sum(a.file==f);
   trials = (1:trialCt)';
   a.trial = [a.trial; trials];
end