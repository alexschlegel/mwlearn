function s = PaperResults(varargin)
% MWL.Behavioral.PaperResults
%
% Description:	load paper-based behavioral results 
%
% Syntax:	s = MWL.Behavioral.PaperResults(<options>);
%
% In: 
%   <options>:
%       session:	(<all>) a cell of session codes
%		ifo:		(<load>) the full results of MWL.GetSubjectInfo
%
% Out:
%   s	- a struct of paper-based behavioral results
% 
% Updated: 2015-03-20
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'session'	, []	, ...
			'ifo'		, []	  ...
			);
	
	if isempty(opt.ifo)
		ifo	= MWL.GetSubjectInfo;
	else
		ifo	= opt.ifo;
	end
	
	if isempty(opt.session)
		cSession	= ifo.code.behavioral;
	else
		cSession	= opt.session;
	end
	
	bExist		= ~cellfun(@isempty,cSession);
	szSession	= size(cSession);

%load the keys and responses
	sKey		= MWL.Behavioral.PaperKeys;
	sResponse	= MWL.Behavioral.PaperResponses;

%test version for the master list of behavioral sessions
	cSessionMaster	= ifo.code.behavioral;
	cVersionMaster	= cell(size(cSessionMaster));
	
	cVersionMaster(:,[1 3])	= repmat(lower(ifo.order),[1 2]);
	cVersionMaster(:,2)		= cellfun(@(v) switch2(v,'A','b','B','a'),ifo.order,'uni',false);
	
	[bMaster,kMaster]	= ismember(cSession,cSessionMaster);
	bMaster(~bExist)	= false;
	kMaster(~bExist)	= 0;

%process the results for each test
	[cID,cVersion]	= deal(cell(szSession));
	
	[t,cID(bExist)]	= cellfun(@ParseSessionCode,cSession(bExist),'uni',false);
	cVersion(bExist)	= cVersionMaster(kMaster(bExist));
	
	cTest	= fieldnames(sKey);
	nTest	= numel(cTest);
	
	s	= struct;
	for kT=1:nTest
		strTest	= cTest{kT};
		
		key	= sKey.(strTest);
		res	= sResponse.(strTest);
		
		[keys,ress,kRes]	= deal(cell(szSession));
		keys(bExist)		= cellfun(@(v) key.(v),cVersion(bExist),'uni',false);
		
		kRes(bExist)	= cellfun(@(id,v) find(strcmp(res.(v).id,id)),cID(bExist),cVersion(bExist),'uni',false);
		bExist			= ~cellfun(@isempty,kRes);
		ress(bExist)	= cellfun(@(k,v) res.(v).response{k},kRes(bExist),cVersion(bExist),'uni',false);
		
		s.(strTest)	= NaN(szSession);
		if iscell(key.a)
			bExist(bExist)	= cellfun(@(c) ~all(cellfun(@isempty,c)),ress(bExist));
			
			correct	= cellfun(@strcmp,keys(bExist),ress(bExist),'uni',false);
		else
			bExist(bExist)	= cellfun(@(x) ~all(isnan(x)),ress(bExist));
			
			correct	= cellfun(@(k,r) k==r,keys(bExist),ress(bExist),'uni',false);
		end
		s.(strTest)(bExist)	= cellfun(@nanmean,correct);
	end
