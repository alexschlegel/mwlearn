function addSet(a,setParam)
% Assemblage.addSet
% 
% Description:	add all the parts in a set (see Assemblage.getSet)
% 
% Syntax:	a.addSet(setParam)
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nParam	= numel(setParam);
for kP=1:nParam
	a.addPart(setParam{kP}{:});
end
