function bResponseCorrect = RunOne(mwlt, rotStep, bPractice)
% Run one image rotation task. This is the function
% passed to PsychoCurve.
%
%   Syntax: MWL.Angle.RunOne(mwlt, dLevel)
%
%   In:  mwlt   - the MWLearnTest object
%       rotStep - the difference in rotation between correct and incorrect
%                 figures. Ranges from 1 (hardest) to 90 (easiest).                 
%     bPractice - whether this is a practice trial
%
%   Out: bResponseCorrect  - logical indicating correctness of
%                            response.

% Set up the textures
[hPrompt, hTest, hResponse, hFeedback, bLeftCorr] = MWL.Angle.SetupTask(mwlt, rotStep, bPractice);
hStart = mwlt.Experiment.Window.OpenTexture('start');
mwlt.Experiment.Show.Text('Press any key to start the trial.', 'window', 'start');


% Response buttons
kButtonCorrect = cell2mat(mwlt.Experiment.Input.Get(conditional(bLeftCorr,'left','right')));

bResponseCorrect = false;

% initialize sequence
t = MWL.Param('angle','time');
cX = {hStart
     hPrompt
     {'Blank'}
     hTest
     hResponse
     {@ShowFeedback, false}
     {@ShowFeedback, true}
     {'Blank'}
     };

tShow = {@StartTrial
         t.prompt
         t.rotate
         t.test
         t.response
         t.pause
         t.feedback
         t.prepare
         };
     
fWait   = {@Wait_Default
           @Wait_Default
           @Wait_Default
           @Wait_Response
           @Wait_Response
           @Wait_Default
           @Wait_Default
           @Wait_Default
          };
mwlt.Experiment.Log.Append('Trial begin');
[cTrial.tStart,cTrial.tEnd,cTrial.tShow,cTrial.bAbort,cTrial.kButton,cTrial.rt] = ...
    mwlt.Experiment.Show.Sequence(cX, tShow, 'fwait', fWait, 'tbase', 'step', 'fixation', false);
mwlt.Experiment.Log.Append('Trial end');

% Close textures
cellfun(@(t) mwlt.Experiment.Window.CloseTexture(t), {'start','prompt','test','response','feedback'});

global angleResult;
if ~bPractice
    % save data
    cTrial.correct = bResponseCorrect;
    if isempty(angleResult)
        angleResult = cTrial;
    else
        angleResult(end+1) = cTrial;
    end
    mwlt.Experiment.Info.Set('mwlt', {'angle','result'}, angleResult);
    mwlt.Experiment.Log.Append('Trial results saved.');
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
        bContinue = mwlt.Experiment.Input.DownOnce('any');        
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

