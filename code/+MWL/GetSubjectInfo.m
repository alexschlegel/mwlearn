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
% Updated: 2015-01-03
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
kReturn	= ParseArgs(varargin,[]);

global strDirBase;

warning('off','MATLAB:xlsread:ActiveX');

%numeric fields
	cNumeric	= {'n','group','dob','learn_style','fmri1','behav1','fmri2','behav2'};
%date fields
	cDate		= {'dob','fmri1','behav1','fmri2','behav2'};

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
					mGender				= mapping({'f','m'},{0 1});
					ifo.(cField{kF})	= cellfun(@(x) mGender(lower(x)),ifo.(cField{kF}),'UniformOutput',false);
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
%get some derived info
	%subject name
		ifo.name	= cellfun(@(a,b) conditional(~isempty(b),b,a),ifo.first,ifo.preferred,'UniformOutput',false);
%keep the specified subset
	if ~isempty(kReturn)
		[bKeep,kKeep]	= ismember(kReturn,ifo.code);
		kKeep			= kKeep(bKeep);
		ifo				= structfun2(@(x) x(kKeep),ifo);
	end

%sort by subject code and eliminate blank subjects
	[c,kSort]	= sort(ifo.n);
	ifo			= StructArrayRestructure(ifo);
	ifo			= ifo(kSort);
	
	bBlank		= cellfun(@isempty,{ifo.id});
	ifo(bBlank)	= [];
	
	ifo			= StructArrayRestructure(ifo);
