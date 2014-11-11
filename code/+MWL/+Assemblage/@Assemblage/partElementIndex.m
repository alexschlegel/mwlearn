function idx = partElementIndex(a,part)
% Assemblage.partElementIndex
% 
% Description:	get the index of a part
% 
% Syntax:	idx = a.partElementIndex(part)
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if isa(part,'MWL.Assemblage.AssemblagePart')
	idx	= a.partElementIndex(part.param.idx);
else
	idx	= part;
end
