function s = BehavioralResults(varargin)
% GO.BehavioralResults
% 
% Description:	load the behavioral results for a set of subjects
% 
% Syntax:	s = GO.BehavioralResults(<options>)
% 
% In:
%	<options>:
%		session:	(<all>) a cell of session codes
%		force:		(false) true to force recalculation of previously-calculated
%					result
% 
% Out:
% 	s	- a struct of behavioral results
% 
% Updated: 2015-03-20
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirAnalysis;

%parse the inputs
	opt	= ParseArgs(varargin,...
			'session'	, []	, ...
			'force'	, false		  ...
			);
	
	if isempty(opt.session)
		ifo			= MWL.GetSubjectInfo;
		cSession	= ifo.code.mri;
	else
		cSession	= opt.session;
	end
	cResult	= cell(size(cSession));

%load existing results
	strPathMe		= mfilename('fullpath');
	strPathStore	= PathAddSuffix(strDirAnalysis,sprintf('%s-store',PathGetFilePre(strPathMe)),'mat');
	if ~opt.force && FileExists(strPathStore)
		sStore	= getfield(load(strPathStore),'sStore');
	else
		sStore	= dealstruct('code','result',{});
	end

%copy the previously-constructed results
	[bStore,kStore]	= ismembercellstr(cSession,sStore.code);
	cResult(bStore)	= sStore.result(kStore(bStore));

%construct the new ones
	bNew	= ~bStore;
	if any(bNew)
		cSessionNew	= cSession(bNew);
		
		[cResultNew,bError]	= cellfunprogress(@LoadResults,cSessionNew,...
								'label'	, 'loading gridop behavioral results'	, ...
								'uni'	, false									  ...
								);
		bError				= cell2mat(bError);
		cResult(bNew)		= cResultNew;
		
		%save the results
			bSave			= ~bError;
			sStore.code		= [sStore.code; reshape(cSessionNew(bSave),[],1)];
			sStore.result	= [sStore.result; reshape(cResultNew(bSave),[],1)];
			
			save(strPathStore,'sStore');
	end

%restructure the results
	s	= restruct(cell2mat(cResult));

%------------------------------------------------------------------------------%
function [sResult,bError] = LoadResults(strSession)
	global strDirData 
	
	bError	= false;
	
	strPathMAT	= PathUnsplit(strDirData,strSession,'mat');
	if FileExists(strPathMAT)
		s	= load(strPathMAT);
		
		GOParam	= GO.Param;
		
		%trial parameters and result
			map		= struct(...
						'shape'		, s.PTBIFO.subject.map_stim	, ...
						'operation'	, s.PTBIFO.subject.map_op	  ...
						);
			cField	=	{
							'shape'		'input'
							'operation'	'operation'
							'correct'	'correct'
						};
			nField	= size(cField,1);
			
			bRan	= cellfun(@isstruct,s.PTBIFO.go.result);
			sRes	= s.PTBIFO.go.result(bRan);
			
			sBlock	= struct;
			for kF=1:nField
				strFieldIn	= cField{kF,2};
				strFieldOut	= cField{kF,1};
				
				x	= cellfun(@(res) [res.(strFieldIn)], sRes,'uni',false);
				x	= cat(1,x{:});
				
				if isfield(map,strFieldOut)
					x	= map.(strFieldOut)(x);
				end
				
				sBlock.(strFieldOut)	= x;
			end
		
		%response time
			x			= cellfun(@(res) {res.tresponse},sRes,'uni',false);
			x			= cellfun(@(cx) cellfun(@(x) unless(x,{NaN}),cx,'uni',false),x,'uni',false);
			tResponse	= cellfun(@(cx) cellfun(@(x) x{end},cx),x,'uni',false);
			tResponse	= cat(1,tResponse{:});
			
			tTest	= GOParam.time.prompt + GOParam.time.operation;
			TR		= GOParam.time.tr;
			
			sBlock.rt	= TR*(tResponse - tTest);
		
		%attributes
			sAnalysis	= struct(...
							'roi'	, struct('HRF',1,'BlockOffset',0,'BlockSub',3)	, ...
							'dc'	, struct('HRF',1,'BlockOffset',0,'BlockSub',5)	  ...
							);
			cAnalysis	= fieldnames(sAnalysis);
			nAnalysis	= numel(cAnalysis);
			
			sScheme	= struct(...
						'shape'		, {{'R1';'R2';'P1';'P2'}}	, ...
						'operation'	, {{'CW';'CCW';'H';'V'}}	  ...
						);
			cScheme		= fieldnames(sScheme);
			nScheme		= numel(cScheme);
			
			durBlock	= GOParam.trtrial;
			durRest		= GOParam.trrest;
			durPre		= GOParam.trrestpre - durRest;
			durPost		= GOParam.trrestpost - durRest;
			durRun		= GOParam.trrun;
			
			sAttr	= struct;
			for kA=1:nAnalysis
				strAnalysis	= cAnalysis{kA};
				sParam		= sAnalysis.(strAnalysis);
				
				for kS=1:nScheme
					strScheme	= cScheme{kS};
					
					nRun			= size(sBlock.(strScheme),1);
					
					cCondition		= sScheme.(strScheme);
					nCondition		= numel(cCondition);
					cConditionCI	= [repmat({'Blank'},[nCondition 1]); cCondition];
				
					%all
						[cTarget,cEvent]	= deal(cell(nRun,1));
						for kR=1:nRun
							block		= sBlock.(strScheme)(kR,:);
							cTarget{kR}	= block2target(block,durBlock,durRest,cCondition,durPre,durPost,...
											'hrf'			, sParam.HRF			, ...
											'block_offset'	, sParam.BlockOffset	, ...
											'block_sub'		, sParam.BlockSub		  ...
											);
							
							if kS==1
								cEvent{kR}	= block2event(block,durBlock,durRest,durPre,durPost);
							end
						end
						
						sAttr.(strAnalysis).target.(strScheme).all	= cat(1,cTarget{:});
						
						if kS==1
							event		= eventcat(cEvent,durRun);
							nEvent		= size(event,1);
							durRunTotal	= durRun*nRun;
							
							event(:,1)	= 1:nEvent;
							event(:,2)	= event(:,2) + sParam.HRF + sParam.BlockOffset;
							event(:,3)	= sParam.BlockSub;
							ev			= event2ev(event,durRunTotal);
							
							sAttr.(strAnalysis).chunk.all	= sum(ev.*repmat(1:nEvent,[durRunTotal 1]),2);
						end
						
					%just correct
						[cTarget,cEvent]	= deal(cell(nRun,1));
						for kR=1:nRun
							block		= sBlock.(strScheme)(kR,:);
							correct		= sBlock.correct(kR,:);
							blockCI		= block + nCondition*correct;
							
							cTarget{kR}	= block2target(blockCI,durBlock,durRest,cConditionCI,durPre,durPost,...
											'hrf'			, sParam.HRF			, ...
											'block_offset'	, sParam.BlockOffset	, ...
											'block_sub'		, sParam.BlockSub		  ...
											);
							
							if kS==1
								cEvent{kR}	= block2event(blockCI,durBlock,durRest,durPre,durPost);
							end
						end
						
						sAttr.(strAnalysis).target.(strScheme).correct	= cat(1,cTarget{:});
						
						if kS==1
							event							= eventcat(cEvent,durRun);
							event(event(:,1)<=nCondition,:)	= [];
							
							nEvent		= size(event,1);
							durRunTotal	= durRun*nRun;
							
							event(:,1)	= 1:nEvent;
							event(:,2)	= event(:,2) + sParam.HRF + sParam.BlockOffset;
							event(:,3)	= sParam.BlockSub;
							ev			= event2ev(event,durRunTotal);
							
							sAttr.(strAnalysis).chunk.correct	= sum(ev.*repmat(1:nEvent,[durRunTotal 1]),2);
						end
					end
			end
		
		sResult	= struct(...
					'block'	, sBlock	, ...
					'attr'	, sAttr		  ...
					);
	else
		bError	= true;
		sResult	= struct(...
					'block'	, dealstruct('shape','operation','correct','rt',[])	, ...
					'attr'	, dealstruct('roi','dc',struct(...
								'target'	, dealstruct('shape','operation',dealstruct('all','correct',[]))	, ...
								'chunk'		, dealstruct('all','correct',[])									  ...
								))	  ...
					);
	end
%------------------------------------------------------------------------------%
