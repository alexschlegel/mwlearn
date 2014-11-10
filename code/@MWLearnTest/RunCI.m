function RunCI(mwlt, varargin)
% Helper function to run the CI task.
%
% Syntax: mwlt.RunCI([lock]=true)
%
% In:
%   mwlt - the MWLearnTest experiment object
%   <options>:
%       lock -(true) whether to lock the keyboard at the end of the test, until the
%             unlock code is pressed on the input device (see mwlt.Run)
opt = ParseArgs(varargin, 'lock',true);
mwlt.Run('ci','lock',opt.lock);