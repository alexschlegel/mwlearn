function distractors = createDistractors(a,n,varargin)
% Assemblage.createDistractors
% 
% Description:	create multiple distractors based on the current assemblage
% 
% Syntax:	distractors = a.createDistractors(n,[opt]=struct)
% 
% In:
% 	n		- the number of distractors to create
%	[opt]	- options for the distractor Assemblage calls
% 
% Out:
% 	distractors	- a cell of the distractors
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,struct);

[distractors,distractorsSet]	= deal(cell(n,1));

for kD=1:n
	opt.exclude	= distractorsSet;
	d			= a.createDistractor(opt);
	
	distractors{kD}		= d;
	distractorsSet{kD}	= d.getSet;
end
