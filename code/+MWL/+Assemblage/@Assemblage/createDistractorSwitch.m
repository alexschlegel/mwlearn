function distractor = createDistractorSwitch(a,varargin)
% Assemblage.createDistractorSwitch
% 
% Description:	create a distractor by switching two parts
% 
% Syntax:	distractor = a.createDistractorSwitch([opt]=struct)
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

%create the distractor
	optA	= rmfield(opt,'exclude');
	distractor	= MWL.Assemblage.Assemblage(a.ptb,optA);

%construct the distractor set
	stepsOrig	= a.getSteps;

	%find parts that can be switched
		%get the connection profile of each existing part
			conn	= cellfun(@(partName) MWL.Assemblage.Param(partName).connects, a.existingParts,'uni',false);
		%find matching connection profiles
			[connU,kConnU,kConn]	= UniqueCell(conn);
			matchingParts			= arrayfun(@(k) a.existingParts(kConn==k),kConnU,'uni',false);
			nMatch					= cellfun(@numel,matchingParts);
			matchingParts			= matchingParts(nMatch>1);
			
			if isempty(matchingParts)
				distractor	= a.createDistractorReplace(opt);
				return;
			end
		%get all potential transformations
			txAll	= cellfun(@handshakes,matchingParts,'uni',false);
			txAll	= cat(1,txAll{:});
			txAll	= [txAll; txAll(:,[2 1])];
			nTX		= size(txAll,1);
		%randomize them
			txAll	= randomize(txAll,1,'rows');
	
	nTries	= min(20,nTX);
	for kTX=1:nTries
		steps		= stepsOrig;
		
		%get the transformation
			txFrom	= txAll{kTX,1};
			txTo	= txAll{kTX,2};
		%choose random from and to parts
			kFromAll	= find(cellfun(@(step) strcmp(step{2},txFrom),steps));
			kToAll		= find(cellfun(@(step) strcmp(step{2},txTo),steps));
			
			kFrom	= randFrom(kFromAll);
			kTo		= randFrom(kToAll);
		
		steps{kFrom}{2}	= txTo;
		steps{kTo}{2}	= txFrom;
		
		distractor.setSteps(steps);
		
		if ~distractor.locationMatch(opt.exclude)
			return;
		end
	end

%fallback to a replace distractor
	distractor	= a.createDistractorReplace(opt);

