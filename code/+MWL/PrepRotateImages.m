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
	raph	= cellfunprogress(@svg2raphael,cPathSVG,'uni',false);
	nRaph	= numel(raph);
	
	if any(cellfun(@numel,raph)>1)
		error('Some SVG files had more than one path.');
	end

	%convert to normalized array form
		cRaph	= cell(nRaph,1);
		
		for kR=1:nRaph
			strPath	= regexprep(raph{kR}.path,'\\[rnt]','');
			
			sPath	= svgpath2struct(strPath,...
						'allowhv'	, false	, ...
						'fill'		, true	, ...
						'normalize'	, true	  ...
						);
			
			cArrPath	= cellfun(@(c,p) sprintf('[%s]',join([{['''' c '''']};num2cell(p)],',')),{sPath.command},{sPath.param},'uni',false);
			cRaph{kR}	= regexprep(sprintf('[%s]',join(cArrPath,',')),'0\.','.');
		end
	
	%save to a file
		strPaths	= join(cRaph,10);
		
		strPathOut	= PathUnsplit(strDirIm,'raphael','coffee');
		fput(strPaths,strPathOut);
