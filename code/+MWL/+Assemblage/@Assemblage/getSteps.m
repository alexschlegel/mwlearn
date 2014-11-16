function steps = getSteps(a)
% Assemblage.getSteps
% 
% Description:	get the steps needed to recreate an assemblage
% 
% Syntax:	steps = a.getSteps()
% 
% Updated: 2014-11-15
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nStep	= a.numSteps;

steps	= cell(nStep,1);
for kS=1:nStep
	switch a.history{kS}{1}
		case 'add'
			idxPart		= a.history{kS}{2};
			part		= a.part(idxPart);
			partName	= part.part;
			
			if ~isequalwithequalnans(part.param.parent,NaN)
				neighbor		= a.part(part.param.parent);
				idxNeighbor		= neighbor.param.idx;
				sidePart		= find(part.param.attachment==idxNeighbor)-1;
				sideNeighbor	= find(neighbor.param.attachment==idxPart)-1;
			else
				idxNeighbor		= NaN;
				sidePart		= 0;
				sideNeighbor	= 0;
			end
			
			steps{kS}	= {'add' partName idxNeighbor sidePart sideNeighbor};
		case 'rotate'
			ang			= a.history{kS}{2};
			steps{kS}	= {'rotate' ang/90};
		otherwise
			error('%s steps are not supported',a.history{kS}{1});
	end
end
