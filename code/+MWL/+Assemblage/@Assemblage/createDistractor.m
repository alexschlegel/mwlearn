function distractor = createDistractor(a,varargin)
% Assemblage.createDistractor
% 
% Description:	create a distractor assemblage based of the current one
% 
% Syntax:	distractor = a.createDistractor([dType]='switch',[opt]=struct)
% 
% In:
%	dType	- the distractor type ('switch', 'flip', 'rotate', or 'replace') 
% 	opt		- options for the distractor assemblage
% 
% Out:
% 	distractor	- the distractor assemblage
% 
% Updated: 2014-11-15
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[dType,opt]	= ParseArgs(varargin,'switch',struct);

switch dType
	case 'switch'
		distractor	= a.createDistractorSwitch(opt);
	case 'flip'
		distractor	= a.createDistractorFlip(opt);
	case 'rotate'
		distractor	= a.createDistractorRotate(opt);
	case 'replace'
		distractor	= a.createDistractorReplace(opt);
	otherwise
		error('Invalid distractor type.');
end
