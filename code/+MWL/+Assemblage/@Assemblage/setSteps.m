function setSteps(a,steps)
% Assemblage.setSteps
% 
% Description:	set the steps of an assemblage to match a steps description
%				constructed using getSteps
% 
% Syntax:	a.setSteps(steps)
% 
% Updated: 2014-11-15
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

a.reset;

nStep	= numel(steps);
for kS=1:nStep
	switch steps{kS}{1}
		case 'add'
			a.addPart(steps{kS}{2:end});
		case 'rotate'
			a.rotate(steps{kS}{2:end});
		otherwise
			error('%s is an invalid step type.',steps{kS}{1});
	end
end
