function bResponseCorrect = RunOne(mwlt, degRot, bPractice)
% Run one parts-construct task. This is the function
% passed to PsychoCurve.
%
%   Syntax: MWL.CI.RunOne(mwlt, dLevel)
%
%   In:  mwlt   - the MWLearnTest object
%        degRot - the degrees of rotation, ranging from 1 (hardest) to 90
%        (easiest).
%     bPractice - whether this is a practice trial
%
%   Out: bResponseCorrect  - logical indicating correctness of
%                            response.