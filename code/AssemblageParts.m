PrepMWL

s		= 100;
sBase	= 800;

strDirIn	= DirAppend(strDirBase,'images','assemblage');
strDirOut	= DirAppend(strDirCode,'web','mwlearn','mwlearnapp','static','mwlearnapp','images','assemblage');

CreateDirPath(strDirOut);

cPathIn		= FindFilesByExtension(strDirIn,'png');
cPathOut	= cellfun(@(f) PathUnsplit(strDirOut,PathGetFileName(f)),cPathIn,'uni',false);
nIm			= numel(cPathIn);

for kI=1:nIm
	[im,map,alpha]	= imread(cPathIn{kI});
	sOld			= size(im,1);
	sNew			= round(sOld*s/sBase);
	%im	= imresize(im,[s s],'nearest');
	im	= uint8(255*ones(sNew,sNew,3));
	alpha	= 255 - imresize(alpha,[sNew sNew],'nearest');
	
	imwrite(im,cPathOut{kI},'Alpha',alpha);
end
