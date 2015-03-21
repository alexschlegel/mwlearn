function s = ComputerResults(varargin)
% MWL.Behavioral.ComputerResults
%
% Description:	load computer-based behavioral results 
%
% Syntax:	s = MWL.Behavioral.ComputerResults(<options>);
%
% In: 
%   <options>:
%       session:	(<all>) a cell of session codes
%		force:		(false) true to force recalculation of previously-calculated
%					results
%
% Out:
%   s	- a struct of computer-based behavioral results
%                       
% Notes: 
%   -For alex tests (ci, angle, assemblage) this function returns the
%   difficulty (1-t from psychoCurve). For the sentence span task it
%   returns percent correct on letter-memory. For spatial short term 
%   memory, it returns 'fracScore', the percentage of dot locations 
%   remembered correctly.
%   
%   -Missing sessions are given a score of NaN 
%
% Updated: 2015-03-20
% Copyright 2015 Kevin Hartstein.  This work is licensed under a Creative
% Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
global strDirAnalysis;

%parse the inputs
	opt	= ParseArgs(varargin,...
			'session'	, []	, ...
			'force'	, false		  ...
			);
	
	if isempty(opt.session)
		ifo			= MWL.GetSubjectInfo;
		cSession	= ifo.code.behavioral;
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
		
		[cResultNew,bError]	= cellfunprogress(@LoadResult,cSessionNew,...
								'label'	, 'loading computer-based behavioral results'	, ...
								'uni'	, false											  ...
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
function [sResult,bError] = LoadResult(strSession)
	global strDirData
	
	warning('off','MATLAB:indeterminateFields');
	
	bError	= false;
	
	strPathMAT	= PathUnsplit(strDirData,strSession,'mat');
	if FileExists(strPathMAT)
		res	= load(strPathMAT);
		
		sResult	= struct(...
					'construct'		, GetConstructScore(res)	, ...
					'rotate'		, GetRotateScore(res)		, ...
					'assemblage'	, GetAssemblageScore(res)	, ...
					'wm_verbal'		, GetWMVerbalScore(res)		, ...
					'wm_spatial'	, GetWMSpatialScore(res)	  ...
					);
	else
		bError	= true;
		
		if ~isempty(strSession)
			warning('%s does not exist.',strPathMAT);
		end
		
		sResult	= dealstruct('construct','rotate','assemblage','wm_verbal','wm_spatial',NaN);
	end
end
%------------------------------------------------------------------------------%
function [constructScore] = GetConstructScore(res)  
	constructScore	= 1 - res.PTBIFO.mwlt.ci.psychoCurve.t;
end
%------------------------------------------------------------------------------%
function [rotateScore] = GetRotateScore(res)
	rotateScore	= 1 - res.PTBIFO.mwlt.angle.psychoCurve.t;
end
%------------------------------------------------------------------------------%
function [assemblageScore] = GetAssemblageScore(res)
	assemblageScore	= 1 - res.PTBIFO.mwlt.assemblage.psychoCurve.t;
end
%------------------------------------------------------------------------------%
function [wm_verbalScore] = GetWMVerbalScore(res)
	bTrial			= [res.PTBIFO.mwlt.wm.ss.trial];
	cLetterCorrect	= {bTrial.bLetterCorrect};
	bPercentCorrect	= cellfun(@mean, cLetterCorrect);
	wm_verbalScore	= mean(bPercentCorrect);    
end
%------------------------------------------------------------------------------%
function [wm_spatialScore] = GetWMSpatialScore(res)
	wm_spatialScore	= res.PTBIFO.mwlt.wm.sstm.fracScore;
end
%------------------------------------------------------------------------------%

end
