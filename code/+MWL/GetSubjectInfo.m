function ifo = GetSubjectInfo(varargin)
% MWL.GetSubjectInfo
% 
% Description:	get info about the MWLearn subjects
% 
% Syntax:	ifo = MWL.GetSubjectInfo([kReturn]=<all>)
% 
% In:
% 	kReturn	- the subject numbers (from the code column) of the subjects to load
% 
% Out:
% 	ifo	- a struct of info
% 
% Updated: 2015-03-10
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
kReturn	= ParseArgs(varargin,[]);

global strDirBase strDirData

warning('off','MATLAB:xlsread:ActiveX');

%session date fields
	cFieldSession	= {'fmri1'; 'behav1'; 'fmri2'; 'behav2'; 'behav3'};
%numeric fields
	cNumeric	= ['n'; 'group'; 'dob'; 'learn_style'; cFieldSession];
%date fields
	cDate		= ['dob'; cFieldSession];

strDirXLS	= DirAppend(strDirBase,'docs','secure');
strPathXLS	= PathUnsplit(strDirXLS,'subject_info','xls');

%read the info
	[x,str,raw]	= xlsread(strPathXLS);
	
%parse into a struct
	cField	= cellfun(@(x) lower(str2fieldname(x)),raw(1,:),'UniformOutput',false);
	nField	= numel(cField);
	
	for kF=1:nField
		ifo.(cField{kF})	= raw(2:end,kF);
		
		%data-specific manipulation
			switch cField{kF}
				case {'gender'}
					ifo.(cField{kF})	= cellfun(@(x) switch2(lower(x),'f',0,'m',1,NaN),ifo.(cField{kF}));
			end
		%fix date fields
			if ismember(cField{kF},cDate)
				ifo.(cField{kF})	= cellfun(@ExcelDate2ms,ifo.(cField{kF}),'UniformOutput',false);
			end
		%fix numeric cells
			if ismember(cField{kF},cNumeric)
				bNaN					= cellfun(@(x) ~isscalar(x) | ~isnumeric(x),ifo.(cField{kF}));
				ifo.(cField{kF})(bNaN)	= {NaN};
				ifo.(cField{kF})		= cell2mat(ifo.(cField{kF}));
			end
		%fix empty string cells
			if iscell(ifo.(cField{kF}))
				bBlank	= cellfun(@(x) all(isnan(x)),ifo.(cField{kF}));
				
				ifo.(cField{kF})(bBlank)	= {''};
			end
	end
%keep the specified subset
	if ~isempty(kReturn)
		[bKeep,kKeep]	= ismember(kReturn,ifo.code);
		kKeep			= kKeep(bKeep);
		ifo				= structfun2(@(x) x(kKeep),ifo);
	end

%get some derived info
	%subject name
		ifo.name	= cellfun(@(a,b) conditional(~isempty(b),b,a),ifo.first,ifo.preferred,'UniformOutput',false);

%sort by subject code and eliminate blank and inactive subjects
	[c,kSort]	= sort(ifo.n);
	ifo			= restruct(ifo);
	ifo			= ifo(kSort);
	
	bRemove			= arrayfun(@(s) isempty(s.id) || s.active==0,ifo);
	ifo(bRemove)	= [];
	
	ifo			= restruct(ifo);

%get the session codes
	cSessionCode	= cellfun(@(f) cellfun(@(t,id) conditional(isnan(t),NaN,sprintf('%s%s',lower(FormatTime(t,'ddmmmyy')),id)),num2cell(ifo.(f)),ifo.id,'uni',false),cFieldSession,'uni',false);
	ifo.code	= cell2struct(cSessionCode,cFieldSession);

%get the various paths
	ifo.path.session	= structfun2(@(cs) cellfun(@GetSessionPath,cs,'uni',false),ifo.code);


%------------------------------------------------------------------------------%
function strPathSession = GetSessionPath(s)
	if isnan(s)
		strPathSession	= NaN;
	else
		strPathSession	= PathUnsplit(strDirData,s,'mat');
	end
end
%------------------------------------------------------------------------------%

end
