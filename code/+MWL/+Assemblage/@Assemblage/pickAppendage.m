function appendage = pickAppendage(a,varargin)
% Assemblage.pickAppendage
% 
% Description:	randomly choose a new appendage to add to the assemblage
% 
% Syntax:	appendage = a.pickAppendage([excludePart]=NaN)
% 
% In:
% 	excludePart	- a part to exclude as a possible attachment point
% 
% Out:
% 	appendage	- the parameters for a new AssemblagePart
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
excludePart	= ParseArgs(varargin,NaN);

conns	= a.findOpenConnections(excludePart);
conn	= cell2mat(randFrom(conns));

if ~isequalwithequalnans(unless(conn,NaN),NaN)
	%make it's a square if we only have one possible connection
	if numel(conns)==1 && ~isequalwithequalnans(conn(1),NaN)
		part	= 'square';
	else
		part	= a.pickPart;
	end
	
	side	= a.pickSide(part);
	
	appendage	= {part, conn(1), side, conn(2)};
else
	appendage	= NaN;
end
