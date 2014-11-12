function replacementParts = findReplacements(a,param)
% Assemblage.findReplacements
% 
% Description:	find possible replacements for a part
% 
% Syntax:	replacementParts = a.findReplacements(param)
% 
% In:
% 	param	- the part's set parameters
% 
% Out:
% 	replacementParts	- a cell of possible replacement part names
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%first try with existing parts unless we're a small assemblage
	if a.numParts > 2
		replacementParts = a.findReplacementsGivenParts(param,a.existingParts);
	else
		replacementParts = {};
	end

%expand to all parts
	if numel(replacementParts)==0
		replacementParts	= a.findReplacementsGivenParts(param,a.possibleParts)
	end
