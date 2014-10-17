function RunSims
% MWL.CI.RunSims
%
% Run simulations to test PsychoCurve.

nCore = 11;

dLevel = 0:0.1:1; 
b = (1:10)';
reps = 10;

dLevelRep = repmat(dLevel, numel(b), 1);
bRep = repmat(b, 1, numel(dLevel));

% simulate parameters
noise = 0.2;
errThresh = 0.1;
maxTrials = 1000;
% simulate!
trials2thresh = MultiTask(@DoSimulation, {num2cell(dLevelRep), num2cell(bRep)},...
    'description', 'simulating trials','nthread', nCore);

surf(dLevelRep, bRep, cell2mat(trials2thresh));


    function trials2thresh = DoSimulation(d,b)
        trials2thresh = 0;
        for k = 1:reps
            [~,~,~,currt2t] = MWL.CI.Simulate(d, b, 'noise', noise, ...
           'errThresh', errThresh, 'maxTrials', maxTrials, 'plot', false);
            trials2thresh = trials2thresh + currt2t;
        end
        trials2thresh = trials2thresh/reps;
    end
end
