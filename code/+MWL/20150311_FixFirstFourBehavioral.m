%fix the behavioral results for the first four subjects, who had to come back
%and redo the assemblage task
strDirPre	= DirAppend(strDirData,'orig');

cSessionFirst	=	{
						'12nov14jg'
						'13nov14kh'
						'14nov14ph'
						'15nov14sg'
					};

cSessionSecond	=	{
						'17nov14jg'
						'16nov14kh'
						'16nov14ph'
						'16nov14sg'
					};
nSession		= numel(cSessionFirst);

for kS=1:nSession
	strPathFirst	= PathUnsplit(strDirPre,cSessionFirst{kS},'mat');
	strPathSecond	= PathUnsplit(strDirPre,cSessionSecond{kS},'mat');
	strPathOut		= PathUnsplit(strDirData,cSessionFirst{kS},'mat');
	
	d1	= load(strPathFirst);
	d2	= load(strPathSecond);
	
	PTBIFO					= d1.PTBIFO;
	PTBIFO.mwlt.assemblage	= d2.PTBIFO.mwlt.assemblage;
	
	save(strPathOut,'PTBIFO');
	
% 	disp(sprintf('%s: %d',strPathFirst,FileSize(strPathFirst)));
% 	disp(sprintf('%s: %d',strPathSecond,FileSize(strPathSecond)));
% 	disp(sprintf('%s: %d',strPathOut,FileSize(strPathOut)));
% 	disp('');
end
