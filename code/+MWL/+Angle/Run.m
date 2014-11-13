function Run(mwlt)
% MWL.Angle.Run
%
% Description: do a  mental angle rotation run
%
% Syntax: MWL.Angle.Run(mwlt)

% clear residual global variables
clear global angleParam;
clear global angleResult;

% switch to lr input scheme
mwlt.Experiment.Input.Set('response', {'left','right'});

mwlt.Experiment.Scheduler.Pause;

MWL.Angle.ShowInstructions(mwlt);

rng('shuffle');
% practice trials
numPractice = MWL.Param('angle','numPractice');
if numPractice > 0
    minPracticeAngle = MWL.Param('angle','minPracticeAngle');
    for nPractice = 1:numPractice
        MWL.Angle.RunOne(mwlt, randi([minPracticeAngle, 90]), true);
    end
end

mwlt.Experiment.Show.Instructions('The experiment will now begin.');

mwlt.Experiment.Scheduler.Resume;

% PsychoCurve parameters
a = MWL.Param('angle','psychocurve','targetFracCorrect');
g = MWL.Param('angle','psychocurve','baselineFracCorrect');
xstep = MWL.Param('angle','psychocurve','xstep');
t = MWL.Param('angle','psychocurve','start_t');

p = PsychoCurve('F',@NextTrial, 'a', a, 'g', g, 'xstep', xstep, 't', t );

numTrial = MWL.Param('angle','numTrial');
currTrial = 0;
rotStepRange = MWL.Param('angle','rotStep');
p.Run('itmin',numTrial, 'itmax',numTrial, 'silent', true);

% for final trial
lastCorrect = p.bResponse(end);
mwlt.Experiment.AddLog(['Response ' conditional(lastCorrect,'','in') 'correct. ']);
mwlt.Experiment.AddLog(['Final t: ' num2str(p.t)]);

mwlt.Experiment.Info.Set('mwlt',{'angle','psychoCurve'},p);
mwlt.Experiment.AddLog('PsychoCurve saved');

% clear global variables again
clear global angleParam;
clear global angleResult;

    function bResponseCorrect = NextTrial(x)
        if currTrial > 0 % log data about last trial
              lastCorrect = p.bResponse(end);
              mwlt.Experiment.AddLog(['Response ' conditional(lastCorrect,'','in') 'correct. ']);
              mwlt.Experiment.AddLog(['Current t: ' num2str(p.t)]);
        end
        currTrial = currTrial + 1;
        mwlt.Experiment.AddLog(['Trial ' num2str(currTrial) '/' num2str(numTrial) ': begin']);
        xScaled = x*range(rotStepRange);
        rotStep = round(xScaled + rotStepRange(1));
        bResponseCorrect = MWL.Angle.RunOne(mwlt, rotStep, false);
        mwlt.Experiment.AddLog(['Trial ' num2str(currTrial) '/' num2str(numTrial) ': end']);
    end
end