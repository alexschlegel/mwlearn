function distractor = createDistractorFlip(a,varargin)
% Assemblage.createDistractorFlip
% 
% Description:	create a distractor by flipping the assemblage
% 
% Syntax:	distractor = a.createDistractorFlip([opt]=struct)
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

nPart	= a.numParts;
steps	= a.getSteps;
loc		= a.getPartLocations;

%create the distractor
	optA	= rmfield(opt,'exclude');
	distractor	= MWL.Assemblage.Assemblage(a.ptb,optA);


%first try a horizontal flip
	distractor.setSteps(steps);
	
	for kP=1:nPart
		part				= distractor.part(kP);
		part.param.grid(1)	= -part.param.grid(1);
		
		part.param.orientation	= switch2(part.param.orientation,1,3,3,1,part.param.orientation);
	end
	
	tmp	= distractor.grid.min(1);
	distractor.grid.min(1)	= -distractor.grid.max(1);
	distractor.grid.max(1)	= -tmp;
	
	if ~distractor.locationMatch(opt.exclude) && ~distractor.locationMatch({loc})
		return;
	end

%now try a vertical flip
	distractor.setSteps(steps);
	
	for kP=1:nPart
		part				= distractor.part(kP);
		part.param.grid(2)	= -part.param.grid(2);
		
		part.param.orientation	= switch2(part.param.orientation,0,2,2,0,part.param.orientation);
	end
	
	tmp	= distractor.grid.min(2);
	distractor.grid.min(2)	= -distractor.grid.max(2);
	distractor.grid.max(2)	= -tmp;
	
	if ~distractor.locationMatch(opt.exclude) && ~distractor.locationMatch({loc})
		return;
	end

%fallback to a switch distractor
	distractor	= a.createDistractorSwitch(opt);
