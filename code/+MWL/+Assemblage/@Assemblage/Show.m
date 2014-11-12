function Show(a,s,pos,varargin)
% Assemblage.Show
% 
% Description:	show the assemblage
% 
% Syntax:	a.Show(s,pos,<options>)
% 
% In:
% 	s	- the [H,W] size of the bounding box for the assemblage, in d.v.a
%	pos	- the [x,y] position of the assemblage
%	<options>:
%		window:	('main') the window on which to show the assemblage
% 
% Updated: 2014-11-12
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'window'	, 'main'	  ...
		);

%construct the assemblage image
	sPx	= a.ptb.Window.va2px(s);
	im	= a.Image(sPx);

%show it
	a.ptb.Show.Image(im,pos,...
		'window'	, opt.window	  ...
		);
