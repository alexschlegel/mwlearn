function Run(mwlt)
% MWL.Assemblage.Run
%
% Description: do an assemblage test run
%
% Syntax: MWL.Assemblage.Run(mwlt)

% clear residual global variables
clear global AssemblageResult;

% switch to lrud input scheme
mwlt.Experiment.Input.Set('response',{'left','right','up','down'});

MWL.Assemblage.ShowInstructions(mwlt);

% Get experiment parameters
numPractice = MWL.Param('assemblage','numPractice');
numTrial = MWL.Param('assemblage','numTrial');

% practice trials
% increases difficulty at a constant (but discrete) rate within the range
% of dLevelPractice, for numPractice trials.
if numPractice > 0
    dLevelPractice = MWL.Param('assemblage','dLevelPractice');
    if numPractice > 1
        dLPracticeStep = (dLevelPractice(end) - dLevelPractice(1))/(numPractice-1);
    else
        dLPracticeStep = 1;
    end
    mwlt.Experiment.Show.Instructions(['You will now have ' num2str(numPractice) ...
        ' practice trial' plural(numPractice, '', 's') '.']);
    for nPractice = 1:numPractice
        MWL.Assemblage.RunOne(mwlt, dLevelPractice(1)+round((nPractice-1)*dLPracticeStep), 'practice');
    end
end

mwlt.Experiment.Show.Instructions('The experiment will now begin.');

% PsychoCurve parameters
a = MWL.Param('assemblage','psychocurve','targetFracCorrect');
g = MWL.Param('assemblage','psychocurve','baselineFracCorrect');
xstep = MWL.Param('assemblage','psychocurve','xstep');
t = MWL.Param('assemblage','psychocurve','start_t');

dLevelRange = MWL.Param('assemblage','dLevel');
currTrial = 0;

% run!
p = PsychoCurve('F',@NextTrial, 'a', a, 'g', g, 'xstep', xstep, 't', t);
p.Run('itmin',numTrial, 'itmax',numTrial, 'silent', true);

% for final trial
lastCorrect = p.bResponse(end);
mwlt.Experiment.AddLog(['Response ' conditional(lastCorrect,'','in') 'correct. ']);
mwlt.Experiment.AddLog(['Final t: ' num2str(p.t)]);

% save psychocurve object
mwlt.Experiment.Info.Set('mwlt',{'assemblage','psychoCurve'},p);
mwlt.Experiment.AddLog('PsychoCurve saved');

% clear global variables again
clear global AssemblageResult;

    function bResponseCorrect = NextTrial(x)
        if currTrial > 0 % log data about last trial
              lastCorrect = p.bResponse(end);
              mwlt.Experiment.AddLog(['Response ' conditional(lastCorrect,'','in') 'correct. ']);
              mwlt.Experiment.AddLog(['Current t: ' num2str(p.t)]);
        end
        currTrial = currTrial + 1;
        mwlt.Experiment.AddLog(['Trial ' num2str(currTrial) '/' num2str(numTrial) ': begin']);
        d = 1-x;
        dScaled = d*(range(dLevelRange));
        dLevel = round(dScaled + dLevelRange(1));
        bResponseCorrect = MWL.Assemblage.RunOne(mwlt, dLevel);
        mwlt.Experiment.AddLog(['Trial ' num2str(currTrial) '/' num2str(numTrial) ': end']);
    end
end