function part = addPart(a,partName,varargin)
% Assemblage.addPart
% 
% Description:	add a part to the assemblage
% 
% Syntax:	part = a.addPart(partName,[neighbor]=<none>,[sidePart]=0,[sideNeighbor]=0,[opt]=struct)
% 
% In:
% 	partName		- the name of the part
%	[neighbor]		- the neighbor on to which to part will attach
%	[sidePart]		- the side on which the part will attach
%	[sideNeightbor]	- the side of the neighbor on which the part will attach
%	[opt]:
%		orientation:	(0) the initial assemblage orientation (if this is the
%						first part
%		(other options for AssemblagePart)
% 
% Out:
% 	part	- the new AssemblagePart
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[neighbor,sidePart,sideNeighbor,opt]	= ParseArgs(varargin,NaN,0,0,struct);

opt	= StructMerge(a.opt,opt);

part			= MWL.Assemblage.AssemblagePart(a.ptb,partName,opt);
part.assemblage	= a;

a.element{end+1}	= part;

part.param.idx	= a.numParts;

if ~any(strcmp(a.existingParts,partName))
	a.existingParts{end+1}	= partName;
end

if ~isequalwithequalnans(neighbor,NaN)
	neighbor	= a.part(neighbor);
	
	part.param.parent							= neighbor.param.idx;
	neighbor.param.attachment(sideNeighbor+1)	= part.param.idx;
	part.param.attachment(sidePart+1)			= neighbor.param.idx;
	
	%orientation of the part to match with the neighbor
	orientation = mod( mod(sideNeighbor+2,4) - sidePart + neighbor.param.orientation,4);
	
	%direction to move from the neighbor
	gridRel = neighbor.side2direction(sideNeighbor);
	
	part.param.grid = neighbor.param.grid + gridRel;
	
	a.grid.min	= min(a.grid.min, part.param.grid);
	a.grid.max	= max(a.grid.max, part.param.grid);
else
	orientation	= unless(GetFieldPath(opt,'orientation'),0);
end

part.param.orientation	= orientation;

a.addEvent('add',part.param.idx);
