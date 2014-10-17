function Run(mwlt, test)
% MWLearnTest.Run
%
% Description: run a series of mwlearn tests.
%
% Syntax: mwlt.Run(test)
%
% In:
%   test - the test to run, either 'ci', 'angle', 'wm', or 'assemblage'.

% Parse input to determine tests to run

% set exit code
if  strcmp(mwlt.Experiment.Info.Get('experiment','input'), 'joystick')
    mwlt.Experiment.Input.Set('close_window', {'lupper';'back';'y'});
else
    mwlt.Experiment.Input.Set('close_window', {'left';'right'});
end

% run test
switch test
    case 'ci'
        mwlt.Experiment.Info.Set('mwlt',{'tests','ci'}, true);
        MWL.CI.Run(mwlt);
    case 'angle'
        mwlt.Experiment.Info.Set('mwlt',{'tests','angle'}, true);        
        MWL.Angle.Run(mwlt);
    case 'wm'
        mwlt.Experiment.Info.Set('mwlt',{'tests','wm'}, true);
        MWL.WM.Run(mwlt);
    case 'assemblage'
        mwlt.Experiment.Info.Set('mwlt',{'tests','assemblage'}, true);
        MWL.Assemblage.Run(mwlt);
end

% Finish up
fClose = @()deal(mwlt.Experiment.Input.DownOnce('close_window'),false,PTB.Now);
mwlt.Experiment.Show.Instructions('Finished! Please alert the experimenter.', ...
     'prompt', ' ', 'fresponse', fClose);
mwlt.Experiment.Window.Close; 
end