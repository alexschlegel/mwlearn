function sIm = PartImages()
% MWL.Assemblage.PartImages
% 
% Description:	return a struct of the part images
% 
% Syntax:	sIm = MWL.Assemblage.PartImages()
% 
% Updated: 2014-11-12
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirBase;
persistent s;

if isempty(s)
	parts	= MWL.Assemblage.Parts;
	nPart	= numel(parts);
	
	strDirIm	= DirAppend(strDirBase,'images','assemblage');
	
	s	= struct;
	for kP=1:nPart
		part	= parts{kP};
		
		strPathIm	= PathUnsplit(strDirIm,part,'png');
		
		[im,map,alpha]	= imread(strPathIm);
		
		s.(part)	= logical(imresize(alpha,[300 300],'nearest'));
	end
end

sIm	= s;
