% generate the constructive imagery parts

PrepCI;

ptb	= CI.Run('debug','debug',2,'input','keyboard');
sca

n	= 100;
s	= 2000;
cIm	= arrayfun(@(k) imresize(1-double(ptb.CI.Stimulus.Segment(k,1,true)),[s s],'nearest'), (1:n)', 'uni',false);

PrepMWL
strDirOut	= DirAppend(strDirCode,'web','mwlearn','mwlearnapp','static','mwlearnapp','images','construct','part');
CreateDirPath(strDirOut);

rot	= [90 180 270 0];
for r=1:numel(rot)
	strDirRot	= DirAppend(strDirOut,num2str(r)-1);
	CreateDirPath(strDirRot);
	
	cPathOut	= arrayfun(@(k) PathUnsplit(strDirRot,sprintf('%03d',k),'png'),(0:n-1)','uni',false);
	
	cImRot	= cellfun(@(im) imrotate(im,-rot(r),'nearest'),cIm,'uni',false);
	
	cellfun(@(im,f) imwrite(im,f,'Alpha',im),cImRot,cPathOut);
end
