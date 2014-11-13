function Run(mwlt, test, varargin)
% MWLearnTest.Run
%
% Description: run a mwlearn test.
%
% Syntax: mwlt.Run(test, <options>)
%
% In:
%   mwlt - the MWLearnTest experiment object
%   test - the test to run, either 'ci', 'angle', 'wm', or 'assemblage'.
%   <options>:   
%       lock -(true) whether to lock the keyboard until the unlock code is pressed
%            at the end of the test(s) The unlock code is lupper + back + y
%            on the joystick, and left + right on the keyboard.

% Parse input
opt = ParseArgs(varargin, 'lock',true);

% set exit code
if  strcmp(mwlt.Experiment.Info.Get('experiment','input'), 'joystick')
    mwlt.Experiment.Input.Set('unlock', {'lupper';'back';'y'});
else
    mwlt.Experiment.Input.Set('unlock', {'left';'right'});
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
fClose = @()deal(mwlt.Experiment.Input.DownOnce('unlock'),false,PTB.Now);
mwlt.Scheduler.Pause;
mwlt.Experiment.Show.Instructions('Task finished! Please alert the experimenter.', ...
     'prompt', ' ', 'fresponse', conditional(opt.lock,fClose,@()deal(true,false,PTB.Now)));
mwlt.Scheduler.Resume;
end