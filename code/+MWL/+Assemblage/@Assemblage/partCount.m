function n = partCount(a,part,varargin)
% Assemblage.partCount
% 
% Description:	calculate the number of a particular type of part in the
%				assemblage
% 
% Syntax:	n = a.partCount(part,[excludePart]=NaN)
% 
% In:
% 	part			- the name of the part
%	[excludePart]	- a part to exclude
% 
% Out:
% 	n	- the number of parts of the specified type in the assemblage
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
excludePart	= ParseArgs(varargin,NaN);

n	= numel(a.findPart(part,excludePart));
