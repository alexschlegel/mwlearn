function [hPrompt, hTest, hResponse, hFeedback, bLeftCorr] = SetupTask(mwlt, rotLevel, bPractice)
%  Set up the textures for one angle task.
%
%  Syntax: MWL.Angle.SetupTask(mwlt, rotStep, bPractice)
%
%  In:
%       mwlt   - the MWLearnTest object
%      rotStep - the difference in rotation between correct and incorrect
%                 figures. Ranges from 1 (hardest) to 90 (easiest).                 
%    bPractice - whether this is a practice trial
%
%  Out:
%    hPrompt - handle to the prompt texture
%        hOp - handle to the operation/instruction texture
%      hTest - handle to the test texture
%  hResponse - handle to the texture shown after the test figures disappear 
%  hFeedback - handle to the feedback texture (sans "yes" or "no")
%  bLeftCorr - whether the correct figure was on the left

% get the trial information
numIm = MWL.Param('angle','image','num');
colors = MWL.Param('angle','color');
iImage = randi(numIm);
myColor = colors{randi(numel(colors))};
image = MWL.Angle.GetImage(mwlt, iImage, myColor);
startAngle = randi(360)-1;
refAngles = MWL.Param('angle','refAngles');
df = abs(rotLevel - refAngles);
dfMin = find(df==min(df));
rotAngle = refAngles(dfMin(1));
bCW = logical(randi(2)-1); % figure is rotated clockwise
bDistractorLeft = logical(randi(2)-1); % incorrect figure is more CCW than correct figure
nStepMax = floor(MWL.Param('angle','maxRotation')./rotAngle);
nStep = randi(nStepMax);
degRotCorr = nStep*rotAngle*conditional(bCW,1,-1);
degRotIncorr = degRotCorr + rotLevel*conditional(bDistractorLeft,-1,1);
bLeftCorr = logical(randi(2)-1); % correct figure is positioned to the left

% gather and save information
global angleParam;
if ~bPractice
    trialInfo = struct('image', iImage, 'color', myColor, 'start_angle', startAngle, ...
        'rot_angle_correct', degRotCorr, 'rot_angle_incorrect', degRotIncorr, ...
        'angle_diff', rotLevel, 'pos_correct', conditional(bLeftCorr,'l','r'));
    if isempty(angleParam)
        angleParam = trialInfo;
    else
        angleParam(end+1) = trialInfo;
    end
    mwlt.Experiment.Info.Set('mwlt',{'angle','param'},angleParam);
    mwlt.Experiment.Log.Append('Trial parameters saved.');
end

% Prepare the textures
[~, ~, ~, screenDimVA] = mwlt.Experiment.Window.Get('main'); % screen size in visual angle
[widthVA, heightVA] = deal(screenDimVA(1), screenDimVA(2));
imSize = heightVA/3;
horzOffset = widthVA/4;

% PROMPT
hPrompt = mwlt.Experiment.Window.OpenTexture('prompt');
mwlt.Experiment.Show.Image(image, [0,-heightVA/6], imSize, startAngle, 'window', 'prompt');
[strAngle, strDirection] = MWL.Angle.rot2prompt(degRotCorr);
mwlt.Experiment.Show.Text(strAngle, [0,heightVA/3-1.5], 'window', 'prompt');
mwlt.Experiment.Show.Text(strDirection, [0, heightVA/3+1.5], 'window', 'prompt');

% TEST
hTest = mwlt.Experiment.Window.OpenTexture('test');
mwlt.Experiment.Show.Image(image, [-horzOffset, 0], imSize, ...
    startAngle + conditional(bLeftCorr,degRotCorr,degRotIncorr),'window','test');
mwlt.Experiment.Show.Image(image, [horzOffset, 0], imSize, ...
    startAngle + conditional(bLeftCorr,degRotIncorr,degRotCorr), 'window','test');

% RESPONSE (fixation crosses)
hResponse = mwlt.Experiment.Window.OpenTexture('response');
mwlt.Experiment.Show.Line('black',[-horzOffset, heightVA/8], [-horzOffset,-heightVA/8],'window','response');
mwlt.Experiment.Show.Line('black',[-horzOffset+heightVA/8,0], [-horzOffset-heightVA/8,0],'window','response');
mwlt.Experiment.Show.Line('black',[horzOffset, heightVA/8], [ horzOffset,-heightVA/8],'window','response');
mwlt.Experiment.Show.Line('black',[horzOffset+heightVA/8,0], [horzOffset-heightVA/8,0],'window','response');

% FEEDBACK
hFeedback = mwlt.Experiment.Window.OpenTexture('feedback');
if bLeftCorr
    mwlt.Experiment.Show.Image(image, [-horzOffset, 0], imSize, ...
        startAngle + degRotCorr, 'window','feedback');
else
    mwlt.Experiment.Show.Image(image, [horzOffset, 0], imSize, ...
        startAngle + degRotCorr, 'window','feedback');
end

end