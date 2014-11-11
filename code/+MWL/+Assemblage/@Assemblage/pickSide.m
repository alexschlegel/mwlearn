function side = pickSide(a,part)
% Assemblage.pickSide
% 
% Description:	pick a side from an existing part
% 
% Syntax:	side = a.pickSide(part)
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
param	= MWL.Assemblage.Param(part);
side	= randFrom(param.connects);
