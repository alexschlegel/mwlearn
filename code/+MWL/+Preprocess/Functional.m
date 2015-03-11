function Functional(varargin)
% MWL.Preprocess.Functional
% 
% Description:	preprocess the gridop functional data
% 
% Syntax:	MWL.Preprocess.Functional(<options>)
% 
% In:
% 	<options>:
%		nthread:	(12)
%		force:		(false)
% 
% Updated: 2015-02-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData

opt	= ParseArgs(varargin,...
		'nthread'	, 12	, ...
		'force'		, false	  ...
		);

ifo	= MWL.GetSubjectInfo;

%preprocess the fMRI data
	%BET the structurals
		bProcess			= FileExists(ifo.path.structural.raw);
		cPathStructural		= ifo.path.structural.raw(bProcess);
		[b,cPathStructural]	= FSLBet(cPathStructural,...
								'thresh'	, 0.25			, ...
								'nthread'	, opt.nthread	, ...
								'force'		, opt.force		  ...
								);
	
	cPathFunctional		= ifo.path.functional.raw(bProcess);
	cPathFunctionalPP	= ifo.path.functional.pp(bProcess);
	bProcess			= cellfun(@FileExists,cPathFunctional,'uni',false);
	cPathFunctional		= cellfun(@(cf,b) cf(b),cPathFunctional,bProcess,'uni',false);
	cPathFunctionalPP	= cellfun(@(cf,b) cf(b),cPathFunctionalPP,bProcess,'uni',false);
	cPathStructural		= cellfun(@(s,f) repmat({s},size(f)),cPathStructural,cPathFunctional,'uni',false);
	
	[cPathFunctional,cPathStructural]	= varfun(@cellnestflatten,cPathFunctional,cPathStructural);
	
	[bSuccess,cPathOut,tr]	= FSLFEATPreprocess(cPathFunctional,cPathStructural,...
								'motion_correct'		, true			, ...
								'slice_time_correct'	, 6				, ...
								'spatial_fwhm'			, 6				, ...
								'norm_intensity'		, false			, ...
								'highpass'				, 100			, ...
								'lowpass'				, false			, ...
								'force'					, opt.force		, ...
								'nthread'				, opt.nthread	  ...
								);

%concatenate the fMRI runs
	bProcess			= ~cellfun(@isempty,cPathFunctionalPP);
	cPathFunctionalPP	= cPathFunctionalPP(bProcess);
	
	[b,cPathCat,cDirFEATCat]	= FSLConcatenate(cPathFunctionalPP,...
									'nthread'	, opt.nthread	, ...
									'force'		, opt.force		  ...
									);
	