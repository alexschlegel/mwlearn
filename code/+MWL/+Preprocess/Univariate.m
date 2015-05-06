function Univariate(varargin)
% MWL.Preprocess.Univariate
% 
% Description:	calculate betas for the block design (to be used in subsequent
%				comparisons between BOLD activity and behavioral measures)
% 
% Syntax:	MWL.Preprocess.Univariate(<options>)
% 
% In:
% 	<options>:
%		cores:	(12)
%		force:	(false)
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%process the input
	opt	= ParseArgs(varargin,...
			'cores'	, 12	, ...
			'force'	, false	  ...
			);

%get subject info
	ifo			= MWL.GetSubjectInfo;
	cSession	= ifo.code.mri;
	
	s	= GO.BehavioralResults('session',cSession);

%construct the design matrices
	nTRRest		= GO.Param('trrest');
	nTRRestPre	= GO.Param('trrestpre');
	nTRRestPost	= GO.Param('trrestpost');
	nTRTrial	= GO.Param('trtrial');
	
	nTrial	= GO.Param('trialperrun');
	nRun	= GO.Param('exp','runs');
	
	block	= cellfun(@(ab) cellfun(@(b) 2-b,mat2cell(ab,ones(size(ab,1),1),size(ab,2)),'uni',false),s.block.correct,'uni',false);
	
	ev	= cellfun(@(cb) cellfun(@(b) block2ev(b,nTRTrial,nTRRest,nTRRestPre-nTRRest,nTRRestPost-nTRRest,2),cb,'uni',false),block,'uni',false);
	ev	= cellfun(@(cev) cat(1,cev{:}),ev,'uni',false);
	
	cEVName	= {'correct';'incorrect'};

%first level FEAT
	cPathData	= ifo.path.functional.cat;
	
	tContrast		=	[
							1	0
							1	-1
						];
	tContrastName	= {'correct';'c>i'};
	
	[b,cDirOut]	= FSLFEATFirst(cPathData,ev,...
					'ev_name'			, cEVName		, ...
					'convolve'			, true			, ...
					'tderivative'		, true			, ...
					'tcontrast'			, tContrast		, ...
					'tcontrast_name'	, tContrastName	, ...
					'cores'				, opt.cores		, ...
					'force'				, opt.force		  ...
					);
