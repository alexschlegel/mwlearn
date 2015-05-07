% Analysis_20150505_DTIWholeBrainCorrelation
% whole brain DTI FA/RD analyses looking for correlations with behavioral
% measures
nCore	= 12;

%create directory for analysis results
	strNameAnalysis	= '20150505_dtiwholebraincorrelation';
	strDirOut		= DirAppend(strDirAnalysis, strNameAnalysis);
	CreateDirPath(strDirOut);

%get subject info
	ifo					= MWL.GetSubjectInfo;
	[nSubject,nSession]	= size(ifo.t.mri);
	kSession			= (1:nSession)';
	
	resBehav	= MWL.Behavioral.Results('session',ifo.code.behavioral(:,kSession));

%input data
	strDirDTI	= DirAppend(strDirData,'diffusion');
	
	cNameData	= {'faz';'rdz'};
	nData		= numel(cNameData);
	cPathData	= arrayfun(@(s) cellfun(@(n) PathUnsplit(strDirDTI,sprintf('%s_%d',n,s),'nii.gz'),cNameData,'uni',false),kSession,'uni',false);
	
	strPathWM	= PathUnsplit(strDirDTI,'wm','nii.gz');

%construct the design matrices
	cMeasure	= fieldnames(resBehav);
	nMeasure	= numel(cMeasure);
	
	d	= arrayfun(@(s) cellfun(@(m) resBehav.(m)(:,s),cMeasure,'uni',false),kSession,'uni',false);
%t-contrasts
	tContrast	= [1; -1];

%call randomise
	kSessionRep		= arrayfun(@(s) repmat(num2cell(s),[nData 1]),kSession,'uni',false);
	cNameDataRep	= repmat({cNameData},[nSession 1]);
	
	[cPathDataRep,kSessionRep,cNameDataRep]	= varfun(@(c) cellnestflatten(cellfun(@(x) reshape(repmat(x,[1 nMeasure]),[],1),c,'uni',false)),cPathData,kSessionRep,cNameDataRep);
	
	cMeasureRep	= repmat({cMeasure},[nSession 1]);
	
	[dRep,cMeasureRep]	= varfun(@(c) cellnestflatten(cellfun(@(x) reshape(repmat(reshape(x,1,[]),[nData 1]),[],1),c,'uni',false)),d,cMeasureRep);
	
	cNameOut	= cellfun(@(d,s,m) sprintf('%s_%d_%s',d,s,m),cNameDataRep,kSessionRep,cMeasureRep,'uni',false);
	cPathOut	= cellfun(@(n) PathUnsplit(strDirOut,n),cNameOut,'uni',false);
	
	[b,cPathOut]	= FSLRandomise(cPathDataRep,dRep,...
						'output'			, cPathOut	, ...
						'mask'				, strPathWM	, ...
						'tcontrast'			, tContrast	, ...
						'cores'				, nCore		, ...
						'force'				, false		  ...
						);
