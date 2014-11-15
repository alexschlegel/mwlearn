function r = Reward(x)
% GO.Reward
% 
% Description:	calculate the reward to give to a subject based on his/her
%				performance
% 
% Syntax:	r = Reward(x)
% 
% In:
%	x	- one of the following:
%			the subject code (e.g. '11oct81as')
%			the path to an experiment record .mat file
%			the subject's experiment record
% 
% Out:
% 	r	- the reward, in dollars
% 
% Updated: 2014-11-14
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData

%get the experiment record
	if ischar(x)
		if ~FileExists(x)
			x	= PathUnsplit(strDirData,PTBIFO,'mat');
		end 
		x	= load(x);
		x	= x.PTBIFO;
	end

%construct a record of which trials were correct/incorrect
	result		= cat(2,x.go.result{:});
	bCorrect	= [result.correct];

%calculate the reward
	nTrial	= numel(bCorrect);
	
	nTrialTarget	= GO.Param('exp','runs')*GO.Param('exp','reps')*16;
	rMin			= GO.Param('reward','base');
	rMax			= GO.Param('reward','max');
	fPenalty		= GO.Param('reward','penalty');
	
	rPer	= (rMax-rMin)/nTrialTarget;
	pPer	= rPer*fPenalty;
	
	r	= rMin;
	for kT=1:nTrial;
		if bCorrect(kT)
			r	= r + rPer;
		else
			r	= max(rMin,r - pPer);
		end
	end
