  function Run(mwlt)
% MWLearnTest.RunCI
%
% Description: do a constructive imagery run
%
% Syntax: MWL.CI.Run(mwlt)

mwlt.Experiment.Input.Set('response',{'left','right','up','down'});

ShowInstructions(mwlt);

% practice trials
numPractice = MWL.Param('ci','numPractice');
dLevelPractice = MWL.Param('ci','dLevelPractice');
if numPractice > 0
    mwlt.Experiment.Show.Instructions(['You will now have ' num2str(numPractice) ...
        ' practice trial' plural(numPractice, '', 's') '.']);
    for nPractice = 1:numPractice
        MWL.CI.RunOne(mwlt, dLevelPractice, 'practice');
    end
end

mwlt.Experiment.Show.Instructions('The experiment will now begin.');

% PsychoCurve parameters
a = MWL.Param('ci','psychocurve','targetFracCorrect');
g = MWL.Param('ci','psychocurve','baselineFracCorrect');
xstep = MWL.Param('ci','psychocurve','xstep');
t = MWL.Param('ci','psychocurve','start_t');
% since RunOne interprets x=1 as hardest and x=0 as easiest, must pass 1-x.
fNext = @(x) MWL.CI.RunOne(mwlt,1-x);
  
p = PsychoCurve('F',fNext, 'a', a, 'g', g, 'xstep', xstep, 't', t);

numTrial = MWL.Param('ci','numTrial');
p.Run('itmin',numTrial, 'itmax',numTrial, 'silent', true);

mwlt.Experiment.Info.Set('mwlt',{'ci','psychoCurve'},p);
end

%---------------Instruction sequence adapted from CI.Program.Train3.m--------

function ShowInstructions(mwlt)
iFigures = MWL.Param('ci','example');
[parts, figures] = arrayfun(@(f) MWL.CI.GetImages(mwlt, iFigures(:,f)), (1:4)','uni',false);
sF = 7;
sS = 16;
sFPx = mwlt.Experiment.Window.va2px(sF);
sSPx = mwlt.Experiment.Window.va2px(sS);
[~,sWPx,~,sW] = mwlt.Experiment.Window.Get('main');

%introduce the experiment
str	= 'In this test you will mentally construct figures from their parts.';
fig = Figure_Example(parts{1}, figures{1});
mwlt.Experiment.Show.Instructions(str,'figure',fig);
   mwlt.Experiment.Window.CloseTexture(fig);

%describe constructing
str	= 'Assemble the parts starting with\nthe upper right and going clockwise.';
fig	= Figure_Construct(parts{1}, figures{1});
mwlt.Experiment.Show.Instructions(str,'figure',fig);
 mwlt.Experiment.Window.CloseTexture(fig);

%describe the test
tTest		= MWL.Param('ci','time','test')/1000;
strPlural	= plural(tTest,'','s');
str	= ['A few seconds after the parts disappear, you will see four test figures. Press the button corresponding to your figure.\n\nYou will have ' num2str(tTest) ' second' strPlural ' to respond. Only your last response is recorded.'];
fig	= Figure_Test(figures);
mwlt.Experiment.Show.Instructions(str,'figure',fig);
mwlt.Experiment.Window.CloseTexture(fig);

    function fig = Figure_Example(part, figure)
        % construct an example figure for the instructions.
        fig	= 'ci_figure_example';
        hT = mwlt.Experiment.Window.OpenTexture(fig, [sWPx(1) 2*sFPx]);
        
        mwlt.Experiment.Show.Image(part,[0 -3*sF/4],sS,'window',hT);
        mwlt.Experiment.Show.Arrow('marigold',[0 -4],[0 -1],[],0,1,'window',hT);
        mwlt.Experiment.Show.Image(figure,[0 sF/2],sF,'window',hT);       
    end

    function fig = Figure_Construct(part, figure)
        fig	= 'ci_figure_construct';	
        hT	= mwlt.Experiment.Window.OpenTexture(fig,[sWPx(1) 2*sFPx]);
        
        yS	= -3*sF/4;
        
        mwlt.Experiment.Show.Image(part,[0 yS],sS,'window',hT);
        mwlt.Experiment.Show.Arrow('marigold',[0 -4],[0 -1],[],0,1,'window',hT);
        mwlt.Experiment.Show.Image(figure,[0 sF/2],sF,'window',hT);
        
        mwlt.Experiment.Show.Text('<color:marigold>1</color>',[-sF-sF/8 yS+3*sF/16],'window',hT);
        mwlt.Experiment.Show.Text('<color:marigold>2</color>',[-sF/2 yS-sF/8],'window',hT);
        mwlt.Experiment.Show.Text('<color:marigold>3</color>',[sF/2 yS-sF/8],'window',hT);
        mwlt.Experiment.Show.Text('<color:marigold>4</color>',[sF+sF/8 yS+3*sF/16],'window',hT);
        
        mwlt.Experiment.Show.Line('marigold',[0 0],[0 sF],'window',hT);
        mwlt.Experiment.Show.Line('marigold',[-sF/2 sF/2],[sF/2 sF/2],'window',hT);
        mwlt.Experiment.Show.Text('<color:marigold>1</color>',[sF/16 sF/2-sF/16],'window',hT);
        mwlt.Experiment.Show.Text('<color:marigold>2</color>',[sF/16 sF/2+sF/8],'window',hT);
        mwlt.Experiment.Show.Text('<color:marigold>3</color>',[-sF/16 sF/2+sF/8],'window',hT);
        mwlt.Experiment.Show.Text('<color:marigold>4</color>',[-sF/16 sF/2-sF/16],'window',hT);
    end

    function fig = Figure_Test(figures)
        fig	= 'ci_figure_test';
        
        hT	= mwlt.Experiment.Window.OpenTexture(fig,[sWPx(1) 2*sFPx]);
        
        mwlt.Experiment.Show.Image(figures{1},[-sF/1.8 0],sF/1.5,'window',hT);
        mwlt.Experiment.Show.Image(figures{2},[sF/1.8 0],sF/1.5,'window',hT);
        mwlt.Experiment.Show.Image(figures{3},[0 -sF/1.8],sF/1.5,'window',hT);
        mwlt.Experiment.Show.Image(figures{4},[0 sF/1.8],sF/1.5,'window',hT);
        
        mwlt.Experiment.Show.Circle('red',1/6,[0 0],'window',hT);
        
        mwlt.Experiment.Show.Text('<color:marigold>L</color>',[-sF/2 0],'window',hT);
        mwlt.Experiment.Show.Text('<color:marigold>R</color>',[sF/2 0],'window',hT);
        mwlt.Experiment.Show.Text('<color:marigold>U</color>',[0 -sF/2],'window',hT);
        mwlt.Experiment.Show.Text('<color:marigold>D</color>',[0 sF/2],'window',hT);
        
    end
end