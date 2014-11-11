function strDefinition = naturalDefinition(part)
% AssemblagePart.naturalDefinition
% 
% Description:	construct a string representation a natural definition of the
%				part
% 
% Syntax:	strDefinition = part.naturalDefinition()
% 
% Updated: 2014-11-11
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if ~isequalwithequalnans(part.param.parent,NaN)
	parent	= part.assemblage.part(part.param.parent);
else
	parent	= NaN;
end

partName		= part.naturalName(true);

if ~isequalwithequalnans(parent,NaN)
	partLocation	= [' ' part.naturalRelativeLocation(parent,true,part)];
else
	partLocation	= '';
end

strDefinition	= [partName partLocation];
