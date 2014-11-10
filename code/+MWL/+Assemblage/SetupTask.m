function [hPrompt, tPrompt, hTest, hFeedback, posCorrect] = SetupTask(mwlt, dLevel)
%  Set up the textures for one assemblage task.
%
%  Syntax: MWL.Assemblage.SetupTask(mwlt,dLevel)
%
%  In:
%       mwlt - the MWLearnTest experiment object.
%     dLevel - current difficulty level (1 -> 10)
%
%  Out:
%    hPrompt - handle to the prompt texture
%    tPrompt - time to show the prompt texture
%      hTest - handle to the test texture
%  hFeedback - handle to feedback texture
% posCorrect - indicates the position of the correct figure, clockwise
%              starting from the top.

% Add assemblage code here!