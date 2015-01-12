function s = GetSubjectProgress(varargin)
% MWL.GetSubjectProgress
% 
% Description:	get the subjects' training progress
% 
% Syntax:	s = GetSubjectProgress(<options>)
%
% In:
%	<options>:
%		report: 	(true) true to print out info about the subjects' progress
% 
% Updated: 2015-01-11
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'report'	, true	  ...
		);

sData	= MWL.GetTrainingData;

nSubject	= numel(sData.id);

tStart	= sData.ifo.behav1;
tEnd	= conditional(~isnan(sData.ifo.behav2),sData.ifo.behav2,sData.ifo.behav1+ConvertUnit(4,'week','ms'));

s	= struct(...
		'id'				, {sData.id}		, ...
		'group'				, sData.ifo.group	, ...
		'email'				, {sData.ifo.email}	, ...
		't_start'			, tStart			, ...
		't_end'				, tEnd				, ...
		'sessions_finished'	, zeros(nSubject,1)	  ...
		);

for kS=1:nSubject
	if ~isempty(sData.data{kS})
		if s.group(kS)==1
			s.sessions_finished(kS)	= sData.data{kS}.sessions_finished.value;
		else
			s.sessions_finished(kS)	= numel(sData.data{kS});
		end
	end
end

tRef	= conditional(s.t_end>nowms,nowms,s.t_end);

s.days_since_start	= ConvertUnit(tRef-tStart,'ms','day');
s.session_rate		= s.sessions_finished./s.days_since_start;

if opt.report
	[dummy,kSort]	= sort(s.days_since_start,1,'descend');
	sR				= StructArrayRestructure(s);
	sR				= sR(kSort);
	sR				= StructArrayRestructure(sR);
	
	
	for kS=1:nSubject
		strLabel	= sR.id{kS};
		
		disp(sprintf('%s: %03d days, %03d sessions, %.2f sessions/day (%s)',...
			strLabel						, ...
			round(sR.days_since_start(kS))	, ...
			sR.sessions_finished(kS)		, ...
			sR.session_rate(kS)				, ...
			sR.email{kS}					  ...
			));
	end
end