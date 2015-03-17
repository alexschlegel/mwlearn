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
	cFieldSessionMRI	= {'fmri1'; 'fmri2'};
	cFieldSessionBehav	= {'behav1'; 'behav2'; 'behav3'};
	cFieldSession		= [cFieldSessionMRI; cFieldSessionBehav];
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
		[bKeep,kKeep]	= ismember(kReturn,ifo.n);
		kKeep			= kKeep(bKeep);
		ifo				= structfun2(@(x) x(kKeep),ifo);
	end
%sort by subject code and eliminate blank and inactive subjects
	[c,kSort]	= sort(ifo.n);
	ifo			= restruct(ifo);
	ifo			= ifo(kSort);
	
	bRemove			= arrayfun(@(s) isempty(s.id) || s.active==0,ifo);
	ifo(bRemove)	= [];
	
	ifo			= restruct(ifo);

%reorganize the session times
	ifo.t.mri			= cellfun(@(f) ifo.(f),cFieldSessionMRI,'uni',false);
	ifo.t.behavioral	= cellfun(@(f) ifo.(f),cFieldSessionBehav,'uni',false);
	ifo.t				= structfun2(@(ct) cat(2,ct{:}),ifo.t);
	
	ifo	= rmfield(ifo,cFieldSession);

%get some derived info
	%subject name
		ifo.name	= cellfun(@(a,b) conditional(~isempty(b),b,a),ifo.first,ifo.preferred,'UniformOutput',false);
	%session codes
		ifo.code	= structfun2(@(t) cellfun(@sessioncode,repmat(ifo.id,[1 size(t,2)]),num2cell(t),'uni',false),ifo.t); 
		
	%various paths
		ifo.path.session		= structfun2(@(cs) cellfun(@(s) GetPathSessionMAT(strDirData,s),cs,'uni',false),ifo.code);
		ifo.path.functional.raw	= cellfun(@(s) GetPathFunctional(strDirData,s,'run','all'),ifo.code.mri,'uni',false);
		ifo.path.functional.pp	= cellfun(@(s,raw) conditional(numel(raw)>0,GetPathFunctional(strDirData,s,'type','pp','run',(1:numel(raw))'),{}),ifo.code.mri,ifo.path.functional.raw,'uni',false);
		ifo.path.functional.cat	= cellfun(@(s) GetPathFunctional(strDirData,s,'type','cat'),ifo.code.mri,'uni',false);
		ifo.path.diffusion.raw	= cellfun(@(s) GetPathDTI(strDirData,s),ifo.code.mri,'uni',false);
		ifo.path.structural.raw	= cellfun(@(s) GetPathStructural(strDirData,s),ifo.code.mri,'uni',false);
