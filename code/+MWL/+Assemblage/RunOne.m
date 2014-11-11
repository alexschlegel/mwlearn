function bResponseCorrect = RunOne(mwlt, dLevel, varargin)
% Run one assemblage task. 
%
%   Syntax: MWL.Assemblage.RunOne(mwlt, dLevel, [runMode]='test')
%
%   In:  mwlt   - the MWLearnTest object
%        dLevel - the current difficulty level (see parameters)
%        runMode - 'test' = normal trial
%                  'practice' = practice trial
%
%   Out: bResponseCorrect  - logical indicating correctness of
%                            response.

% parse input arguments
runMode = ParseArgs(varargin, 'test');
bRecord = ~strcmp(runMode, 'practice');

%initialize the trial result
sTrial	= struct;

% set up the textures / prompts
[hPrompt, tPrompt, hTest, hFeedback, sTrial.posCorrect, sTrial.assemblages] = MWL.Assemblage.SetupTask(mwlt, dLevel);


hStart = mwlt.Experiment.Window.OpenTexture('start');
mwlt.Experiment.Show.Text('Press any key to start the trial.', 'window', 'start');

% set up response buttons
buttons = {'up','right','down','left'};
kButtonCorrect = cell2mat(mwlt.Experiment.Input.Get(buttons{sTrial.posCorrect}));

bResponseCorrect = false; %initially

% initialize sequence
t = MWL.Param('assemblage','time');
cX = {hStart
     hPrompt
     hTest
     {@ShowFeedback, false}
     {@ShowFeedback, true}
     };
 
tShow = {@StartTrial
        tPrompt
        t.test
        t.pause
        t.feedback
        };
    
fWait = {@Wait_Default
        @Wait_Default
        @Wait_Response
        @Wait_Default
        @Wait_Default
        };

mwlt.Experiment.Log.Append('Trial begin');
[sTrial.tStart,sTrial.tEnd,sTrial.tShow,sTrial.bAbort,sTrial.kButton,sTrial.rt] = ...
    mwlt.Experiment.Show.Sequence(cX, tShow, 'fwait', fWait, 'tbase', 'step', 'fixation', false);
mwlt.Experiment.Log.Append('Trial end');

global AssemblageResult;

if bRecord
    % save data
    sTrial.correct	= bResponseCorrect;
    sTrial.level	= dLevel;
    
    if isempty(AssemblageResult)
        AssemblageResult = sTrial;
    else
        AssemblageResult(end+1) = sTrial;
    end
    
    mwlt.Experiment.Info.Set('mwlt',{'assemblage','result'},AssemblageResult);
    mwlt.Experiment.Log.Append('Trial results saved');
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