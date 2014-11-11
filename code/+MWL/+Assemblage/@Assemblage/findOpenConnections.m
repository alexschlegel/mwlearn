function conn = findOpenConnections(a,varargin)
% Assemblage.findOpenConnections
% 
% Description:	find unoccupied sides in the assemblage
% 
% Syntax:	conn = a.findOpenConnections([excludePart]=NaN)
% 
% In:
% 	[excludePart]	- a part to exclude
% 
% Out:
% 	conn	- a cell of [part_index, side] open connections
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
excludePart	= ParseArgs(varargin,NaN);

if a.numParts==0
	conn	= {[NaN,0]};
else
	if ~isequalwithequalnans(excludePart,NaN)
		excludePart	= a.part(excludePart);
	end
	
	occupied	= a.getOccupiedPositions;
	nOccupied	= numel(occupied);
	
	conn	= {};
	
	parts	= a.part;
	nPart	= numel(parts);
	for kP=1:nPart
		part	= parts{kP};
		if isequal(part,excludePart)
			continue;
		end
		
		param	= MWL.Assemblage.Param(part.part);
		sides	= param.connects;
		nSide	= numel(sides);
		for kS=1:nSide
			side	= sides(kS);
			if isequalwithequalnans(part.param.attachment(side+1),NaN)
				grid	= part.param.grid + part.side2direction(side);
				
				bFound	= false;
				for kO=1:nOccupied
					if all(occupied{kO}==grid)
						bFound	= true;
						break;
					end
				end
				if ~bFound
					conn{end+1}	= [kP, side];
				end
			end
		end
	end
end
