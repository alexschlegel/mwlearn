% Analysis_20150511_DTIWholeBrainCorrelationTest
% make sure Analysis_20150505_DTIWholeBrainCorrelation is set up correctly by
% injecting some signal
nCore	= 12;

%create directory for analysis results
	strNameAnalysis	= '20150511_dtiwholebraincorrelationtest';
	strDirOut		= DirAppend(strDirAnalysis, strNameAnalysis);
	CreateDirPath(strDirOut);

res	= MWL.Behavioral.Results;
r	= res.ravens(:,1);

%input data
	strDirDTI	= DirAppend(strDirData,'diffusion');
	strPathReal	= PathUnsplit(strDirDTI,'faz_1','nii.gz');
	strPathWM	= PathUnsplit(strDirDTI,'wm','nii.gz');

%inject signal into the test data
	strPathFake	= PathUnsplit(strDirOut,'faz_1-fake','nii.gz');
	
	nii	= NIfTI.Read(strPathReal);
	
	x	= 40;
	y	= 40;
	z	= 40;
	w	= 10;
	h	= 10;
	
	rm	= repmat(reshape(r,1,1,1,[]),[w h 1 1]);
	rn	= rm.*(1 + 0.5*rand(size(rm)));
	
	nii.data(x+(0:w-1),y+(0:h-1),z,:)	= rn;
	
	NIfTI.Write(nii,strPathFake);

%construct the design matrix
	d	= r;
%t-contrasts
	tContrast	= [1; -1];

%call randomise
	strPathOut	= PathUnsplit(strDirOut,'faz_1_ravens');
	
	strPathMask	= FSLPathMNIAnatomical('type','MNI152_T1_2mm_brain_mask');
	
	[b,strPathOut]	= FSLRandomise(strPathFake,d,...
						'output'			, strPathOut	, ...
						'mask'				, strPathMask	, ...
						'tcontrast'			, tContrast		, ...
						'permutations'		, 500			, ...
						'cores'				, nCore			, ...
						'force'				, true			  ...
						);
