function strName = naturalName(a)
% Assemblage.naturalName
% 
% Description:	construct a natural language name for the assemblage
% 
% Syntax:	strName = a.naturalName()
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if a.numParts==1
	strName	= a.part(1).naturalName;
else
	strName	= 'image';
end
