function distractor = createDistractorReplace(a,varargin)
% Assemblage.createDistractorReplace
% 
% Description:	create a distractor by replacing a random part
% 
% Syntax:	distractor = a.createDistractorReplace([opt]=struct)
% 
% In:
% 	opt	- options for the distractor assemblage, plus:
%		exclude: a cell of part locations from assemblages to exclude
% 
% Out:
% 	distractor	- the distractor assemblage
% 
% Updated: 2014-11-15
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,struct);

opt.exclude	= ForceCell(unless(GetFieldPath(opt,'exclude'),{}));

%create the distractor
	optA	= rmfield(opt,'exclude');
	distractor	= MWL.Assemblage.Assemblage(a.ptb,optA);

%construct the distractor set
	stepsOrig	= a.getSteps;

	bStepAdd	= cellfun(@(step) isequal(step{1},'add'),stepsOrig);
	kStepAdd	= find(bStepAdd);
	
	nTries	= 0;
	while nTries<20
		steps		= stepsOrig;
		
		kStepReplace				= randFrom(kStepAdd);
		steps{kStepReplace}(2:end)	= a.pickReplacement(steps{kStepReplace}(2:end));
		
		distractor.setSteps(steps);
		
		if ~distractor.locationMatch(opt.exclude)
			return;
		end
		
		nTries	+ nTries+1;
	end
