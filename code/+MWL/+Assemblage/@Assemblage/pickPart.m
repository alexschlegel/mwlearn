function part = pickPart(a)
% Assemblage.pickPart
% 
% Description:	pick a random part
% 
% Syntax:	part = a.pickPart()
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
part	= char(randFrom(a.possibleParts));
