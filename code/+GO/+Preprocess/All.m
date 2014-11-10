function All(varargin)
% GO.Preprocess.All
% 
% Description:	do all the preliminary preprocessing. mainly here as a record.
% 
% Syntax:	GO.Preprocess.All(<options>)
% 
% In:
% 	<options>:
%		nthread:	(12)
%		force:		(false)
% 
% Updated: 2014-03-06
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

syncmri;

GO.Preprocess.Organize(varargin{:});
GO.Preprocess.Functional(varargin{:});
GO.Preprocess.FreeSurfer(varargin{:});
GO.Preprocess.Masks(varargin{:});
