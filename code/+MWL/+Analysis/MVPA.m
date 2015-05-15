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
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
s	= struct;

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
	mvpa	= MWL.MVPA.Results('ifo',ifo);
	behav	= MWL.Behavioral.Results('ifo',ifo);
	
	cAnalysis	= fieldnames(mvpa);
	nAnalysis	= numel(cAnalysis);
	
	cScheme	= fieldnames(mvpa.(cAnalysis{1}));
	nScheme	= numel(cScheme);
	
	cMVPAMeasure	=	{
							'accuracy'
							'corr'
							'corrz'
						};
	nMVPAMeasure	= numel(cMVPAMeasure);
	
	cBehavMeasure	= fieldnames(behav);
	nBehavMeasure	= numel(cBehavMeasure);

%groups
	bGroup	= arrayfun(@(g) ifo.group==g,(1:2)','uni',false);

%between group change
	s.group	= struct;
	
	for kA=1:nAnalysis
		strAnalysis	= cAnalysis{kA};
		
		s.group.(strAnalysis).mask	= mvpa.(strAnalysis).(cScheme{1}).mask;
		
		nMask	= numel(s.group.(strAnalysis).mask);
		
		for kS=1:nScheme
			strScheme	= cScheme{kS};
			
			for kM=1:nMVPAMeasure
				strMeasure	= cMVPAMeasure{kM};
				
				d	= mvpa.(strAnalysis).(strScheme).(strMeasure);
				
				[ss.mExp,ss.seExp,ss.mCon,ss.seCon,ss.df]	= deal(NaN(nMask,2));
				[ss.F,ss.p]									= deal(NaN(nMask,1));
				for kK=1:nMask
					dExp	= squeeze(d(kK,bGroup{1},1:2));
					dCon	= squeeze(d(kK,bGroup{2},1:2));
					
					ss.mExp(kK,:)	= nanmean(dExp,1);
					ss.seExp(kK,:)	= nanstderr(dExp,1);
					ss.mCon(kK,:)	= nanmean(dCon,1);
					ss.seCon(kK,:)	= nanstderr(dCon,1);
					
					[p,table]	= anova_rm({dExp dCon},'off');
					
					ss.df(kK,:)	= [table{4,3} table{5,3}];
					ss.F(kK)	= table{4,5};
					ss.p(kK)	= table{4,6};
				end
				
				[dummy,ss.pfdr]	= fdr(ss.p,0.05);
				
				s.group.(strAnalysis).(strScheme).(strMeasure)	= ss;
			end
		end
	end

%correlation between mvpa and behavioral measures
	s.behavcorr	= struct;
	
	cCorrMethod	= {'first';'mean';'change';'first2change'};
	nCorrMethod	= numel(cCorrMethod);
	
	dBehav		= cellfun(@(x) permute(x,[3 1 2]),struct2cell(behav),'uni',false);
	dBehav		= cat(1,dBehav{:});
	
	dBehav	=	{
					dBehav(:,:,1)
					nanmean(dBehav,3)
					dBehav(:,:,2)-dBehav(:,:,1)
					dBehav(:,:,2)-dBehav(:,:,1)
				};
	
	for kA=1:nAnalysis
		strAnalysis	= cAnalysis{kA};
		
		s.behavcorr.(strAnalysis).mask	= mvpa.(strAnalysis).(cScheme{1}).mask;
		s.behavcorr.(strAnalysis).behav	= cBehavMeasure;
		
		nMask	= numel(s.group.(strAnalysis).mask);
		
		for kS=1:nScheme
			strScheme	= cScheme{kS};
			
			for kM=1:nMVPAMeasure
				strMeasure	= cMVPAMeasure{kM};
				
				dMVPA	= mvpa.(strAnalysis).(strScheme).(strMeasure);
				dMVPA	=	{
								dMVPA(:,:,1)
								nanmean(dMVPA,3)
								dMVPA(:,:,2)-dMVPA(:,:,1)
								dMVPA(:,:,1)
							};
				
				for kC=1:nCorrMethod
					strCorrMethod	= cCorrMethod{kC};
					
					ss	= dealstruct('r','z','df','p',NaN(nMask,nBehavMeasure));
					for kK=1:nMask
						dm	= reshape(dMVPA{kC}(kK,:),[],1);
						db	= dBehav{kC};
						
						[r,stat]	= corrcoef2(dm,db);
						
						ss.r(kK,:)	= stat.r;
						ss.z(kK,:)	= stat.z;
						ss.df(kK,:)	= stat.df;
						ss.p(kK,:)	= stat.p;
					end
					
					[dummy,ss.pfdr]	= fdr(ss.p,0.05);
					
					s.behavcorr.(strAnalysis).(strScheme).(strMeasure).(strCorrMethod)	= ss;
				end
			end
		end
	end

%no plots
	h	= [];

