function im = GetImage(mwlt, imIndex, strColor)
% MWL.Angle.GetImage
%
% Description: get an image for the angle rotation task.
%
% Syntax: cImage = MWL.Angle.GetImage(mwlt, imIndex, strColor);
%
% In:
%   mwlt     - the MWLearnTest object
%   imIndex  - an index for the image to get
%   strColor - the color of the image to get (a string for PTB.Color)
%
% Out:
%   im - the image

persistent cAllImage;
if isempty(cAllImage)
    imDir = MWL.Param('angle','image', 'dir');
    imExt = MWL.Param('angle','image', 'ext');
    numIm = MWL.Param('angle','image', 'num');
    fGetIm = @(n) PathUnsplit(imDir, StringFill(n,3), imExt);
    cImPath = arrayfun(fGetIm, (1:numIm)', 'uni', false);
    cAllImage = cellfun(@(imPath) 255*imread(imPath, imExt), cImPath, 'uni', false);
end

imAlpha = cAllImage{imIndex};
imSize = size(imAlpha);
imColor = mwlt.Experiment.Color.Get(strColor);
imColor = imColor(1:3); % remove alpha channel
im = cat(3, repmat(reshape(imColor,[1,1,3]),imSize), imAlpha);
