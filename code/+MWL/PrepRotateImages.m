function PrepRotateImages()
% PrepRotateImages
% 
% Description:	prepare .png and Raphael versions of the rotate images
% 
% Syntax:	MWL.PrepRotateImages()
% 
% Updated: 2014-10-16
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global strDirBase

strDirIm	= DirAppend(strDirBase,'images','rotate');
strDirSVG	= DirAppend(strDirIm,'svg');
strDirPNG	= DirAppend(strDirIm,'png');

CreateDirPath(strDirPNG);

cPathSVG	= FindFilesByExtension(strDirSVG,'svg');
cPathPNG	= cellfun(@(f) PathUnsplit(strDirPNG,PathGetFilePre(f),'png'),cPathSVG,'uni',false);

%convert to png
	%copy the svg files
		cPathSVGTemp	= cellfun(@(f) PathAddSuffix(f,'','svg'),cPathPNG,'uni',false);
		b				= cellfun(@FileCopy,cPathSVG,cPathSVGTemp);
	%convert to huge png
		[ec,cOut]	= CallProcess('svg2png',{'-d',1200,cPathSVGTemp});
	%delete the SVGs
		cellfun(@delete,cPathSVGTemp);
	
	%process the png
		cellfunprogress(@MWL.FixPNG,cPathPNG);

%convert to Raphael
	strDirJS	= DirAppend(strDirIm,'js');
	
	CreateDirPath(strDirJS);
	
	strPathRappar	= PathUnsplit(DirAppend(strDirCode,'rappar'),'rappar','js');
	[ec,cOut]		= CallProcess('node',{strPathRappar,cPathSVG});
	