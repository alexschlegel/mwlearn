function sResults = GetBehavResults(varargin)
% MWL.GetBehavResults;
%
% Description: Gets behavioral results (pretest, posttest, and change)
%   for all mwlt participants. 
%
% Syntax: behavResults = MWL.GetBehavResults(<options>);
%
% In: 
%   <options>:
%       path:   (<all>) a cell of paths to .mat result files
%       silent: (false) true to suppress status messages
%
% Out:
%   behavResults    -   a struct containing the participants'
%                       behavioral results. Each field is an N-subject by
%                       3-session array of scores for the test indicated by
%                       the field name
%                       
% Notes: 
%   -For alex tests (ci, angle, assemblage) this function returns the
%   difficulty (1-t from psychoCurve). For the sentence span task it
%   returns percent correct on letter-memory. For spatial short term 
%   memory, it return 'fracScore', the percentage of dot locations 
%   remembered correctly.
%   
%   -Missing sessions are given a score of 1 in behavResults struct. 
%
% Written 03-11-2015 by Kevin Hartstein
opt = ParseArgs(varargin,...
        'path'      , []    , ...
        'silent'    , false   ...
        );

if isempty(opt.path)
    ifo = MWL.GetSubjectInfo;
    opt.path = ifo.path.session.behavioral;
end

sResults = cellfunprogress(@LoadResult,opt.path,...
            'label'     , 'loading behavioral results', ...
            'silent'    , opt.silent                    ...
            );
sResults = restruct(sResults);

end

% Functions for getting scores for each test

function s = LoadResult(strPathResult)
    warning('off','MATLAB:indeterminateFields');
    
    if FileExists(strPathResult)
        res = load(strPathResult);
        
        s = struct(...
                'construct'     , GetConstructScore(res)   , ...
                'rotate'        , GetRotateScore(res)      , ...
                'assemblage'    , GetAssemblageScore(res)  , ...
                'wm_verbal'     , GetWMVerbalScore(res)    , ...
                'wm_spatial'    , GetWMSpatialScore(res)     ...
                );
    else
        if ~isempty(strPathResult)
            warning('%s does not exist.',strPathResult);
        end
        
        s = dealstruct('construct','rotate','assemblage','wm_verbal','wm_spatial',NaN);
    end
end

function [constructScore] = GetConstructScore(res)  
    constructScore = 1 - res.PTBIFO.mwlt.ci.psychoCurve.t;
end

function [rotateScore] = GetRotateScore(res)
    rotateScore = 1 - res.PTBIFO.mwlt.angle.psychoCurve.t;
end
   
function [assemblageScore] = GetAssemblageScore(res)
    assemblageScore = 1 - res.PTBIFO.mwlt.assemblage.psychoCurve.t;
end

function [wm_verbalScore] = GetWMVerbalScore(res)
    bTrial = [res.PTBIFO.mwlt.wm.ss.trial];
    cLetterCorrect = {bTrial.bLetterCorrect};
    bPercentCorrect = cellfun(@mean, cLetterCorrect);
    wm_verbalScore = mean(bPercentCorrect);    
end

function [wm_spatialScore] = GetWMSpatialScore(res)
    wm_spatialScore = res.PTBIFO.mwlt.wm.sstm.fracScore;
end
