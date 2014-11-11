function paramReplace = pickReplacement(a,param)
% Assemblage.pickReplacement
% 
% Description:	pick a replacemet for a specified part
% 
% Syntax:	paramReplace = a.pickReplacement(param)
% 
% In:
% 	param	- the part's set parameters
% 
% Out:
% 	paramReplace	- the set parameters for the replacement part 
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
paramReplace	= param;
paramReplace(1)	= randFrom(a.findReplacements(param));
