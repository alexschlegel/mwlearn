function param = Param(varargin)
% Assemblage.Param
% 
% Description:	get part parameters
% 
% Syntax:	param = Assemblage.Param([part]=<all>)
% 
% In:
% 	[part]	- name of the part for which to retrieve parameters
% 
% Out:
% 	param	- a struct of parameters for the part
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent partName paramAll;

if isempty(paramAll)
	paramAll	= {};
	
	addPart('square',struct('symmetry','90'));
	addPart('circle',struct('symmetry','90'));
	addPart('triangle',struct('symmetry','vertical','connects',[1 3]));
	addPart('diamond',struct('symmetry','90'));
	addPart('line',struct('symmetry','180','connects',[1 3]));
	addPart('cross',struct('symmetry','90'));
end

part	= ParseArgs(varargin,NaN);

if isequalwithequalnans(part,NaN)
	param	= paramAll;
else
	kPart	= find(strcmp(partName,part),1);
	param	= paramAll{kPart};
end


%------------------------------------------------------------------------------%
function addPart(name,varargin)
	opt	= ParseArgs(varargin,struct);
	
	opt.name		= name;
	opt.connects	= unless(GetFieldPath(opt,'connects'),[0 1 2 3]);
	opt.symmetry	= unless(GetFieldPath(opt,'symmetry'),'none');
	
	paramAll{end+1}	= opt;
	partName{end+1}	= name;
end
%------------------------------------------------------------------------------%

end
