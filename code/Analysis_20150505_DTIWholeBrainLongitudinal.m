% Analysis_20150505_DTIWholeBrainLongitudinal
% whole brain DTI FA/RD analyses looking for changes between the two groups
nCore	= 12;

%create directory for analysis results
	strNameAnalysis	= '20150505_dtiwholebrainlongitudinal';
	strDirOut		= DirAppend(strDirAnalysis, strNameAnalysis);
	CreateDirPath(strDirOut);

%get subject info
	ifo					= MWL.GetSubjectInfo;
	[nSubject,nSession]	= size(ifo.t.mri);

%input data
	strDirDTI	= DirAppend(strDirData,'diffusion');
	
	cNameData	= {'faz';'rdz'};
	cPathData	= cellfun(@(n) PathUnsplit(strDirDTI,n,'nii.gz'),cNameData,'uni',false);
	
	strPathWM	= PathUnsplit(strDirDTI,'wm','nii.gz');

%construct the design matrix
	%construct times
		g		= repmat(ifo.group,[nSession 1]);
		bExp	= g==1;
		bCon	= g==2;
		
		t	= reshape(repmat(1:nSession,[nSubject 1]),[],1);
		
		tExp	= t.*bExp;
		tCon	= t.*bCon;
	%control for subjects
		bSubject	= repmat(eye(nSubject),[nSession 1]);
	
	d	=	[
				bSubject	... %data points from single subjects
				tExp		... %time for experimentals
				tCon		... %time for controls
			];
%contrasts to test differences in slope between groups
	zSubject	= zeros(1,nSubject);
	
	tContrast	=	[
						zSubject 1 -1	%mE > mC
						zSubject -1 1	%mE < mC
					];
%exchangeability block definition
	kSubject	= (1:nSubject)';
	exch		= repmat(kSubject,[nSession 1]);

%call randomise
	cPathOut	= cellfun(@(n) PathUnsplit(strDirOut,n),cNameData,'uni',false);
	
	[b,cPathOut]	= FSLRandomise(cPathData,d,...
						'output'			, cPathOut	, ...
						'mask'				, strPathWM	, ...
						'tcontrast'			, tContrast	, ...
						'exchangeability'	, exch		, ...
						'cores'				, nCore		, ...
						'force'				, false		  ...
						);
