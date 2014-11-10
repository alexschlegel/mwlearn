  function Run(mwlt)
% MWLearnTest.RunCI
%
% Description: do a constructive imagery run
%
% Syntax: MWL.CI.Run(mwlt)

% clear residual global variables
clear global CIResult;

% switch to lrud input scheme
if strcmp(mwlt.Experiment.Info.Get('experiment','input'), 'joystick')
    mwlt.Experiment.Input.Set('left', 'x');
    mwlt.Experiment.Input.Set('right', 'b');
end
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

% save psychocurve object
mwlt.Experiment.Info.Set('mwlt',{'ci','psychoCurve'},p);
% clear global variables again
clear global CIResult;
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
str	= 'In this test, you will mentally construct figures from their parts.';
fig = Figure_Example(parts{1}, figures{1});
mwlt.Experiment.Show.Instructions(str,'figure',fig);
   mwlt.Experiment.Window.CloseTexture(fig);

%describe constructing
str	= 'You will see four parts.\nPut the parts together in your head,\nstarting with the upper right and going clockwise.';
fig	= Figure_Construct(parts{1}, figures{1});
mwlt.Experiment.Show.Instructions(str,'figure',fig);
 mwlt.Experiment.Window.CloseTexture(fig);

%describe the test
tTest		= MWL.Param('ci','time','test')/1000;
strPlural	= plural(tTest,'','s');
str	= ['A few seconds after the parts disappear, you will see four test figures. Press the button corresponding to the correct figure (X, Y, A or B).\n\nYou will have ' num2str(tTest) ' second' strPlural ' to respond. Only your last response will be recorded.'];
fig	= Figure_Test(figures);
mwlt.Experiment.Show.Instructions(str,'figure',fig);
mwlt.Experiment.Window.CloseTexture(fig);

    function fig = Figure_Example(part, figure)
        % construct an example figure for the instructions.
        fig	= 'ci_figure_example';
        hT = mwlt.Experiment.Window.OpenTexture(fig, [sWPx(1) 2*sFPx]);
        
        mwlt.Experiment.Show.Image(part,[0 -3*sF/4],sS,'window',hT);
        mwlt.Experiment.Show.Arrow('yellow',[0 -4],[0 -1],[],0,1,'window',hT);
        mwlt.Experiment.Show.Image(figure,[0 sF/2],sF,'window',hT);       
    end

    function fig = Figure_Construct(part, figure)
        fig	= 'ci_figure_construct';	
        hT	= mwlt.Experiment.Window.OpenTexture(fig,[sWPx(1) 2*sFPx]);
        
        yS	= -3*sF/4;
        
        mwlt.Experiment.Show.Image(part,[0 yS],sS,'window',hT);
        mwlt.Experiment.Show.Arrow('yellow',[0 -4],[0 -1],[],0,1,'window',hT);
        mwlt.Experiment.Show.Image(figure,[0 sF/2],sF,'window',hT);
        
        mwlt.Experiment.Show.Text('<color:yellow>1</color>',[-sF-sF/8 yS+3*sF/16],'window',hT);
        mwlt.Experiment.Show.Text('<color:yellow>2</color>',[-sF/2 yS-sF/8],'window',hT);
        mwlt.Experiment.Show.Text('<color:yellow>3</color>',[sF/2 yS-sF/8],'window',hT);
        mwlt.Experiment.Show.Text('<color:yellow>4</color>',[sF+sF/8 yS+3*sF/16],'window',hT);
        
        mwlt.Experiment.Show.Line('yellow',[0 0],[0 sF],'window',hT);
        mwlt.Experiment.Show.Line('yellow',[-sF/2 sF/2],[sF/2 sF/2],'window',hT);
        mwlt.Experiment.Show.Text('<color:yellow>1</color>',[sF/16 sF/2-sF/16],'window',hT);
        mwlt.Experiment.Show.Text('<color:yellow>2</color>',[sF/16 sF/2+sF/8],'window',hT);
        mwlt.Experiment.Show.Text('<color:yellow>3</color>',[-sF/16 sF/2+sF/8],'window',hT);
        mwlt.Experiment.Show.Text('<color:yellow>4</color>',[-sF/16 sF/2-sF/16],'window',hT);
    end

    function fig = Figure_Test(figures)
        fig	= 'ci_figure_test';
        
        hT	= mwlt.Experiment.Window.OpenTexture(fig,[sWPx(1) 2*sFPx]);
        
        mwlt.Experiment.Show.Image(figures{1},[-sF/1.8 0],sF/1.5,'window',hT);
        mwlt.Experiment.Show.Image(figures{2},[sF/1.8 0],sF/1.5,'window',hT);
        mwlt.Experiment.Show.Image(figures{3},[0 -sF/1.8],sF/1.5,'window',hT);
        mwlt.Experiment.Show.Image(figures{4},[0 sF/1.8],sF/1.5,'window',hT);
        
        mwlt.Experiment.Show.Circle('red',1/6,[0 0],'window',hT);
        
        mwlt.Experiment.Show.Text('<color:blue>X</color>',[-sF/2 0],'window',hT);
        mwlt.Experiment.Show.Text('<color:red>B</color>',[sF/2 0],'window',hT);
        mwlt.Experiment.Show.Text('<color:yellow>Y</color>',[0 -sF/2],'window',hT);
        mwlt.Experiment.Show.Text('<color:green>A</color>',[0 sF/2],'window',hT);
        
    end
end