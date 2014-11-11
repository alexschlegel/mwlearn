function Run(mwlt)
% MWL.Assemblage.Run
%
% Description: do an assemblage test run
%
% Syntax: MWL.Assemblage.Run(mwlt)

% clear residual global variables
clear global AssemblageResult;

% switch to lrud input scheme
if strcmp(mwlt.Experiment.Info.Get('experiment','input'), 'joystick')
    mwlt.Experiment.Input.Set('left', 'x');
    mwlt.Experiment.Input.Set('right', 'b');
end
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

dLevel = MWL.Param('assemblage','dLevel');

% run!
p = PsychoCurve('F',@NextTrial, 'a', a, 'g', g, 'xstep', xstep, 't', t);
p.Run('itmin',numTrial, 'itmax',numTrial, 'silent', true);

% save psychocurve object
mwlt.Experiment.Info.Set('mwlt',{'assemblage','psychoCurve'},p);

% clear global variables again
clear global AssemblageResult;

    function bResponseCorrect = NextTrial(x)
        d = 1-x;
        dScaled = d*(dLevel(end)-dLevel(1));
        dLevelCurr = round(dScaled + dLevel(1));
        bResponseCorrect = MWL.Assemblage.RunOne(mwlt, dLevelCurr);
    end
end