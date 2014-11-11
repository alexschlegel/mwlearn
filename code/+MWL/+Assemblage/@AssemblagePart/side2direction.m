function direction = side2direction(part,side)
% AssemblagePart.side2direction
% 
% Description:	get a relative direction vector to a part side
% 
% Syntax:	direction = part.side2direction(side)
% 
% In:
% 	side	- the part side (0->3)
% 
% Out:
% 	direction	- the relative direction vector to that side
% 
% Updated: 2014-11-11
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
sideAbs	= mod(side+part.param.orientation,4);

direction	= switch2(sideAbs,...
				0	, [-1,0]	, ...
				1	, [0,-1]	, ...
				2	, [1,0]		, ...
				3	, [0,1]		, ...
				[0,0]);
