function res = Results(varargin)
% MWL.MVPA.Results
%
% Description:	load the MVPA results 
%
% Syntax:	res = MWL.MVPA.Results(<options>)
%
% In:
%	<options>:
%		ifo:	(<load>) the subject info struct
%
% Out:
%	res	- a struct of results
% 
% Updated: 2015-04-30
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirAnalysis

%parse the inputs
	opt	= ParseArgs(varargin,...
			'ifo'		, []	  ...
			);
	
	if isempty(opt.ifo)
		ifo	= MWL.GetSubjectInfo;
	else
		ifo	= opt.ifo;
	end

%subject info
	nSubject	= numel(ifo.id);
	nSession	= 2;

%load the results
	sAnalysis	= struct(...
					'roi'	, '20150320_roimvpa'	, ...
					'cc'	, '20150320_roiccmvpa'	, ...
					'dc'	, '20150320_roidcmvpa'	  ...
					);
	cAnalysis	= fieldnames(sAnalysis);
	nAnalysis	= numel(cAnalysis);
	
	progress('action','init','total',nAnalysis,'label','loading data from each analysis');
	for kA=1:nAnalysis
		strField	= cAnalysis{kA};
		strAnalysis	= sAnalysis.(strField);
		
		strDirResult	= DirAppend(strDirAnalysis,strAnalysis);
		strPathResult	= PathUnsplit(strDirResult,'result','mat');
		
		r	= MATLoad(strPathResult,'res');
		
		cScheme	= fieldnames(r);
		nScheme	= numel(cScheme);
		
		for kS=1:nScheme
			strScheme	= cScheme{kS};
			
			res.(strField).(strScheme).data		= reshape(r.(strScheme).param.path_data,[],nSubject,nSession);
			
			cDataSession	= squeeze(res.(strField).(strScheme).data(1,:,:));
			cDataMask		= squeeze(res.(strField).(strScheme).data(:,1,1));
			
			if iscell(cDataSession{1})
				res.(strField).(strScheme).session	= cellfun(@(c) PathGetSession(c{1}),cDataSession,'uni',false);
				res.(strField).(strScheme).mask		= cellfun(@(c) join(cellfun(@PathGetMaskName,c,'uni',false),'-'),cDataMask,'uni',false);
			else
				res.(strField).(strScheme).session	= cellfun(@PathGetSession,cDataSession,'uni',false);
				res.(strField).(strScheme).mask		= cellfun(@PathGetMaskName,cDataMask,'uni',false);
			end
			
			res.(strField).(strScheme).accuracy	= reshape(r.(strScheme).result.allway.accuracy.mean,[],nSubject,nSession);
			res.(strField).(strScheme).corr		= reshape(r.(strScheme).result.allway.stats.confusion.corr.r,[],nSubject,nSession);
			res.(strField).(strScheme).corrz	= reshape(r.(strScheme).result.allway.stats.confusion.corr.z,[],nSubject,nSession);
		end
		
		progress;
	end
