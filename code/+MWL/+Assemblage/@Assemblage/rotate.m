function rotate(a,steps)
% Assemblage.rotate
% 
% Description:	rotate the assemblage by some numbers of steps (1 step==90 deg)
% 
% Syntax:	a.rotate(steps)
% 
% In:
% 	steps	- number of steps to rotate
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
ang = 90*steps;

a.rotation	= mod(a.rotation + ang,360);

%rotate the parts
	nElement	= numel(a.element);
	for kE=1:nElement
		a.element{kE}.rotate(ang);
	end

%rotate the grid positions
	parts	= a.part;
	nPart	= numel(parts);
	for kP=1:nPart
		el	= parts{kP};
		el.param.grid	= round(RotatePoints(el.param.grid,d2r(ang)));
	end

%add the event
	a.addEvent('rotate',ang);
