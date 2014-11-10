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
if  strcmp(mwlt.Experiment.Info.Get('experiment','input'), 'joystick')
    mwlt.Experiment.Input.Set('left', 'lupper');
    mwlt.Experiment.Input.Set('right', 'rupper');
end
mwlt.Experiment.Input.Set('response', {'left','right'});

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

% PsychoCurve parameters
a = MWL.Param('angle','psychocurve','targetFracCorrect');
g = MWL.Param('angle','psychocurve','baselineFracCorrect');
xmin = MWL.Param('angle','psychocurve','xmin');
xmax = MWL.Param('angle', 'psychocurve','xmax');
xstep = MWL.Param('angle','psychocurve','xstep');
t = MWL.Param('angle','psychocurve','start_t');
fNext = @(x) MWL.Angle.RunOne(mwlt, x, false);

p = PsychoCurve('F',fNext, 'a', a, 'g', g, 'xmin', xmin, 'xmax', xmax, 'xstep', xstep, 't', t );

numTrial = MWL.Param('angle','numTrial');
p.Run('itmin',numTrial, 'itmax',numTrial, 'silent', true);

mwlt.Experiment.Info.Set('mwlt',{'angle','psychoCurve'},p);

% clear global variables again
clear global angleParam;
clear global angleResult;
end