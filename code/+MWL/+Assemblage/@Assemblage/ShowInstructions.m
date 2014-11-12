function ShowInstructions(a,varargin)
% Assemblage.ShowInstructions
% 
% Description:	show the instructions for assembling the assemblage
% 
% Syntax:	a.ShowInstructions(<options>)
% 
% In:
% 	<options>:
%		window:	('main') the window on which to show the instructions
% 
% Updated: 2014-11-11
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'window'	, 'main'	  ...
		);

strInstruction	= ['<family:Arial><size:1>' join(a.instruction,'\n') '</size></family>'];

a.ptb.Show.Text(strInstruction,...
	'window'	, opt.window	  ...
	);
