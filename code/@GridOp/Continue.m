function b = Continue(go, strPrompt)
% GridOp.Continue
% 
% Description:	prompt the subject to continue, but check with the experimenter
%				as well
% 
% Syntax:	b = go.Continue(strPrompt)
% 
% Updated: 2015-01-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strYes	= GO.Param('response','correct');
strNo	= GO.Param('response','incorrect');

kYes= cell2mat(go.Experiment.Input.Get('correct'));
kNo	= cell2mat(go.Experiment.Input.Get('incorrect'));

strPrompt = sprintf('%s\\n\\nPress any button to continue.',strPrompt);

go.Experiment.Show.Text(strPrompt);
go.Experiment.Window.Flip;

%disable the keyboard
	ListenChar(2);

%so we can track button presses
	go.Experiment.Scanner.StartScan;

[err,t,kState,bAbort]	= go.Experiment.Input.WaitDownOnce('response',...
							'fabort'	, @CheckAbort	  ...
							);

%stop looking for button presses
	go.Experiment.Scanner.StopScan;

%enable the keyboard
	ListenChar(1);

b	= ~bAbort;

go.Experiment.Show.Blank;
go.Experiment.Window.Flip;

%------------------------------------------------------------------------------%
function b = CheckAbort()
	b	= go.Key.Down('abort');
end
%------------------------------------------------------------------------------%

end
