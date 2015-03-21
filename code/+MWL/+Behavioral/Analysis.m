function s = Analysis(varargin)
% MWL.Behavioral.Analysis
%
% Description:	analyze the behavioral results 
%
% Syntax:	s = MWL.Behavioral.Analysis(<options>)
%
% In:
%	<options>:
%		ifo:	(<load>) the subject info struct
%		result:	(<load>) the behavioral results
%
% Example:
%	sAnalysis = MWL.Behavioral.Analysis;
%	cLabel = cellfun(@(str) strrep(str,'_',''),sAnalysis.corr.test,'uni',false);
%	[M,k] = spectralreorder(sAnalysis.corr.stat.r);
%	h = alexplot(M,'label',cLabel(k),'type','confusion');
% 
% Updated: 2015-03-20
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'ifo'		, []	, ...
			'result'	, []	  ...
			);
	
	if isempty(opt.ifo)
		ifo	= MWL.GetSubjectInfo;
	else
		ifo	= opt.ifo;
	end
	
	if isempty(opt.result)
		sResult	= MWL.Behavioral.Results('ifo',ifo);
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
				
				[h,p,ci,stats]	= ttest(data(bTTest,2),data(bTTest,1));
				
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
	s.corr.stat	= structfun2(@squareform,s.corr.stat);
