function Organize(varargin)
% GO.Preprocess.Organize
% 
% Description:	organize the raw data
% 
% Syntax:	GO.Preprocess.Organize(<options>)
% 
% In:
% 	<options>:
%		nthread:	(12)
%		force:		(false)
% 
% Updated: 2014-03-06
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData

opt	= ParseArgs(varargin,...
		'nthread'	, 12	, ...
		'force'		, false	  ...
		);

strDirRaw	= DirAppend(strDirData,'raw');

%organize the data
	[b,cPathRaw,cPathOut]	= PARRECOrganize(strDirRaw,...
								'nthread'	, opt.nthread	, ...
								'force'		, opt.force		  ...
								);
