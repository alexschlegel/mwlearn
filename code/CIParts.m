% generate the constructive imagery parts

PrepCI;

n	= 100;
s	= 1000;

% ptb.Window.px2va(1000) == 28.503482774797
sVA	= 28.503482774797

ptb	= CI.Run('debug','debug',2,'input','keyboard','ci_render_size',sVA);
sca

cIm	= arrayfun(@(k) 1-double(ptb.CI.Stimulus.Segment(k,1,true)), (1:n)', 'uni',false);

PrepMWL
strDirOut	= DirAppend(strDirBase,'images','ci');
CreateDirPath(strDirOut);

cPathOut	= arrayfun(@(k) PathUnsplit(strDirOut,sprintf('part_%03d',k),'png'),(0:n-1)','uni',false);

cellfunprogress(@imwrite,cIm,cPathOut);
