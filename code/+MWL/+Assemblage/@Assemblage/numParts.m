function n = numParts(a)
% Assemblage.numParts
% 
% Description:	get the number of parts in the assemblage
% 
% Syntax:	n = a.numParts()
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
n	= numel(a.element);
