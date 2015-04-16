function [s,param] = Results(varargin)
% MWL.Behavioral.Results
%
% Description:	load paper-based behavioral results 
%
% Syntax:	[s,param] = MWL.Behavioral.Results(<options>);
%
% In: 
%   <options>:
%       session:	(<all>) a cell of session codes
%		robust:		([]) see MWL.Behavioral.ComputerResults
%		force:		(false) true to force recalculation of previously-calculated
%					results
%
% Out:
%   s		- a struct of paper-based behavioral results
%	param	- some extra parameters
% 
% Updated: 2015-04-16
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	ifo	= MWL.GetSubjectInfo;
	
	opt	= ParseArgs(varargin,...
			'session'	, []	, ...
			'robust'	, []	, ...
			'force'		, false	  ...
			);
	
	if isempty(opt.session)
		cSession	= ifo.code.behavioral;
	else
		cSession	= opt.session;
	end

%load the results
	sComputer	= MWL.Behavioral.ComputerResults(...
					'session'	, cSession		, ...
					'robust'	, opt.robust	, ...
					'force'		, opt.force		  ...
					);
	
	sPaper		= MWL.Behavioral.PaperResults(...
					'session'	, cSession	, ...
					'ifo'		, ifo		  ...
					);

%merge them
	s	= StructMerge(sComputer,sPaper);

%keep a record of the subject sessions and ids
	param.session	= cSession;
	
	[t,param.id]	= cellfun(@ParseSessionCode,cSession,'uni',false);
	
	param.id	= mat2cell(param.id,ones(size(param.id,1),1),size(param.id,2));
	param.id	= cellfun(@(id) id{find(~cellfun(@isempty,id),1)},param.id,'uni',false);
