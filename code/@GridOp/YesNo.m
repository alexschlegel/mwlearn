function b = YesNo(go, strPrompt)
% GridOp.YesNo
% 
% Description:	ask a yes or no question and return the response
% 
% Syntax:	b = go.YesNo(strPrompt)
% 
% Updated: 2015-01-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strYes	= GO.Param('response','correct');
strNo	= GO.Param('response','incorrect');

kYes= cell2mat(go.Experiment.Input.Get('correct'));
kNo	= cell2mat(go.Experiment.Input.Get('incorrect'));

strPrompt = sprintf('%s\\n\\nYes: %s\\nNo: %s',strPrompt,strYes,strNo);

go.Experiment.Show.Text(strPrompt);
go.Experiment.Window.Flip;

%so we can track button presses
	go.Experiment.Scanner.StartScan;

[err,t,kState]	= go.Experiment.Input.WaitDownOnce('response');

%stop looking for button presses
	go.Experiment.Scanner.StopScan;

b	= any(ismember(kYes,kState));

go.Experiment.Show.Blank;
go.Experiment.Window.Flip;
