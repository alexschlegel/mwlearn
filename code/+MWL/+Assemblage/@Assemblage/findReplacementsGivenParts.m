function replacementParts = findReplacementsGivenParts(a,param,parts)
% Assemblage.findReplacementsGivenParts
% 
% Description:	find possible replacements for a part, given the possible set of
%				replacements
% 
% Syntax:	replacementParts = a.findReplacementsGivenParts(param,parts)
% 
% In:
% 	param	- the part set parameters
%	parts	- the possible replacement part names
% 
% Out:
% 	replacementParts	- the names of the possible replacement partss
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
part		= param{1};

conn		= MWL.Assemblage.Param(part).connects;
nConn		= numel(conn);

replacementParts	= {};

nPart	= numel(parts);
for kP=1:nPart
	replacement	= parts{kP};
	
	if ~strcmp(part,replacement)
		replacementParam	= MWL.Assemblage.Param(replacement);
		if all(ismember(conn,replacementParam.connects))
			replacementParts{end+1}	= replacement;
		end
	end
end
