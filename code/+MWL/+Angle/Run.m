function Run(mwlt)
% MWLearnTest.RunAngle
%
% Description: do a  mental angle rotation run
%
% Syntax: MWL.Angle.Run(mwlt)

% switch to lr input scheme
mwlt.Experiment.Input.Set('left', 'ltrigger');
mwlt.Experiment.Input.Set('right', 'rtrigger');
mwlt.Experiment.Input.Set('response', {'left','right'});

ShowInstructions(mwlt);

% practice trials
numPractice = MWL.Param('angle','numPractice');
if numPractice > 0
    degRotPractice = MWL.Param('angle','degRotPractice');
    mwlt.Experiment.Show.Instructions(['You will now have ' num2str(numPractice) ...
        ' practice trial' plural(numPractice, '', 's') '.']);
    for nPractice = 1:numPractice
        MWL.Angle.RunOne(mwlt, degRotPractice, true);
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

p = PsychoCurve('F',fNext, 'a', a, 'g', g, 'xmin', xmin, 'xmax', xmax, 'xstep', xstep, 't', t);

numTrial = MWL.Param('angle','numTrial');
p.Run('itmin',numTrial, 'itmax',numTrial, 'silent', true);

mwlt.Experiment.Info.Set('mwlt',{'angle','psychoCurve'},p);
end

%---INSTRUCTIONS------------------------------------------------------
function ShowInstructions(mwlt)
    sampleImage = cell2mat(MWL.Angle.GetImage(1));
    hSample = mwlt.Experiment.OpenTexture('sample', sampleImage);
    
end