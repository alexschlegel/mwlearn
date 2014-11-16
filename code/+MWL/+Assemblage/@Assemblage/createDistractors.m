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
% Updated: 2014-11-15
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,struct);

dType	=	{
				'switch'
				'flip'
				'rotate'
			};
nType		= numel(dType);

distractors	= cell(n,1);
opt.exclude	= {};

kType	= 0;
for kD=1:n
	kType	= mod(kType,nType)+1;
	
	distractors{kD}		= a.createDistractor(dType{kType},opt);
	opt.exclude{end+1}	= distractors{kD}.getPartLocations;
end
