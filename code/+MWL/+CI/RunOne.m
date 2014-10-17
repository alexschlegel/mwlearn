function bResponseCorrect = RunOne(mwlt, dLevel, varargin)
% Run one parts-construct task. This is the function
% passed to PsychoCurve.
%
%   Syntax: MWL.CI.RunOne(mwlt, dLevel, [runMode]='test')
%
%   In:  mwlt   - the MWLearnTest object
%        dLevel - the current difficulty level, ranging from
%                0 to 1 with step of 0.01.
%          runMode - 'test' = normal trial
%                 'practice' = practice trial
%
%   Out: bResponseCorrect  - logical indicating correctness of
%                            response.

% parse input arguments
runMode = ParseArgs(varargin, 'test');
bRecord = ~strcmp(runMode, 'practice');

% Set up the textures.
[hPrompt, hTest, hFeedback, posCorrect, iAnsParts] = MWL.CI.SetupTask(mwlt, dLevel);
hStart = mwlt.Experiment.Window.OpenTexture('start');

mwlt.Experiment.Show.Text('Press any key to start the trial.', 'window', 'start');
% set up response buttons
buttons = {'up','right','down','left'};
kButtonCorrect = cell2mat(mwlt.Experiment.Input.Get(buttons{posCorrect}));

bResponseCorrect = false;

% initialize sequence
t = MWL.Param('ci','time');
cX      = {hStart
           hPrompt
          {'Blank'}
           hTest
          {@ShowFeedback, false}
          {@ShowFeedback, true}
          };

tShow   = {@StartTrial
           t.prompt
           t.construct
           t.test
           t.pause
           t.feedback
          };

fWait   = {@Wait_Default
           @Wait_Default
           @Wait_Default
           @Wait_Response
           @Wait_Default
           @Wait_Default
          };

mwlt.Experiment.Log.Append('Trial begin');
[cTrial.tStart,cTrial.tEnd,cTrial.tShow,cTrial.bAbort,cTrial.kButton,cTrial.rt] = ...
    mwlt.Experiment.Show.Sequence(cX, tShow, 'fwait', fWait, 'tbase', 'step', 'fixation', false);
mwlt.Experiment.Log.Append('Trial end');

persistent trial;
if bRecord
    % save data
    cTrial.correct = bResponseCorrect;
    cTrial.posCorrect = posCorrect;
    cTrial.parts = iAnsParts;
    cTrial.level = dLevel;
    
    if isempty(trial)
        trial = cTrial;
    else
        trial(end+1) = cTrial;
    end
    mwlt.Experiment.Info.Set('mwlt',{'ci','trial'},trial);
    mwlt.Experiment.Log.Append('Trial data saved');
end
%-----------------------------------------------------------------------------%
    function ShowFeedback(bGiveFeedback, varargin)
        if bGiveFeedback  
            if bResponseCorrect
                mwlt.Experiment.Show.Text('<color:green><size:1.3>Yes!</size></color>', [0,0],'center',true,'window', hFeedback);
            else
                mwlt.Experiment.Show.Text('<color:red><size:1.3>No!</size></color>', [0,0], 'center',true,'window', hFeedback);
            end
        end
        mwlt.Experiment.Show.Texture(hFeedback, varargin{:});
    end
%----------------------------------------------------------------------------%
    function [bAbort, bContinue] = StartTrial(~)
        bAbort = false;
        bContinue = any(mwlt.Experiment.Input.State);        
    end
%----------------------------------------------------------------------------%
    function [bAbort, kButton, tResponse] = Wait_Default(~,~)
        bAbort = false;
        kButton = [];
        tResponse = [];
        mwlt.Experiment.Scheduler.Wait(PTB.Scheduler.PRIORITY_CRITICAL);        
    end
%----------------------------------------------------------------------------%
    function [bAbort, kButton, tResponse] = Wait_Response(tNow,~)
        bAbort = false;        
        [~, ~, ~, kButton] = mwlt.Experiment.Input.DownOnce('response');
        if kButton == kButtonCorrect
            bResponseCorrect = true;
            tResponse = tNow;
        elseif ~isempty(kButton)
            bResponseCorrect = false;
            tResponse = tNow;
        else
            tResponse = [];
        end        
        mwlt.Experiment.Scheduler.Wait(PTB.Scheduler.PRIORITY_CRITICAL);
    end


end
