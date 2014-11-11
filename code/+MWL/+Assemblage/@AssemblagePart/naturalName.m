function strName = naturalName(part,varargin)
% AssemblagePart.naturalName
% 
% Description:	get a string representing a natural name for the part
% 
% Syntax:	strName = part.naturalName([fullName]=false)
% 
% Updated: 2014-11-11
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
fullName	= ParseArgs(varargin,false);

if fullName
	orientation	= part.naturalOrientation();
else
	orientation	= '';
end

if numel(orientation)>0
	orientation	= [orientation ' '];
end

strName	= [orientation part.part];
