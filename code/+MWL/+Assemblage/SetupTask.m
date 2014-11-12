function [hPrompt, tPrompt, hTest, hFeedback, posCorrect, assemblage] = SetupTask(mwlt, dLevel)
%  Set up the textures for one assemblage task.
%
%  Syntax: [hPrompt, tPrompt, hTest, hFeedback, posCorrect, assemblage] = MWL.Assemblage.SetupTask(mwlt,dLevel)
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
% assemblage - a cell of assemblages, in order of position (clockwise from top)

aTarget		= MWL.Assemblage.Create(mwlt.Experiment,'steps',dLevel);
aDistractor	= aTarget.createDistractors(3);

[assemblages,kRand]	= randomize([{aTarget}; aDistractor]);
kUnRand				= zeros(size(kRand));
kUnRand(kRand)		= 1:numel(kRand);
posCorrect			= kUnRand(1);

sAssemblage	= MWL.Param('assemblage','size','assemblage');
sOffset		= MWL.Param('assemblage','size','offset');

%show the prompt
	t	= MWL.Param('assemblage','time');
	
	hPrompt	= mwlt.Experiment.Window.OpenTexture('prompt');
	aTarget.ShowInstructions('window','prompt');
	
	nWord	= numel(split(join(aTarget.instruction,' '),' '));
	nStep	= a.numSteps;
	tPrompt	= nWord*t.perWord + nStep*t.perLine;

%show the test screen
	hTest	= mwlt.Experiment.Window.OpenTexture('test');
	
	posAssemblage	=	[
							0	-1
							1	0
							0	1
							-1	0
						];
	
	nAssemblage	= numel(assemblage);
	for kA=1:nAssemblage
		pos	= posAssemblage(kA,:).*sOffset;
		
		assemblage{kA}.Show(sAssemblage,pos,..
			'window'	, 'test'	  ...
			);
	end

%show the feedback screen
	hFeedback	= mwlt.Experiment.Window.OpenTexture('feedback');
	
	pos	= posAssemblage(posCorrect,:).*offsetAssemblage;
	assemblage{posCorrect}.Show(sAssemblage,pos,...
			'window'	, 'feedback'	 ...
			);
