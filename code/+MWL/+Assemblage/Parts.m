function parts = Parts()
% Assemblage.Parts
% 
% Description:	get a cell of assemblage part names
% 
% Syntax:	parts = Assemblage.Parts()
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
parts	= cellfun(@(part) part.name, MWL.Assemblage.Param,'uni',false);
