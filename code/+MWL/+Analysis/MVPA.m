function [s,h] = MVPA(varargin)
% MWL.Analysis.MVPA
%
% Description:	analyze the MVPA results 
%
% Syntax:	[s,h] = MWL.Analysis.MVPA(<options>)
%
% In:
%	<options>:
%		ifo:	(<load>) the subject info struct
%		plot:	(false) true to plot results
%
% Out:
%	s	- a struct of results
%	h	- a struct of plot handles
% 
% Updated: 2015-04-16
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'ifo'		, []	, ...
			'plot'		, false	  ...
			);
	
	if isempty(opt.ifo)
		ifo	= MWL.GetSubjectInfo;
	else
		ifo	= opt.ifo;
	end

%load the results
	sAnalysis	= struct(...
					'roi'	, '20150320_roimvpa'	, ...
					'cc'	, '20150320_roiccmvpa'	, ...
					'dc'	, '20150320_roidcmvpa'	  ...
					);
	cAnalysis	= fieldnames(sAnalysis);
	nAnalysis	= numel(cAnalysis);
	
	res	= structfun2(@(n) MATLoad(PathUnsplit(DirAppend(strDirAnalysis,n),'result','mat'),'res'),sAnalysis);
	
	behav	= MWL.Behavioral.Results('ifo',ifo);

cGroup	=	{
				'exp'
				'con'
			};
nGroup	= numel(cGroup);

%between group change
	