function im = Image(a,varargin)
% Assemblage.Image
% 
% Description:	construct the assemblage image
% 
% Syntax:	im = a.Image([s]=<auto>)
% 
% In:
% 	[s]	- the [H W] bounding box for the image
% 
% Updated: 2014-11-12
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
s	= ParseArgs(varargin,[]);

if a.numParts==0
	im	= logical(0);
	return;
end

%construct the assemblage image
	parts	= a.part;
	nPart	= numel(parts);
	
	%the images
		[imPart,thickPart]	= cellfun(@(part) part.Image,parts,'uni',false);
		offsetThick			= thickPart{1};
		sPart				= size(imPart{1});
	%the grid positions
		posPart	= cellfun(@(part) part.param.grid,parts,'uni',false);
	
	%the blank image
		aDim	= a.grid.max - a.grid.min + 1;
		sX		= aDim(1);
		sY		= aDim(2);
		
		sImX	= sPart(1)*sX - offsetThick*(sX-1);
		sImY	= sPart(2)*sY - offsetThick*(sY-1);
		
		im	= false(sImY,sImX);
	
	%fill in the images
		for kP=1:nPart
			pos		= posPart{kP};
			xPart	= (pos(1) - a.grid.min(1)) + 1;
			yPart	= (pos(2) - a.grid.min(2)) + 1;
			
			lIm	= (sPart(1)-offsetThick)*(xPart-1) + 1;
			tIm	= (sPart(2)-offsetThick)*(yPart-1) + 1;
			
			yIm	= tIm + (0:sPart(2)-1);
			xIm	= lIm + (0:sPart(1)-1);
			
			im(yIm,xIm)	= im(yIm,xIm) | imPart{kP};
		end

%colorize
	if isstruct(a.ptb)
		colBack	= a.ptb.Color.Get('background');
	else
		colBack	= [128 128 128];
	end
	colBack	= colBack(1:3);
	colFore	= [0 0 0];
	
	im	= ind2rgb(im+1,[colBack; colFore]);

%now fit within the bounding box
	if ~isempty(s)
		sIm		= size(im);
		scale	= min(s./sIm(1:2));
		im		= imresize(im,scale,'bicubic');
	end
