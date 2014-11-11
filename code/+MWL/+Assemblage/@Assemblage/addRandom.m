function part = addRandom(a)
% Assemblage.addRandom
% 
% Description:	add a random part to the assemblage
% 
% Syntax:	parts = a.addRandom()
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
appendage	= a.pickAppendage;
opt			= conditional(a.numParts==0,struct,struct('orientation', randi(4)-1));

if ~isequalwithequalnans(appendage,NaN)
	parts	= a.addPart(appendage{:},opt);
else
	parts	= NaN;
end
