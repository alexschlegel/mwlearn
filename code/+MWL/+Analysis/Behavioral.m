function [s,h] = Behavioral(varargin)
% MWL.Analysis.Behavioral
%
% Description:	analyze the behavioral results 
%
% Syntax:	[s,h] = MWL.Analysis.Behavioral(<options>)
%
% In:
%	<options>:
%		ifo:	(<load>) the subject info struct
%		robust:	([]) see MWL.Behavioral.ComputerResults
%		result:	(<load>) the behavioral results
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
			'robust'	, []	, ...
			'result'	, []	, ...
			'plot'		, false	  ...
			);
	
	if isempty(opt.ifo)
		ifo	= MWL.GetSubjectInfo;
	else
		ifo	= opt.ifo;
	end
	
	if isempty(opt.result)
		sResult	= MWL.Behavioral.Results('ifo',ifo,'robust',opt.robust);
	else
		sResult= opt.result;
	end

cGroup	=	{
				'exp'
				'con'
			};
nGroup	= numel(cGroup);

cTest	= fieldnames(sResult);
nTest	= numel(cTest);

%individual tests
	for kT=1:nTest
		strTest	= cTest{kT};
		
		%individual group t-tests
			cData	= cell(nGroup,1);
			for kG=1:nGroup
				strGroup	= cGroup{kG};
				bGroup		= ifo.group==kG;
				
				data		= sResult.(strTest)(bGroup,:);
				bTTest		= ~any(isnan(data(:,1:2)),2);
				cData{kG}	= data(bTTest,1:2);
				
				[nh,p,ci,stats]	= ttest(data(bTTest,2),data(bTTest,1));
				
				s.test.(strGroup).(strTest)	= struct(...
												'm'		, nanmean(data,1)	, ...
												'se'	, nanstderr(data,1)	, ...
												't'		, stats.tstat		, ...
												'df'	, stats.df			, ...
												'p'		, p					  ...
												);
			end
		
		%group comparison
			[p,table]	= anova_rm(reshape(cData,1,[]),'off');
			
			%store results for the group x time interaction term
			s.test.group.(strTest)	= struct(...
										'F'		, table{4,5}				, ...
										'df'	, [table{4,3} table{5,3}]	, ...
										'p'		, table{4,6}				  ...
										);
	end

%test correlations
	s.corr.test	= cTest;
	
	cTestTrain	=	{
						'assemblage'
						'construct'
						'rotate'
					};
	s.corr.raw	= cellfun(@(t) conditional(ismember(t,cTestTrain),sResult.(t)(:,1),nanmean(sResult.(t)(:,1:2),2)),s.corr.test,'uni',false);
	
	[cPair,kPair]	= handshakes(s.corr.raw);
	[r,stat]		= cellfun(@(x,y) corrcoef2(x,y'),cPair(:,1),cPair(:,2),'uni',false);
	
	s.corr.stat	= restruct(cell2mat(stat));
	s.corr.stat	= structsub(s.corr.stat,{'r','z','df','t','p'});
	
	[pt,s.corr.stat.pfdr]	= fdr(s.corr.stat.p,0.05);
	
	s.corr.stat	= structfun2(@(x) squareform(x) + conditional(logical(eye(size(squareform(x)))),NaN,0),s.corr.stat);
	
	if opt.plot
		r		= s.corr.stat.r;
		z		= s.corr.stat.z;
		p		= s.corr.stat.p;
		pfdr	= s.corr.stat.pfdr;
		cLabel	= cellfun(@(str) strrep(str,'_',''),s.corr.test,'uni',false);
		
		[r,kSort]	= SortConfusion(r);
		cLabel		= cLabel(kSort);
		z			= ReorderConfusion(z,kSort);
		p			= ReorderConfusion(p,kSort);
		pfdr		= ReorderConfusion(pfdr,kSort);
		
		r(pfdr>0.05)	= NaN;
		
		h.corr	= alexplot(r,...
					'nancol'		, [1 1 1]		, ...
					'cmmin'			, 0				, ...
					'label'			, cLabel		, ...
					'tplabel'		, false			, ...
					'scalelabel'	, 'r'			, ...
					'type'			, 'confusion'	  ...
					);
	end