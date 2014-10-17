function cImage = GetImage(arrIndex)
% MWL.Angle.GetImage
%
% Description: get a cell of images for the angle rotation task.
%
% Syntax: cImage = MWL.Angle.GetImage(arrIndex);
%
% In:
%   arrIndex - an array of indices for the images to get
%
% Out:
%   cImage - a cell of the images

persistent cAllImage;
if isempty(cAllImage)
    imDir = MWL.Param('angle','imDir');
    imExt = MWL.Param('angle','imExt');
    % fill in rest once images exist
end

cImage = arrayfun(@(i) cAllImage{i}, arrIndex, 'uni', false);