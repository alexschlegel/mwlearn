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

%update the training_data json file
	strCommand	= PathUnsplit(DirAppend('/','home','tselab','studies','mwlearn','code'),'export_training_data');
	if ~strcmp(computername,'wertheimer')
		strCommand	= sprintf('ssh tselab@wertheimer.dartmouth.edu %s',strCommand);
	end
	[ec,out]	= RunBashScript(strCommand);