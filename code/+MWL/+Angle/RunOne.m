function bResponseCorrect = RunOne(mwlt, rotStep, bPractice)
% Run one image rotation task. This is the function
% passed to PsychoCurve.
%
%   Syntax: MWL.Angle.RunOne(mwlt, dLevel)
%
%   In:  mwlt   - the MWLearnTest object
%        degRot - the difference in rotation between correct and incorrect
%                 figures. Ranges from 1 (hardest) to 90 (easiest).                 
%     bPractice - whether this is a practice trial
%
%   Out: bResponseCorrect  - logical indicating correctness of
%                            response.

% get the trial information
numIm = MWL.Param('angle','image','num');
colors = MWL.Param('angle','color');
iImage = Randi(numIm);
myColor = colors{Randi(numel(colors))};
image = MWL.GetImage(mwlt, iImage, myColor);
startAngle = Randi(360)-1;
refAngles = MWL.Param('angle','refAngles');
df = abs(rotStep - refAngles);
rotAngle = refAngles(df==min(df));
bCW = logical(Randi(2)-1); % figure is rotated clockwise
bDistractorLeft = logical(Randi(2)-1); % incorrect figure is more CCW than correct figure
nStepMax = floor(MWL.Param('angle','maxRotation')./rotAngle);
nStep = Randi(nStepMax);
degRotCorr = nStep*rotAngle*conditional(bCW,1,-1);
degRotIncorr = degRotCorr + rotStep*conditional(bDistractorLeft,-1,1);
bLeftCorr = logical(Randi(2)-1); % correct figure is positioned to the left

% gather and save information
persistent param;
if ~bPractice
    trialInfo = struct('image', iImage, 'color', myColor, 'start_angle', startAngle, ...
        'rot_angle_correct', degRotCorr, 'rot_angle_incorrect', degRotIncorr, ...
        'pos_correct', conditional(bLeftCorr,'l','r'));
    param(end+1) = trialInfo;
    mwlt.Experiment.Info.Set('mwlt',{'angle','param'},param);
    mwlt.Experiment.Log.Append('Trial parameters saved.');
end

% Prepare the textures
[~, ~, ~, screenDimVA] = mwlt.Experiment.Window.Get('main'); % screen size in visual angle
[widthVA, heightVA] = deal(screenDimVA(1), screenDimVA(2));
horzOffset = widthVA/4;
% PROMPT
hPrompt = mwlt.Experiment.Window.OpenTexture('prompt');
mwlt.Experiment.Show.Image(image, [], heightVA/2, startAngle, 'window', 'prompt');

% OPERATION
hOp = mwlt.Experiment.Window.OpenTexture('operation');
[strAngle, strDirection] = MWL.Angle.rot2prompt(sample.degRotCorr);
mwlt.Experiment.Show.Text(strAngle, [0,-1.5], 'window', 'operation');
mwlt.Experiment.Show.Text(strDirection, [0, 1.5], 'window', 'operation');

% TEST
hTest = mwlt.Experiment.Window.OpenTexture('test');
mwlt.Experiment.Show.Image(image, [-horzOffset, 0], heightVA/2, ...
    startAngle + conditional(bLeftCorr,degRotCorr,degRotIncorr),'window','test');
mwlt.Experiment.Show.Image(image, [horzOffset, 0], heightVA/2, ...
    startAngle + conditional(bLeftCorr,degRotIncorr,degRotCorr), 'window','test');

% 
end

