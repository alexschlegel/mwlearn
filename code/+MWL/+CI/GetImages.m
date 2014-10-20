function [part, fig] = GetImages(mwlt, iParts)
% Get the images of parts and the figure given the numbers of 4 parts.
%
% Syntax: [part, fig] = MWL.CI.GetFigure(mwlt, p1, p2, p3, p4);
%
% In: mwlt - the MWLearnTest object
%   iParts - array of 4 part indices
%
% Out: part - an image containing the 4 parts.
%       fig - an image containing the figure constructed from the parts.
persistent cParts;
partsDir = MWL.Param('ci','partsDir');    
partsExt  = MWL.Param('ci','partsExt');
numParts = numel(dir(PathUnsplit(partsDir, '*', partsExt)));
bgColor = mwlt.Experiment.Color.Get(MWL.Param('ci','color','back'));

% get the part images.
if isempty(cParts)    
    fGetPart = @(n) PathUnsplit(partsDir, ['part_' StringFill(n,3)], partsExt);
    cPathParts = arrayfun(fGetPart, (0:numParts-1)', 'uni', false);
    cParts = cellfun(@(path) imread(path, partsExt), cPathParts, 'uni', false);
    % set colors.
    bWhite = cellfun(@(i) i > 128, cParts, 'uni', false);
    bBlack = cellfun(@(i) ~i, bWhite, 'uni', false);    
    fgColor = mwlt.Experiment.Color.Get(MWL.Param('ci','color','fore'));
    cParts = arrayfun(@(i) cat(3, uint8(bWhite{i})*bgColor(1) + uint8(bBlack{i})*fgColor(1), ...
                                  uint8(bWhite{i})*bgColor(2) + uint8(bBlack{i})*fgColor(2), ...
                                  uint8(bWhite{i})*bgColor(3) + uint8(bBlack{i})*fgColor(3),...
                                  uint8(bWhite{i})*bgColor(4) + uint8(bBlack{i})*fgColor(4)),...
                                  1:100, 'uni', false);
end % note that indexing of parts is now 1-based.

% Get part image.
parts = cParts(iParts);
% concatenate parts into a linear figure (sequence: tr, br, bl, tl)
figSizePX = size(parts{1},1);
spacerWidthPX = floor(figSizePX*MWL.Param('ci','spacerFrac'));
spacer = repmat(reshape(bgColor, 1,1,[]), figSizePX, spacerWidthPX);

part = [imrotate(parts{1},-90), spacer, imrotate(parts{2},180), spacer,...
        imrotate(parts{3},90), spacer, parts{4}];
        
% Get figure image.
fig = [         parts{4}      imrotate(parts{1},-90) ; ...
       imrotate(parts{3}, 90) imrotate(parts{2},180)];

end