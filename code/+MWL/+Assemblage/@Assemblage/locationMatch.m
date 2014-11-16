function b = locationMatch(a,cPartLocation)
% Assemblage.locationMatch
% 
% Description:	check to see if an assemblage's part locations match one of a
%				set of test location sets
% 
% Syntax:	b = a.locationMatch(cPartLocation)
% 
% In:
% 	cPartLocation	- a cell of part location cells returned by
%					  Assemblage.getPartLocations
% 
% Out:
% 	b	- true if there is a match
% 
% Updated: 2014-11-15
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
b	= false;

loc	= a.getPartLocations;

nMatch	= numel(cPartLocation);
for kM=1:nMatch
	if isequal(cPartLocation{kM},loc)
		b	= true;
		return;
	end
end
