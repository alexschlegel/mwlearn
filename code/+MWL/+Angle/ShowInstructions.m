function ShowInstructions(mwlt)
% MWL.Angle.ShowInstructions
%
% Description: shows instructions for the angle/rotate task.
%
% Syntax: MWL.Angle.ShowInstructions(mwlt)
%
% In: mwlt - the MWLearnTest object

sample = MWL.Param('angle','sample');
sampleImage = MWL.Angle.GetImage(mwlt, sample.image, sample.color);
[strAngle, strDirection] = MWL.Angle.rot2prompt(sample.degRotCorr);
[hMain, winSize, winRect, winSizeVA] = mwlt.Experiment.Window.Get('main');
winWVA = winSizeVA(1);
winHVA = winSizeVA(2);
imSize = winHVA/4;
horzOffset = 3*winWVA/16;

mwlt.Experiment.Show.Instructions('This task tests your ability to mentally rotate images.');

hSample = mwlt.Experiment.Window.OpenTexture('sample', [winSize(1), 2*winSize(2)/3]);
mwlt.Experiment.Show.Image(sampleImage, [0,-winHVA/12], imSize, sample.startAngle, 'window', hSample);
mwlt.Experiment.Show.Text(strAngle, [0,winHVA/4-1], 'window', hSample);
mwlt.Experiment.Show.Text(strDirection, [0, winHVA/4+1], 'window', hSample);

mwlt.Experiment.Show.Instructions('First, you will see an image, along with\nan angle (in degrees) and a direction (CW or CCW).','figure', hSample);
mwlt.Experiment.Show.Instructions('In your mind, rotate the image by the amount and in the direction shown.','figure', hSample);

mwlt.Experiment.Show.Blank('window',hSample);
mwlt.Experiment.Show.Instructions('The prompt will disappear, but keep the rotated image in your mind.','figure',hSample);

mwlt.Experiment.Window.CloseTexture('sample');
hSample2 = mwlt.Experiment.Window.OpenTexture('sample2', [winSize(1), winSize(2)/2]);

mwlt.Experiment.Show.Blank('window',hSample2);
mwlt.Experiment.Show.Image(sampleImage, [-horzOffset, 0], imSize, ...
    sample.startAngle + switch2(sample.correctPos, 'left', sample.degRotCorr, 'right', sample.degRotIncorr), 'window',hSample2);
mwlt.Experiment.Show.Image(sampleImage, [horzOffset, 0], imSize, ...
    sample.startAngle + switch2(sample.correctPos, 'right', sample.degRotCorr, 'left', sample.degRotIncorr), 'window',hSample2);
mwlt.Experiment.Show.Instructions(['Next, you will see two versions of the image.\n' ...
    'Choose the version that best matches the rotated image in your head, by pressing the left or right upper back button.'], ...
    'figure', hSample2);

mwlt.Experiment.Show.Blank('window',hSample2);
mwlt.Experiment.Show.Line('black',[-horzOffset, winHVA/16], [-horzOffset,-winHVA/16],'window',hSample2);
mwlt.Experiment.Show.Line('black',[-horzOffset+winHVA/16,0], [-horzOffset-winHVA/16,0],'window',hSample2);
mwlt.Experiment.Show.Line('black',[horzOffset, winHVA/16], [ horzOffset,-winHVA/16],'window',hSample2);
mwlt.Experiment.Show.Line('black',[horzOffset+winHVA/16,0], [horzOffset-winHVA/16,0],'window',hSample2);
mwlt.Experiment.Show.Instructions(['The images will disappear after '...
    num2str(MWL.Param('angle','time','test')/1000) ' seconds. However, you will have an additional '...
    num2str(MWL.Param('angle','time','response')/1000) ' seconds to respond.'], 'figure',hSample2);

mwlt.Experiment.Show.Blank('window',hSample2);
mwlt.Experiment.Show.Image(sampleImage, [horzOffset*switch2(sample.correctPos, 'left',-1,'right',1),0], imSize, ...
    sample.startAngle + sample.degRotCorr, 'window', hSample2);
mwlt.Experiment.Show.Text(['<color:green>Yes!</color>'], [0,0],'center',true,'window', hSample2);
mwlt.Experiment.Show.Instructions('Finally, you will be told whether your response was correct.','figure',hSample2);

numPractice = MWL.Param('angle','numPractice');
if numPractice > 0
    mwlt.Experiment.Show.Instructions(['You will now have ' num2str(numPractice) ' practice trials.'], 'next', 'begin');
end

mwlt.Experiment.Window.CloseTexture('sample2');
end