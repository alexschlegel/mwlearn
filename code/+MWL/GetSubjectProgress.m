function s = GetSubjectProgress(varargin)
% MWL.GetSubjectProgress
% 
% Description:	get the subjects' training progress
% 
% Syntax:	s = GetSubjectProgress(<options>)
%
% In:
%	<options>:
%		report: 		(true) true to print out info about the subjects'
%						progress
%		sort:			(<none>) the field by which to sort the data
%		order:			('ascend') either 'ascend' or 'descend', specifying the
%						sort order
%		unscheduled:	(false) true to include only subjects who aren't
%						scheduled for their followup fMRI scan
% 
% Updated: 2015-01-30
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'report'		, true		, ...
		'sort'			, []		, ...
		'order'			, 'ascend'	, ...
		'unscheduled'	, false		  ...
		);

sData	= MWL.GetTrainingData;

%exclude scheduled subjects
	if opt.unscheduled
		bKeep		= isnan(sData.ifo.fmri2);
		sData.id	= sData.id(bKeep);
		
		sData.ifo	= StructArrayRestructure(sData.ifo);
		sData.ifo	= sData.ifo(bKeep);
		sData.ifo	= StructArrayRestructure(sData.ifo);
		
		sData.data	= sData.data(bKeep);
	end

nSubject	= numel(sData.id);

tStart	= sData.ifo.behav1;
bEndSet	= ~isnan(sData.ifo.behav2);
tEnd	= conditional(bEndSet,sData.ifo.behav2,sData.ifo.behav1+ConvertUnit(4,'week','ms'));

s	= struct(...
		'id'				, {sData.id}		, ...
		'group'				, sData.ifo.group	, ...
		'email'				, {sData.ifo.email}	, ...
		't_start'			, tStart			, ...
		't_end'				, tEnd				, ...
		'end_type'			, bEndSet			, ...
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

s.t_end_est			= s.t_start + ConvertUnit(20./s.session_rate,'day','ms');
bBad				= isinf(s.t_end_est) | isnan(s.t_end_est);
s.t_end_est(bBad)	= s.t_end(bBad);

%sort the data
	if ~isempty(opt.sort)
		[dummy,kSort]	= sort(s.(opt.sort),opt.order);
		
		s	= StructArrayRestructure(s);
		s	= s(kSort);
		s	= StructArrayRestructure(s);
	end

if opt.report
	for kS=1:nSubject
		strLabel	= s.id{kS};
		
		disp(sprintf('%s: %03d days, %03d ses., %.2f ses./day, %s est. finish (%s)',...
			strLabel							, ...
			round(s.days_since_start(kS))		, ...
			s.sessions_finished(kS)				, ...
			s.session_rate(kS)					, ...
			FormatTime(s.t_end_est(kS),'mm/dd')	, ...
			s.email{kS}							  ...
			));
	end
end