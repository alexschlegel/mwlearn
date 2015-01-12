function s = GetTrainingData()
% MWL.GetTrainingData
% 
% Description:	get the current training (and control) data from wertheimer's
%				mongo database
% 
% Syntax:	s = GetTrainingData()
% 
% Out:
% 	s	- a struct of info for each subject
% 
% Updated: 2015-01-11
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirData

%load the subject info
	ifo	= MWL.GetSubjectInfo;

%initialize the output struct
	s	= struct(...
			'id'	, {ifo.id}					, ...
			'ifo'	, ifo						, ...
			'data'	, {cell(numel(ifo.id),1)}	  ...
			);

%update the database json files
	status('Updating mongo export files');
	
	strCommand	= PathUnsplit(DirAppend('/','home','tselab','studies','mwlearn','code'),'export_mongo_data');
	if ~strcmp(computername,'wertheimer')
		strCommand	= sprintf('ssh tselab@wertheimer.dartmouth.edu %s',strCommand);
	end
	[ec,out]	= RunBashScript(strCommand,'silent',true);
	
	if ec~=0
		error('Could not update the mongo export files.');
	end

status('Loading database data');
	%load the training_data json file
		strPathTD	= PathUnsplit(DirAppend(strDirData,'raw'),'training_data','json');
		sExp		= json.from(fget(strPathTD));
		
		nExp	= numel(sExp);
		for kE=1:nExp
			sExpCur		= sExp(kE);
			kSubject	= find(strcmp(s.id,sExpCur.user));
			
			if ~isempty(kSubject)
				s.data{kSubject}	= sExpCur;
			end
		end
	
	%load the control_data json file
		strPathCD	= PathUnsplit(DirAppend(strDirData,'raw'),'control_data','json');
		sCon		= json.from(fget(strPathCD));
		sCon		= cat(1,sCon{:});
		
		cUser	= {sCon.user};
		cUserU	= unique(cUser);
		nUser	= numel(cUserU);
		
		for kU=1:nUser
			strUser		= cUserU{kU};
			kSubject	= find(strcmp(ifo.user,strUser));
			
			if strcmp(strUser(1:7),'mwlearn') && ~isempty(kSubject)
				kUser	= find(strcmp(cUser,strUser));
				sConCur	= sCon(kUser);
				
				s.data{kSubject}	= sConCur;
			end
		end
