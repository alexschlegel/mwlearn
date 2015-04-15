function DTI(varargin)
% MWL.Preprocess.DTI
% 
% Description:	preprocess the mwlearn dti data
% 
% Syntax:	MWL.Preprocess.DTI(<options>)
% 
% In:
% 	<options>:
%		stage:		(<all>)
%		nthread:	(12)
%		force:		(false)
% 
% Updated: 2015-04-15
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData

opt	= ParseArgs(varargin,...
		'stage'		, []	, ...
		'nthread'	, 12	, ...
		'force'		, false	  ...
		);

ifo	= MWL.GetSubjectInfo;

%get the directories to process
	cPathDTI	= ifo.path.diffusion.raw;
	bProcess	= FileExists(cPathDTI);
	
	cDirDTI	= cellfun(@PathGetDir,cPathDTI(bProcess),'uni',false);
	

%process the DTI data
	b	= DTIProcess(cDirDTI,...
			'stage'		, opt.stage		, ...
			'force'		, opt.force		, ...
			'nthread'	, opt.nthread	  ...
			);
