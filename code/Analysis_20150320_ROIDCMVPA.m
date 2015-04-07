% Analysis_20150320_ROIDCMVPA.m
% roi directed connectivity classification analysis with the 6 gridop ROIs
nThread	= 12;

dimPCA	= 10;

%create directory for analysis results
	strNameAnalysis	= '20150320_roidcmvpa';
	strDirOut		= DirAppend(strDirAnalysis, strNameAnalysis);
	CreateDirPath(strDirOut);

%get subject info
	ifo			= MWL.GetSubjectInfo;
	cSession	= ifo.code.mri;
	
	s	= GO.BehavioralResults('session',cSession);

%the ROIs
	sMask	= MWL.Masks;
	
	cMask	= sMask.ci;

%classify each scheme
	conf	=	[
					4 2 1 1
					2 4 1 1
					1 1 4 2
					1 1 2 4
				];
	
	cScheme	= fieldnames(s.attr.roi.target);
	nScheme	= numel(cScheme);
	
	for kS=1:nScheme
		strScheme	= cScheme{kS};
		
		%current output directory
			strDirOutScheme	= DirAppend(strDirOut,strScheme);
		
		%targets and chunks
			cTarget	= s.attr.dc.target.(strScheme).all;
			
			durRun	= GO.Param('trrun');
			nRun	= cellfun(@(c) numel(c)/durRun,kChunk,'uni',false);
			kChunk	= cellfun(@(n) reshape(repmat(1:n,[durRun 1]),[],1),nRun,'uni',false);
		
		%ROI directed connectivity classification!
			res	= MVPAROIDCClassify(...
				'dir_out'			, strDirOutScheme	, ...
				'dir_data'			, strDirData		, ...
				'subject'			, cSession			, ...
				'mask'				, cMask				, ...
				'dim'				, dimPCA			, ...
				'targets'			, cTarget			, ...
				'chunks'			, kChunk			, ...
				'target_blank'		, 'Blank'			, ...
				'confusion_model'	, conf				, ...
				'debug'				, 'all'				, ...
				'debug_multitask'	, 'info'			, ...
				'nthread'			, nThread			, ...
				'force'				, false				  ...
				);
	end

%save the results
	strPathOut	= PathUnsplit(strDirOut,'result','mat');    
	save(strPathOut,'res');
