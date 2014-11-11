classdef AssemblagePart < handle
% AssemblagePart
%
% Description:	object for constructing and rendering assemblage part stimuli.
%				this is a port of the coffeescript version.
%
% Syntax: part = AssemblagePart(ptb,name,[opt]=struct)
%
%			properties:
%				ptb:
%				param:
%				assemblage:
%				part:
%			
%			methods:
%				rotate:	DONE
%				side2direction:	DONE
%				naturalLocation:	DONE
%				naturalRelativeLocation:	DONE
%				naturalOrientation:	DONE
%				naturalName:	DONE
%				naturalDefinition:	DONE
%				Show:	***
%
% In:
%	ptb		- the PTB object that will show the assemblage part
%	[opt]	- a struct of options
%
% Out: 
%
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		ptb;
		
		param;
		assemblage;
		part;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function part = AssemblagePart(ptb,name,varargin)
			opt	= ParseArgs(varargin,struct);
			
			part.ptb	= ptb;
			
			part.part			= name;
			
			part.param	= StructMerge(MWL.Assemblage.Param(part.part),struct(...
				'idx'			, NaN				, ...
				'grid'			, [0 0]				, ...
				'orientation'	, 0					, ...
				'parent'		, NaN				, ...
				'attachment'	, [NaN NaN NaN NaN]	  ...
			));
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
