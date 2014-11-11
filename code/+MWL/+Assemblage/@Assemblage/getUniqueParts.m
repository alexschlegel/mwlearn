function parts = getUniqueParts(a)
% Assemblage.getUniqueParts
% 
% Description:	get the unique parts in the assemblage
% 
% Syntax:	parts = a.getUniqueParts()
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
parts	= cellfun(@(part) part.part,a.part,'uni',false);
parts	= unique(parts);
