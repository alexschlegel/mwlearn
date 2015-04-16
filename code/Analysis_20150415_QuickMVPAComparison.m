% Analysis_20150415_QuickMVPAComparison.m
% quick comparison of MVPA results between groups
load('/home/alex/studies/mwlearn/analysis/20150320_roimvpa/result.mat');

ifo	= MWL.GetSubjectInfo;
g	= ifo.group==1;

z	= reshape(res.shape.result.allway.stats.confusion.corr.z,6,40,2);
zd	= z(:,:,2) - z(:,:,1);

zdExp	= zd(:,g);
zdCon	= zd(:,~g);

[h,p,ci,stats]	= ttest2(zdExp,zdCon,'dim',2);

%nope

sResult	= MWL.Behavioral.Results('ifo',ifo);
mb		= structfun2(@(x) nanmean(x,2),sResult);

%z	= nanmean(reshape(res.shape.result.allway.stats.confusion.corr.z,6,40,2),3);
%z	= nanmean(reshape(res.operation.result.allway.stats.confusion.corr.z,6,40,2),3);
%z	= nanmean(reshape(res.shape.result.allway.accuracy.mean,6,40,2),3);
%z	= nanmean(reshape(res.operation.result.allway.accuracy.mean,6,40,2),3);

[r,stat]	= structfun2(@(x) corrcoef2(x,z),mb);
