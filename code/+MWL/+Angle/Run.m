function Run(mwlt)
% MWLearnTest.RunAngle
%
% Description: do a  mental angle rotation run
%
% Syntax: MWL.Angle.Run(mwlt)

% switch to lr input scheme
if  strcmp(mwlt.Experiment.Info.Get('experiment','input'), 'joystick')
    mwlt.Experiment.Input.Set('left', 'ltrigger');
    mwlt.Experiment.Input.Set('right', 'rtrigger');
end
mwlt.Experiment.Input.Set('response', {'left','right'});

ShowInstructions(mwlt);

rng('shuffle');
% practice trials
numPractice = MWL.Param('angle','numPractice');
if numPractice > 0
    mwlt.Experiment.Show.Instructions(['You will now have ' num2str(numPractice) ...
        ' practice trial' plural(numPractice, '', 's') '.']);
    for nPractice = 1:numPractice
        MWL.Angle.RunOne(mwlt, minPracticeAngle-1 + randi(91-minPracticeAngle), true);
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
    sample = MWL.Param('angle','sample');
    sampleImage = MWL.Angle.GetImage(mwlt, sample.image, sample.color);
    [hMain, winSize, winRect, winSizeVA] = mwlt.Experiment.Window.Get('main');
    winWVA = winSizeVA(1);
    winHVA = winSizeVA(2);
    hSample = mwlt.Experiment.Window.OpenTexture('sample', [winSize(1), winSize(2)/2]);
    
    mwlt.Experiment.Show.Instructions('In this test you will mentally rotate images.');
    
    mwlt.Experiment.Show.Image(sampleImage, [], winHVA/3, sample.startAngle, 'window', hSample);
    mwlt.Experiment.Show.Instructions('First, you will see an image.', 'figure', hSample);
    
    mwlt.Experiment.Show.Blank('window',hSample);
    [strAngle, strDirection] = MWL.Angle.rot2prompt(sample.degRotCorr);
    mwlt.Experiment.Show.Text(strAngle, [0,-1.5], 'window', hSample);
    mwlt.Experiment.Show.Text(strDirection, [0, 1.5], 'window', hSample);
    mwlt.Experiment.Show.Instructions(['Next, the image will disappear and you will see an angle in degrees and a direction (CW or CCW).\n'...
        'In your mind, rotate the image by the amount and in the direction shown.'], ...
        'figure', hSample);
    
    mwlt.Experiment.Show.Blank('window',hSample);
    mwlt.Experiment.Show.Image(sampleImage, [-winWVA/4, 0], winHVA/3, ...
        sample.startAngle + switch2(sample.correctPos, 'left', sample.degRotCorr, 'right', sample.degRotIncorr), 'window',hSample);
    mwlt.Experiment.Show.Image(sampleImage, [winWVA/4, 0], winHVA/3, ...
        sample.startAngle + switch2(sample.correctPos, 'right', sample.degRotCorr, 'left', sample.degRotIncorr), 'window',hSample);
    mwlt.Experiment.Show.Instructions(['Finally, you will see two versions of the image.\n' ...
        'Using the left or right trigger button, choose the version that best matches the rotated image in your head.'], ...
        'figure', hSample);
    
    mwlt.Experiment.Show.Blank('window',hSample);
    mwlt.Experiment.Show.Line('black',[-winWVA/4, winHVA/12], [-winWVA/4,-winHVA/12],'window',hSample);    
    mwlt.Experiment.Show.Line('black',[-winWVA/4+winHVA/12,0], [-winWVA/4-winHVA/12,0],'window',hSample);    
    mwlt.Experiment.Show.Line('black',[winWVA/4, winHVA/12], [ winWVA/4,-winHVA/12],'window',hSample);
    mwlt.Experiment.Show.Line('black',[winWVA/4+winHVA/12,0], [winWVA/4-winHVA/12,0],'window',hSample);
    mwlt.Experiment.Show.Instructions(['The images will disappear after '...
        num2str(MWL.Param('angle','time','test')/1000) ' seconds. However, you will have an additional '...
        num2str(MWL.Param('angle','time','pause')/1000) ' seconds to respond.'], 'figure',hSample);
    
    numPractice = MWL.Param('angle','numPractice');
    if numPractice > 0
        mwlt.Experiment.Show.Instructions(['You will now have ' num2str(numPractice) ' practice trials.'], 'next', 'begin');
    end
    
    mwlt.Experiment.Window.CloseTexture('sample');
end