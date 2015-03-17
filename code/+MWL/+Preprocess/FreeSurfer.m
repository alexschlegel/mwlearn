function b = FreeSurfer(varargin)
% MWL.Preprocess.FreeSurfer
% 
% Description:	run the structural data through FreeSurfer
% 
% Syntax:	b = MWL.Preprocess.FreeSurfer(<options>)
% 
% In:
%	<options>:
%		ifo:		(<load>) the subject info struct
%		nthread:	(12) the number of threads to use
%		force:		(false) true to reprocess everything
% 
% Updated: 2015-03-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData;

opt	= ParseArgs(varargin,...
		'ifo'		, []	, ...
		'nthread'	, 12	, ...
		'force'		, false	  ...
		);

if isempty(opt.ifo)
	ifo	= MWL.GetSubjectInfo;
else
	ifo	= opt.ifo;
end

cPathStructural	= ifo.path.structural.raw;
bProcess		= FileExists(cPathStructural);

b	= FreeSurferProcess(cPathStructural(bProcess),...
		'check_results'	, false			, ...
		'nthread'		, opt.nthread	, ...
		'force'			, opt.force		  ...
		);
