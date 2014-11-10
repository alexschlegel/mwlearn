function Run(mwlt)
% MWL.WM.Run
%
% Description: do a working memory battery run
%
% Syntax: MWL.WM.Run(mwlt)

runTest = MWL.Param('wm','run');

global strDirCode
global strDirBase

% Prepare to execute the wm battery
mwlt.Experiment.Scheduler.Pause;
params = MWL.Param('wm');
cd(DirAppend(strDirCode, 'WMBattery'));
mwlt.Experiment.Show.Color('white');
mwlt.Experiment.Window.Flip;

% Run!
[MUData, OSData, SSData, SSTMData, SSTMSumData] = ...
    WMCBattery(mwlt, params, 'run_mu',runTest.mu,'run_os',runTest.os,'run_ss',runTest.ss,'run_sstm',runTest.sstm);

% Back to normal
cd(strDirBase);
mwlt.Experiment.Scheduler.Resume;

% Store the data
MWL.WM.ReadData(mwlt, MUData, OSData, SSData, SSTMData, SSTMSumData);

end
