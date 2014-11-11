function idx = findPart(a,part,varargin)
% Assemblage.findPart
% 
% Description:	find which parts have the specified part name
% 
% Syntax:	idx = a.findPart(part,[excludePart]=NaN)
% 
% In:
% 	part			- then name of the parts to find
%	[excludePart]	- a part to exclude
% 
% Out:
% 	idx	- the indices of the matching parts in the assemblage
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
excludePart	= ParseArgs(varargin,NaN);

idx	= find(strcmp(a.getAllParts(excludePart),part));
