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
global strDirCode

%update the database json files
	strCommand	= PathUnsplit(DirAppend('/','home','tselab','studies','mwlearn','code'),'export_mongo_data');
	if ~strcmp(computername,'wertheimer')
		strCommand	= sprintf('ssh tselab@wertheimer.dartmouth.edu %s',strCommand);
	end
	[ec,out]	= RunBashScript(strCommand,'silent',true);
	
	if ec~=0
		error('Could not update the mongo export files.');
	end

%load the training_data json file
	strPathTD	= PathUnsplit(DirAppend(strDirData,'raw'),'training_data','json');
	s.exp		= json.from(fget(strPathTD));

%update the control_data json file
	