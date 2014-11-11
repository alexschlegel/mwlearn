function a = Create(ptb,varargin)
% MWL.Assemblage.Create
% 
% Description:	create an assemblage
% 
% Syntax:	a = MWL.Assemblage.Create(ptb,<options>)
% 
% In:
% 	ptb	- the PTB object that will show the assemblage
%	<options>:
%		steps:	(3) the number of steps in the assemblage sequence
% 
% Out:
% 	a		- the assemblage
% 
% Updated: 2014-11-11
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'steps'	, 3	  ...
		);

a	= MWL.Assemblage.Assemblage(ptb);

%add the first part
	a.addRandom;

%add the remaining parts, interleaving with image rotations
	iStep	= 1;
	while iStep < opt.steps
		a.addRandom;
		iStep	= iStep+1;
		
		if iStep < opt.steps
			a.rotate(randi(3));
			iStep	= iStep+1;
		end
	end