function p = part(a,varargin)
% Assemblage.part
% 
% Description:	get an AssemblagePart
% 
% Syntax:	part = a.part([part]=<all>)
% 
% In:
% 	part	- an AssemblagePart or part index
% 
% Out:
% 	p	- the AssemblagePart
% 
% Updated: 2015-06-12
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
part	= ParseArgs(varargin,NaN);

if isa(part,'MWL.Assemblage.AssemblagePart')
	p	= part;
elseif ~isequalwithequalnans(part,NaN)
	p	= a.element{a.partElementIndex(part)};
elseif a.numParts>0
	p	= a.element;
else
	p	= [];
end
