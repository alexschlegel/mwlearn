function res = RunSims
% MWL.CI.RunSims
%
% Run simulations to test PsychoCurve.

nCore = 11;

dLevel = 0:0.1:1; 
b = (1:10)';
reps = 1000;
dLevelRep = repmat(dLevel, numel(b), 1);
bRep = repmat(b, 1, numel(dLevel));

% simulate parameters
noise = 0.2;
errThresh = 0.05;
maxTrials = 1000;
% simulate!
[res.trials2thresh, res.tError, res.bError] = MultiTask(@DoSimulation, {num2cell(dLevelRep), num2cell(bRep)},...
    'description', 'simulating trials','cores', nCore);
res.noise = noise;
res.errThresh = errThresh;
res.maxTrials = maxTrials;
res.runsPerCond = reps;

surf(dLevelRep, bRep, cell2mat(res.trials2thresh));


    function [trials2thresh, tError, bError] = DoSimulation(d,b)
        trials2thresh = 0;
        tError = zeros(maxTrials,1);
        bError = zeros(maxTrials,1);
        for k = 1:reps
            [curtError,curbError,~,currt2t] = MWL.CI.Simulate(d, b, 'noise', noise, ...
           'errThresh', errThresh, 'maxTrials', maxTrials, 'plot', false);
            tError(1:length(curtError)) = tError(1:length(curtError)) + curtError;
            bError(1:length(curbError)) = bError(1:length(curbError)) + curbError;
            trials2thresh = trials2thresh + currt2t;
        end
        trials2thresh = trials2thresh/reps;
        tError = tError./reps;
        bError = bError./reps;
    end
end
