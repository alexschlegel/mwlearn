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
			nRun	= cellfun(@(c) numel(c)/durRun,cTarget,'uni',false);
			kChunk	= cellfun(@(n) reshape(repmat(1:n,[durRun 1]),[],1),nRun,'uni',false);
		
		%ROI directed connectivity classification!
			res.(strScheme)	= MVPAROIDCClassify(...
								'dir_out'			, strDirOutScheme	, ...
								'dir_data'			, strDirData		, ...
								'subject'			, cSession			, ...
								'mask'				, cMask				, ...
								'dim'				, dimPCA			, ...
								'targets'			, cTarget			, ...
								'chunks'			, kChunk			, ...
								'target_blank'		, 'Blank'			, ...
								'confusion_model'	, conf				, ...
								'confcorr_method'	, 'subject'			, ...
								'debug'				, 'all'				, ...
								'debug_multitask'	, 'info'			, ...
								'nthread'			, nThread			, ...
								'force'				, false				  ...
								);
	end

%save the results
	strPathOut	= PathUnsplit(strDirOut,'result','mat');    
	save(strPathOut,'res');

%figures
	if false
		cMaskLabel		= upper(cMask);
		
		colMask	=	[
					0	222	222	%dlpfc
					224	0	224	%fef
					0	160	0	%ppc
					224	144	0	%pcu
					64	96	255	%loc
					255	0	0	%occ
				]/255;
		
		conn		= structfun2(@(s) squareform2(s.result.allway.stats.confusion.corr.mz),res);
		pConn		= structfun2(@(s) squareform2(s.result.allway.stats.confusion.corr.p),res);
		pFDRConn	= structfun2(@(s) squareform2(s.result.allway.stats.confusion.corr.pfdr),res);
		
		cLabel		= cMaskLabel;
		[b,kOrder]	= ismember(cLabel,cMaskLabel);
		colLabel	= colMask(kOrder,:);
		
		col	= GetPlotColors(2);
		
		for kS=1:nScheme
			strScheme	= cScheme{kS};
			
			C		= ReorderConfusion(conn.(strScheme),cMaskLabel,cLabel);
			p		= ReorderConfusion(pConn.(strScheme),cMaskLabel,cLabel);
			pfdr	= ReorderConfusion(pFDRConn.(strScheme),cMaskLabel,cLabel);
			
			%hierarchical network plot
				%get the line width bounds
					zAll	= reshape(structtree2array(structfun2(@(s) s.result.allway.stats.confusion.corr.mz,res)),[],1);
					pAll	= reshape(structtree2array(structfun2(@(s) s.result.allway.stats.confusion.corr.p,res)),[],1);
					
					bShow	= pfdr<=0.05;
					bSize	= pAll<=0.05;
					
					zSize	= zAll(bSize);
					zMin	= min(zSize);
					zMax	= max(zSize);
					
					tLineMin	= 1;
					tLineMax	= 8;
				
				x			= C;
				x(~bShow)	= 0;
				x(isnan(x))	= 0;
				
				b		= biograph(x,cLabel);
				
				n		= b.Nodes;
				nNode	= numel(n);
				for kN=1:nNode
					n(kN).Color		= colMask(kN,:);
					n(kN).LineColor	= colMask(kN,:);
					n(kN).TextColor	= GetGoodTextColor(n(kN).Color);
				end
				
				e		= b.Edges;
				nEdge	= numel(e);
				for kE=1:nEdge
					sNode	= regexp(e(kE).ID,'(?<src>.+) -> (?<dst>.+)','names');
					kSrc	= find(strcmp(cMask,sNode.src));
					kDst	= find(strcmp(cMask,sNode.dst));
					
					e(kE).LineWidth	= MapValue(e(kE).Weight,zMin,zMax,tLineMin,tLineMax);
					e(kE).LineColor	= col(kS,:);
				end
				
				[kSupraR,kSupraC]	= find(p<=0.05 & pfdr>0.05);
				nSupra				= numel(kSupraR);
				disp(sprintf('%s pfdr>0.05:',strScheme));
				for kU=1:nSupra
					kR	= kSupraR(kU);
					kC	= kSupraC(kU);
					disp(sprintf('\t%s to %s: t=%f',cLabel{kR},cLabel{kC},MapValue(C(kR,kC),zMin,zMax,tLineMin,tLineMax)));
				end
				
				g	= biograph.bggui(b);
				f	= get(g.biograph.hgAxes,'Parent');
				
				strPathOut	= PathUnsplit(strDirOut,['gcnetwork-' strScheme],'png');
				saveas(f,PathAddSuffix(strPathOut,'','eps'));
				fig2png(f,strPathOut);
		end
	end