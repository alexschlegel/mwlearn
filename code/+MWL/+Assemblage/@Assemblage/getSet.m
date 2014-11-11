function setParam = getSet(a)
% Assemblage.getSet
% 
% Description:	construct a description of the parts in the Assemblage
% 
% Syntax:	setParam = a.getSet()
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
parts	= a.part;
nPart	= numel(parts);

setParam	= cell(nPart,1);

for kP=1:nPart
	part		= parts{kP};
	partName	= part.part;
	parent		= part.param.parent;
	
	if ~isequalwithequalnans(parent,NaN)
		partParent	= a.part(parent);
		sidePart	= find(part.param.attachment==parent,1)-1;
		sideParent	= find(partParent.param.attachment==part.param.idx,1)-1;
	else
		[sidePart,sideParent]	= deal([]);
	end
	
	setParam{kP}	= {partName, parent, sidePart, sideParent};
end
