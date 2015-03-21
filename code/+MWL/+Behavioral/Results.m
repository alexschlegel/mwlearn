function s = Results(varargin)
% MWL.Behavioral.Results
%
% Description:	load paper-based behavioral results 
%
% Syntax:	s = MWL.Behavioral.Results(<options>);
%
% In: 
%   <options>:
%       session:	(<all>) a cell of session codes
%		force:		(false) true to force recalculation of previously-calculated
%					results
%
% Out:
%   s	- a struct of paper-based behavioral results
% 
% Updated: 2015-03-20
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	ifo	= MWL.GetSubjectInfo;
	
	opt	= ParseArgs(varargin,...
			'session'	, []	, ...
			'force'		, false	  ...
			);
	
	if isempty(opt.session)
		cSession	= ifo.code.behavioral;
	else
		cSession	= opt.session;
	end

%load the results
	sComputer	= MWL.Behavioral.ComputerResults(...
					'session'	, cSession	, ...
					'force'		, opt.force	  ...
					);
	
	sPaper		= MWL.Behavioral.PaperResults(...
					'session'	, cSession	, ...
					'ifo'		, ifo		  ...
					);

%merge them
	s	= StructMerge(sComputer,sPaper);

