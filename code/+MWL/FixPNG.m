function FixPNG(strPathPNG)
% FixPNG
% 
% Description:	regularlize a PNG file while preparing the rotate stimuli
% 
% Syntax:	FixPNG(strPathPNG)
% 
% Updated: 2014-10-16
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
s	= 600;

%load
	[im,map,alpha]	= imread(strPathPNG);
%binarize
	if ~isempty(alpha)
		if all(alpha(:)>=128)
			im	= ~all(im==255,3);
		else
			im	= alpha>=128;
		end
	end
%crop the figure
	rp		= regionprops(uint8(im),'Image');
	im		= any(cat(3,rp.Image),3);
	[h,w,c]	= size(im);
%fit within a box
	scale	= s/max(h,w);
	im		= imresize(im,scale,'nearest');
%pad to square
	im	= imPad(im,false,s,s);
%save it
	imwrite(im,strPathPNG);
