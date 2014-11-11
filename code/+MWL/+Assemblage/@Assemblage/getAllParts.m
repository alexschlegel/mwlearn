function partNames = getAllParts(a,varargin)
% Assemblage.getAllParts
% 
% Description:	get an array of the names of all the parts
% 
% Syntax:	partNames = a.getAllParts([excludePart]=NaN)
% 
% In:
% 	[excludePart]	- a part to exclude
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
excludePart	 = ParseArgs(varargin,NaN);

if ~isequalwithequalnans(excludePart,NaN)
	excludePart	= a.part(excludePart);
end

parts		= a.part;
nPart		= numel(parts);
partNames	= {};
for kP=1:nPart
	part	= parts{kP};
	if ~isequal(part,excludePart)
		partNames{end+1}	= part.part;
	end
end
