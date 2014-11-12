function [im,thickness] = Image(part)
% AssemblagePart.Image
% 
% Description:	get the image for the part, in its current orientation
% 
% Syntax:	[im,thickness] = part.Image()
% 
% Updated: 2014-11-12
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%unrotated image
	s	= MWL.Assemblage.PartImages;
	im	= s.(part.part);

%rotate
	im	= imrotate(im,-90*part.param.orientation,'nearest');

thickness	= size(im,1)/10;
