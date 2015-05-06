function res = ConfidenceSims
% MWL.CI.ConfidenceSims
%
% Run simulations to test PsychoCurve. This function finds the average
% 95% confidence interval at each step, for a range of t values.
global strDirCode;

nCore = 11;

dLevel = 0:0.1:1; 
b = 5;
runs = 1000;
%dLevelRep = repmat(dLevel, runs, 1);

% simulation parameters
noise = 0.2;
numTrials = 100;
% % simulate!
% [~,~,p,~] = MultiTask(@(d) MWL.CI.Simulate(d, b, 'noise', noise,...
%     'numTrials', numTrials, 'plot', false), {num2cell(dLevelRep)},...
%     'description', 'simulating trials','cores', nCore);
% 
% save(PathUnsplit(strDirCode, 'confSimTemp','mat'));
% res = [];

load(PathUnsplit(strDirCode, 'confSimTemp','mat'),'p');

tHist = cellfun(@(p) p.hist.t, p, 'uni',false);

%test = CalculateCI(dLevel(4), 1);

[dLevelGrid, numTrialGrid] = meshgrid(dLevel, 1:numTrials);
for d = 1:numel(dLevel)
    res.ci95(:,d) = MultiTask(@CalculateCI, {{tHist(:,d)}, dLevel(d), num2cell((1:numTrials)'), runs},...
        'description', 'calculating confidence intervals', 'cores', nCore,'debug','all','debug_communicator','all');
end



res.ci95 = cell2mat(res.ci95);
res.noise = noise;
res.numTrials = numTrials;
res.runsPerCond = runs;
res.b = b;
res.dLevelGrid = dLevelGrid;
res.numTrialGrid = numTrialGrid;

res.meanci95 = mean(res.ci95,2);

save(PathUnsplit(strDirCode,'confSim','mat'),'res');

surf(dLevelGrid, numTrialGrid, res.ci95);
figure;
plot(1:numTrials, res.meanci95);


end

function ci95 = CalculateCI(tHist, thisDLevel, thisNumTrial, runs)
% Calcualte the 95% confidence interval for a dLevel after a
% certain number of trials.
arrT = cellfun(@(tH) tH(thisNumTrial), tHist);
tErr = abs((1-arrT)-thisDLevel);
[n,x] = hist(tErr, 100);
auc = cumsum(n)/runs;
ci95 = x(abs(auc-0.95)==min(abs(auc-0.95)));
ci95 = ci95(1);
end

