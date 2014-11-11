function strOrientation = naturalOrientation(part)
% AssemblagePart.naturalOrientation
% 
% Description:	construct a string representing the part's orientation
% 
% Syntax:	strOrientation = part.naturalOrientation()
% 
% Updated: 2014-11-11
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strOrientation	= naturaldirection(90*part.param.orientation, part.param.symmetry);
