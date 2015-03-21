function s = PaperResponses()
% MWL.Behavioral.PaperResponses
% 
% Description:	load the responses for the paper-based tests
% 
% Syntax:	s = PaperResponses()
% 
% Out:
% 	s	- a struct of responses for the paper-based tests
% 
% Updated: 2015-03-20
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
sKey	= MWL.Behavioral.PaperKeys;

cTest	= fieldnames(sKey);
nTest	= numel(cTest);

s	= struct;
for kT=1:nTest
	strTest	= cTest{kT};
	
	cVersion	= fieldnames(sKey.(strTest));
	nVersion	= numel(cVersion);
	
	for kV=1:nVersion
		strVersion	= cVersion{kV};
		
		s.(strTest).(strVersion)	= LoadResponses(strTest,strVersion);
	end
end


%------------------------------------------------------------------------------%
function res = LoadResponses(strTest,strVersion)
	global strDirData
	
	strDirBehavioral	= DirAppend(strDirData,'behavioral');
	strPathData			= PathUnsplit(strDirBehavioral,sprintf('%s_%s_responses',strTest,strVersion),'xls');
	
	[n,str,raw]	= xlsread(strPathData);
	
	res.id			= str(2:end,1);
	
	nSubject		= numel(res.id);
	
	data	= raw(2:end,2:end);
	if all(cellfun(@(x) isnumeric(x) || isnan(x),data(:)))
		data	= cell2mat(data);
	else
		data	= str(2:end,2:end);
	end
	
	nResponse		= size(data,2);
	res.response	= mat2cell(data,ones(nSubject,1),nResponse);
	res.response	= cellfun(@(x) reshape(x,nResponse,1),res.response,'uni',false);
end
%------------------------------------------------------------------------------%

end
