function pos = getOccupiedPositions(a,varargin)
% Assemblage.getOccupiedPositions
% 
% Description:	get the occupied grid positions in the assemblage
% 
% Syntax:	pos = a.getOccupiedPositions([excludePart]=NaN)
% 
% In:
% 	[excludePart]	- a part to exclude
% 
% Out:
% 	pos	- a cell array of grid positions
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
excludePart	= ParseArgs(varargin,NaN);

if ~isequalwithequalnans(excludePart,NaN)
	excludePart	= a.part(excludePart);
end

parts	= a.part;
nPart	= numel(parts);
pos		= {};
for kP=1:nPart
	part	= parts{kP};
	if ~isequal(part,excludePart)
		pos{end+1}	= part.param.grid;
	end
end
