function b = SendTrainingReminders(varargin)
% MWL.SendTrainingReminders
% 
% Description:	send a daily training reminder email to each participant who has
%				not yet finished the training
% 
% Syntax:	b = MWL.SendTrainingReminders(<options>)
% 
% In:
%	<options>:
%		from:		('schlegel@gmail.com') the from email address
%		confirm:	(false) see SendEmailByTemplate
% 
% Out:
% 	b	- a logical array indicating which messages were successfully sent
% 
% Updated: 2015-01-21
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirBase;

opt	= ParseArgs(varargin,...
		'from'		, 'schlegel@gmail.com'	, ...
		'confirm'	, false					  ...
		);

%get the subject info
	ifo	= MWL.GetSubjectInfo;
%get the training data
	sProgress	= MWL.GetSubjectProgress('report',false);

%process stuff
	ifo	= StructMerge(ifo,sProgress);
	
	ifo.training_type	= conditional(ifo.group==1,{'imagery'},{'language'});
	
	ifo.session_rate		= roundn(ifo.session_rate,-3);
	ifo.days_since_start	= round(ifo.days_since_start);
	ifo.date_end			= arrayfun(@(t) strrep(FormatTime(t,'mmmm dd'),'  ',' '),ifo.t_end,'UniformOutput',false);
	ifo.days_left			= round(ConvertUnit(ifo.t_end - nowms,'ms','day'));
	ifo.end_date_type		= conditional(ifo.end_type,{'your second behavioral session date'},{'four weeks total'});
	
	bRemind	= ifo.training_reminder==1 & ifo.sessions_finished<20 & ifo.days_since_start>0;
	
	ifo			= StructArrayRestructure(ifo);
	ifo			= ifo(bRemind);
	ifo			= StructArrayRestructure(ifo);
%remind!
	strPathTemplate			= PathUnsplit(DirAppend(strDirBase,'code','email_templates'),'training_reminder','template');
	
	cOptExtra	= opt2cell(GetFieldPath(opt,'opt_extra'));
	
	PrepEmail(opt.from);
	b	= SendEmailByTemplate(strPathTemplate,ifo,'confirm',opt.confirm,cOptExtra{:});
	EndEmail;
