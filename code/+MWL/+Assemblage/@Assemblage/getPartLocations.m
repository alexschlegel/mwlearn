function loc = getPartLocations(a)
% Assemblage.getPartLocations
% 
% Description:	construct a cell specifying the location of each part in the
%				assemblage
% 
% Syntax:	loc = a.getPartLocations()
% 
% Updated: 2014-11-15
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
parts	= a.part;
nPart	= numel(parts);

nGridX	= a.grid.max(1) - a.grid.min(1) + 1;
nGridY	= a.grid.max(2) - a.grid.min(2) + 1;

loc	= repmat({'empty'},[nGridY, nGridX]);

for kP=1:nPart
	part	= parts{kP};
	xPart	= part.param.grid(1) - a.grid.min(1) + 1;
	yPart	= part.param.grid(2) - a.grid.min(2) + 1;
	
	loc{yPart,xPart}	= part.part;
end
