function b = SendReminders(varargin)
% MWL.SendReminders
% 
% Description:	send a reminder email about a scanning or behavioral session
%				times that are occuring on the day indicated by tBase
% 
% Syntax:	b = MWL.SendReminders([tBase]='tomorrow',<options>)
% 
% In:
%	[tBase]	- the base time
%	<options>:
%		from:					('schlegel@gmail.com') the from email address
%		offset:					(0) the offset of the notification time from the
%								actual scan time, in hours
% 
% Out:
% 	b	- a logical array indicating which messages were successfully sent
% 
% Updated: 2015-03-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirBase;

[tBase,opt]	= ParseArgs(varargin,'tomorrow',...
				'from'		, 'schlegel@gmail.com'	, ...
				'offset'	, 0						  ...
				);

tOffset	= ConvertUnit(opt.offset,'hour','ms');

%get the subject info
	s	= MWL.GetSubjectInfo;
	
	nSubject	= numel(s.n);
	
	tMRI		= reshape(s.t.mri,[],1);
	tBehavioral	= reshape(s.t.behavioral,[],1);
	
	ifo.tscan	= [tMRI; tBehavioral];
	ifo.mri		= [true(size(tMRI)); false(size(tBehavioral))];
	
	ifo.name	= repto(s.name,size(t.tscan));
	ifo.email	= repto(s.email,size(t.tscan));
	
	bConsider	= ~isnan(ifo.tscan);
	ifo			= structtreefun(@(x) x(bConsider,:),ifo);
	
	ifo.tscan_short	= arrayfun(@FormatTimeShort,ifo.tscan,'UniformOutput',false);
	ifo.tscan_long	= arrayfun(@FormatTimeLong,ifo.tscan,'UniformOutput',false);
%time info
	strTBase	= conditional(ischar(tBase),tBase,FormatTime(tBase));
	tStart		= FormatTime(['start of ' strTBase]);
	tEnd		= FormatTime(['end of ' strTBase]);
	
	bSubject	= ifo.tscan>=tStart & ifo.tscan<=tEnd;
	kSubject	= find(bSubject);
	nSubject	= numel(kSubject);
	
	[t,kSort]		= sort(ifo.tscan(kSubject));
	kSubject		= kSubject(kSort);
	
	ifo	= structtreefun(@(x) x(kSubject,:),ifo);
%remind!
	ifo.tscan	= ifo.tscan + tOffset;
	
	strPathMRITemplate			= PathUnsplit(DirAppend(strDirBase,'code','email_templates'),'mri_reminder','template');
	strPathBehavioralTemplate	= PathUnsplit(DirAppend(strDirBase,'code','email_templates'),'behavioral_reminder','template');
	
	cTemplate	= conditional(ifo.mri,{strPathMRITemplate},{strPathBehavioralTemplate});
	
	cOptExtra	= opt2cell(GetFieldPath(opt,'opt_extra'));
	
	PrepEmail(opt.from);
	b	= SendEmailByTemplate(cTemplate,ifo,cOptExtra{:});
	EndEmail;

%------------------------------------------------------------------------------%
function strTime = FormatTimeShort(t)
	strTime	= sprintf('%s at %s',FormatTime(t,'mm/dd'),strrep(FormatTime(t,'HH:MMPM'),' ',''));
end
%------------------------------------------------------------------------------%
function strTime = FormatTimeLong(t)
	strTime	= strrep(FormatTime(t,'informal'),'  ',' ');
end
%------------------------------------------------------------------------------%

end
