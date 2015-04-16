% for some reason, 12nov14jg's rotate trials used t=[1,90] instead of t=[0,1].
% fix this.
strPathMAT	= PathUnsplit(strDirData,'12nov14jg','mat');
strPathOrig	= PathAddSuffix(strPathMAT,'-orig');

FileCopy(strPathMAT,strPathOrig);


PTBIFO		= MATLoad(strPathMAT,'PTBIFO');

aMin	= 1;
aMax	= 90;

p	= PTBIFO.mwlt.angle.psychoCurve;

xStim		= (p.xStim - aMin) ./ (aMax - aMin);
bResponse	= p.bResponse;




a		= MWL.Param('angle','psychocurve','targetFracCorrect');
g		= MWL.Param('angle','psychocurve','baselineFracCorrect');
xstep	= MWL.Param('angle','psychocurve','xstep');
t		= MWL.Param('angle','psychocurve','start_t');

p = PsychoCurve('a', a, 'g', g, 'xstep', xstep, 't', t );

p.xStim		= xStim;
p.bResponse	= bResponse;

p.Fit('robust',false);

PTBIFO.mwlt.angle.psychoCurve	= p;

MATSave(strPathMAT,'PTBIFO',PTBIFO);
