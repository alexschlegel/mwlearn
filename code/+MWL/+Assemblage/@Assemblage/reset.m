function reset(a)
% Assemblage.reset
% 
% Description:	reset an assemblage
% 
% Syntax:	a.reset()
% 
% Updated: 2014-11-15
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
a.rotation		= 0;
a.element		= {};
a.existingParts	= {};
a.history		= {};
a.instruction	= {};
a.grid			= struct(...
					'min'	, [0 0]	, ...
					'max'	, [0 0]	  ...
					);
