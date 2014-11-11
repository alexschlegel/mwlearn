function n = numSteps(a)
% Assemblage.numSteps
% 
% Description:	get the number of steps in the Assemblage instructions
% 
% Syntax:	n = a.numSteps()
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
n	= numel(a.history);
