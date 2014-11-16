function distractor = createDistractorRotate(a,varargin)
% Assemblage.createDistractorRotate
% 
% Description:	create a distractor by rotating 180 degrees
% 
% Syntax:	distractor = a.createDistractorRotate([opt]=struct)
% 
% In:
% 	opt	- options for the distractor assemblage, plus:
%		exclude: a cell of assemblages to exclude as possible replacements
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

steps	= a.getSteps;
loc		= a.getPartLocations;

%create the distractor
	optA	= rmfield(opt,'exclude');
	distractor	= MWL.Assemblage.Assemblage(a.ptb,optA);
	distractor.setSteps(steps);
	
	distractor.rotate(2);
	
	if ~distractor.locationMatch(opt.exclude) && ~distractor.locationMatch({loc})
		return;
	end

%fallback to a switch distractor
	distractor	= a.createDistractorSwitch(opt);
