function distractor = createDistractor(a,varargin)
% Assemblage.createDistractor
% 
% Description:	create a distractor assemblage based of the current one
% 
% Syntax:	distractor = a.createDistractor([opt]=struct)
% 
% In:
% 	opt	- options for the distractor assemblage
% 
% Out:
% 	distractor	- the distractor assemblage
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,struct);

opt.exclude	= unless(GetFieldPath(opt,'exclude'),{});
nExclude	= numel(opt.exclude);

%construct the distractor set
	setParamOrig	= a.getSet;
	nTries			= 0; %i think this will always work, but just to make sure...
	
	while true
		setParam		= setParamOrig;
		idx				= randi(numel(setParam));
		setParam{idx}	= a.pickReplacement(setParam{idx});
		
		if nExclude>0 && nTries<20
			setIsGood	= true;
			
			for kE=1:nExclude
				setExclude	= opt.exclude{kE};
				if isequal(setParam,setExclude)
					setIsGood	= false;
					nTries		= nTries+1;
					break;
				end
			end
			if setIsGood
				break;
			end
		else
			break;
		end
	end
	
%create the distractor
	optA	= rmfield(opt,'exclude');
	
	distractor	= MWL.Assemblage.Assemblage(a.ptb,optA);
	distractor.addSet(setParam);
	distractor.rotate(a.rotation/90);
