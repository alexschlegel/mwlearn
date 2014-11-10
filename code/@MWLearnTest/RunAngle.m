function RunAngle(mwlt, varargin)
% Helper function to run the angle task.
%
% Syntax: mwlt.RunAngle(<options>)
%
% In:
%   mwlt - the MWLearnTest experiment object
%   <options>:
%       lock -(true) whether to lock the keyboard at the end of the test, until the
%             unlock code is pressed on the input device (see mwlt.Run)
opt = ParseArgs(varargin, 'lock',true);
mwlt.Run('angle','lock',opt.lock);