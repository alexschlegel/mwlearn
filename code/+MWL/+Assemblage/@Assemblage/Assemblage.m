classdef Assemblage < handle
% Assemblage
%
% Description:	object for constructing and rendering assemblage stimuli. this
%				is a port of the coffeescript version.
%
% Syntax: a = Assemblage(ptb,[opt]=struct)
%
%			properties:
%				ptb:
%				opt:
%				element:
%				rotation:
%				history:
%				instruction:
%				grid:
%				existingParts:
%				possibleParts:
%				
%			
%			methods:
%				rotate:	DONE
%				numParts:	DONE
%				numSteps:	DONE
%				part: 	DONE
%				partElementIndex:	DONE
%				addEvent:	DONE
%				addPart:	DONE
%				addSet:	DONE
%				getSet:	DONE
%				addRandom:	DONE
%				naturalName:	DONE
%				getUniqueParts:	DONE
%				getOccupiedPositions:	DONE
%				getAllParts:	DONE
%				findPart:	DONE
%				findOpenConnections:	DONE
%				partCount:	DONE
%				pickPart:	DONE
%				pickSide:	DONE
%				pickAppendage:	DONE
%				findReplacementsGivenParts:	DONE
%				findReplacements:	DONE
%				pickReplacement:	DONE
%				createDistractor:	DONE
%				createDistractors:	DONE
%				ShowInstruction:	***
%				Show:	***
%
% In:
%	ptb		- the PTB object that will show the assemblage
%	[opt]	- a struct of options
%
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		ptb;
		
		opt;
		
		element;
		rotation;
		
		history;
		instruction;
		grid;
		
		existingParts;
		possibleParts;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function a = Assemblage(ptb,varargin)
			a.opt	= ParseArgs(varargin,struct);
			
			a.ptb	= ptb;
			
			parts	= MWL.Assemblage.Parts;
			
			a.opt.imax	= unless(GetFieldPath(a.opt,'imax'),numel(parts));
			
			a.rotation	= 0;
			
			a.element	= {};
			
			a.existingParts	= {};
			a.possibleParts	= parts(1:a.opt.imax);
			
			a.history		= {};
			a.instruction	= {};
			a.grid	= struct(...
				'min'	, [0 0]	, ...
				'max'	, [0 0]	  ...
				);
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
