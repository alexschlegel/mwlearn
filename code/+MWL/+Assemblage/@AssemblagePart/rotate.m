function rotate(part,a)
% AssemblagePart.rotate
% 
% Description:	rotate the assemblage part
% 
% Syntax:	part.rotate(a)
% 
% In:
% 	a	- the angle through which to rotate the part, in degrees
% 
% Updated: 2014-11-11
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if mod(a,90)~=0
	error('Invalid rotation.');
end

steps	= a/90;

part.param.orientation	= mod(part.param.orientation + steps,4);
