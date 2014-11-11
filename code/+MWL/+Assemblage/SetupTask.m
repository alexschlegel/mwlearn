function [hPrompt, tPrompt, hTest, hFeedback, posCorrect, assemblages] = SetupTask(mwlt, dLevel)
%  Set up the textures for one assemblage task.
%
%  Syntax: [hPrompt, tPrompt, hTest, hFeedback, posCorrect, assemblages] = MWL.Assemblage.SetupTask(mwlt,dLevel)
%
%  In:
%       mwlt - the MWLearnTest experiment object.
%     dLevel - current difficulty level (1 -> 10)
%
%  Out:
%     hPrompt - handle to the prompt texture
%     tPrompt - time to show the prompt texture
%       hTest - handle to the test texture
%   hFeedback - handle to feedback texture
%  posCorrect - indicates the position of the correct figure, clockwise
%               starting from the top.
% assemblages - a cell of assemblages, in order of position (clockwise from top)

aTarget		= MWL.Assemblage.Create(mwlt.Experiment,'steps',dLevel);
aDistractor	= aTarget.createDistractors(3);

[assemblages,kRand]	= randomize([{aTarget}; aDistractor]);
kUnRand				= zeros(size(kRand));
kUnRand(kRand)		= 1:numel(kRand);
posCorrect			= kUnRand(1);

%show the prompt
	

%show the test screen
	

%show the feedback screen
	
