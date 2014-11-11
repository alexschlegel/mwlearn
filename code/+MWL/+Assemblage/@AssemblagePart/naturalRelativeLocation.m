function strLocation = naturalRelativeLocation(part,neighbor,varargin)
% AssemblagePart.naturalRelativeLocation
% 
% Description:	get a string representing the location of the part relative to
%				a neighbor
% 
% Syntax:	strLocation = part.naturalRelativeLocation(neighbor,[includeNeighbor]=false,[excludePart]=NaN)
% 
% In:
% 	neighbor			- the neighbor part
%	[includeNeighbor]	- include the neighbor in the description
%	[excludePart]		- a part to exclude from the process
% 
% Updated: 2014-11-11
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[includeNeighbor,excludePart]	= ParseArgs(varargin,false,NaN);

neighbor	= part.assemblage.part(neighbor);
p1			= part.param.grid;
p2			= neighbor.param.grid;

if p1(1) < p2(1)
	loc	= 'to the left of';
elseif p1(1) > p2(1)
	loc	= 'to the right of';
elseif p1(2) < p2(2)
	loc	= 'above';
elseif p1(2) > p2(2)
	loc	= 'below';
else %this shouldn't happen
	loc	= 'on top of';
end

if includeNeighbor
	neighborLoc	= neighbor.naturalLocation(excludePart, part.param.idx);
	
	if ~isequalwithequalnans(neighborLoc,NaN)
		strLocation	= sprintf('%s the %s',loc,neighborLoc);
	else
		strLocation	= NaN;
	end
else
	strLocation	= loc;
end
