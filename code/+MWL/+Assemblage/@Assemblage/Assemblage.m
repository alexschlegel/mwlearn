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
%				rotate:	
%				numParts:	
%				numSteps:	
%				part: 	
%				partElementIndex:	
%				addEvent:	
%				addPart:	
%				addSet:	
%				getSet:	
%				addRandom:	
%				naturalName:	
%				getUniqueParts:	
%				getOccupiedPositions:	
%				getAllParts:	
%				findPart:	
%				findOpenConnections:	
%				partCount:	
%				pickPart:	
%				pickSide:	
%				pickAppendage:	
%				findReplacementsGivenParts:	
%				findReplacements:	
%				pickReplacement:	
%				createDistractor:	
%				createDistractors:
%				getSteps:	
%				setSteps:	
%				getPartLocations:	
%				Image:	
%				ShowInstruction:	
%				Show:	
%
% In:
%	ptb		- the PTB object that will show the assemblage
%	[opt]	- a struct of options
%
% Updated: 2014-11-12
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
			
			a.possibleParts	= parts(1:a.opt.imax);
			
			a.reset;
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
