function All(varargin)
% MWL.Preprocess.All
% 
% Description:	do all the preliminary preprocessing. mainly here as a record.
% 
% Syntax:	MWL.Preprocess.All(<options>)
% 
% In:
% 	<options>:
%		nthread:	(12)
%		force:		(false)
% 
% Updated: 2015-04-30
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

syncmri;

MWL.SyncData;

MWL.Preprocess.Organize(varargin{:});
MWL.Preprocess.Functional(varargin{:});
MWL.Preprocess.FreeSurfer(varargin{:});
MWL.Preprocess.Masks(varargin{:});
MWL.Preprocess.DTI(varargin{:});

MWL.Preprocess.Univariate(varargin{:});
