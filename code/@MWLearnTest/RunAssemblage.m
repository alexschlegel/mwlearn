function RunAssemblage(mwlt, varargin)
% Helper function to run the assemblage task.
%
% Syntax: mwlt.RunAssemblage([lock]=true)
%
% In:
%   mwlt - the MWLearnTest experiment object
%   <options>:
%       lock -(true) whether to lock the keyboard at the end of the test, until the
%             unlock code is pressed on the input device (see mwlt.Run)

opt = ParseArgs(varargin, 'lock',true);
mwlt.Run('assemblage','lock',opt.lock);