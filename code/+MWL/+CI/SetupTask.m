function [hPrompt, hTest, hFeedback, posCorrect, iAnsParts] = SetupTask(mwlt, dLevel)
%  Set up the textures for one constructive imagery task.
%
%  Syntax: MWL.CI.SetupTask(mwlt,dLevel)
%
%  In:
%       mwlt - the MWLearnTest object.
%     dLevel - current difficulty level (0 -> 1)
%
%  Out:
%    hPrompt - handle to the prompt texture
%      hTest - handle to the test texture
%  hFeedback - handle to feedback texture
% posCorrect - indicates the position of the correct figure, clockwise
%              starting from the top.

numParts = MWL.Param('ci','numParts');

% Screen parameters
[~, ~, ~, screenDimVA] = mwlt.Experiment.Window.Get('main'); % screen size in visual angle
[widthVA, heightVA] = deal(screenDimVA(1), screenDimVA(2));
horzOffset = widthVA/4;
vertOffset = heightVA/4;

% PROMPT SETUP --------------------------------------------
% Choose parts
iParts = PickParts(4);
[part, ~] = MWL.CI.GetImages(mwlt,iParts);

% Draw the prompt texture
hPrompt = mwlt.Experiment.Window.OpenTexture('prompt');
partSize = MWL.Param('ci','imSize','part');
stripLength = MWL.Param('ci','imSize','partStrip');
mwlt.Experiment.Show.Image(part, [0,0], ...
    [stripLength, partSize], 'window', hPrompt, 'center', true);


% TEST SETUP----------------------------------------------------
% Get set of parts for answer choices.
[iAnsParts, posCorrect] = GetAnsParts(iParts);
% construct the figures
[~, ansFigures] = arrayfun(@(i) MWL.CI.GetImages(mwlt, iAnsParts(:,i)), (1:4)', 'uni', false);
                        
figureSize = MWL.Param('ci','imSize','figure');

% Draw the test texture
hTest = mwlt.Experiment.Window.OpenTexture('test');

matPositions = repmat([horzOffset, vertOffset], 4, 1) .* [0,-1;1,0;0,1;-1,0];

mwlt.Experiment.Show.Image(ansFigures{1}, matPositions(1,:), figureSize, ...
    'window', hTest, 'center', true);
mwlt.Experiment.Show.Image(ansFigures{2}, matPositions(2,:), figureSize, ...
    'window', hTest, 'center', true);
mwlt.Experiment.Show.Image(ansFigures{3}, matPositions(3,:), figureSize, ...
    'window', hTest, 'center', true);
mwlt.Experiment.Show.Image(ansFigures{4}, matPositions(4,:), figureSize, ...
    'window', hTest, 'center', true);

% FEEDBACK SETUP---------------------------------------------------------
hFeedback = mwlt.Experiment.Window.OpenTexture('feedback');
mwlt.Experiment.Show.Image(ansFigures{posCorrect}, matPositions(posCorrect, :), ...
    figureSize, 'window', hFeedback, 'center', true);

%----------------------------------------------------------------------------%
    function iParts = PickParts(nPick)
        % Pick parts for a parts-construct task, such that the average of
        % their difficulties is approximately equal to dLevel.
        %
        % In: nPick  - number of parts to pick
        %
        % Out: indParts - indices of part images
        
        % range of allowable parts
        rngMax = min(numParts, 2 + floor(dLevel*(numParts-1)));
        rngMin = max(1, rngMax - 25);
        rngMean = (rngMin + rngMax)/2;
        
        soFar = 0;
        iParts = NaN(nPick,1);
        for iPick = 1:nPick
            if iPick == nPick % get us close to the midpoint
                pMid = rngMean*nPick - soFar;
                pMin = max(rngMin, floor(pMid - 0.5));
                pMax = min(rngMax, ceil(pMid + 0.5));
                nextPart = randi([pMin,pMax]);
            else % choose a part that allows us to reach the midpoint by the end.
                while true
                     nextPart = randi([rngMin, rngMax]);
                    endMin = (soFar + nextPart + rngMin*(nPick-iPick))/nPick;
                    endMax = (soFar + nextPart + rngMax*(nPick-iPick))/nPick;
                    if rngMean >= endMin && rngMean <= endMax
                        break;
                    end
                end
            end
            % Add the chosen part.
            soFar = soFar + nextPart;
            iParts(iPick,1) = nextPart;
        end
        % finish up
        iParts = randomize(iParts);
    end
%-----------------------------------------------------------------------------%
    function [iAnsParts, posCorrect] = GetAnsParts(iCorrect)
   WaitSecs(1);
     % Generate a set of possible answers to show on the test screen.
        %
        % In: iCorrect  - the indices of the parts of the correct figure.
        %
        % Out: iAnsParts - a nParts by nFigures matrix of part indices.
        %     posCorrect - the column of iAnsParts that contains the
        %                  correct figure
        
        % Get distractor figures that are not repeats of each other.
        iAnsParts = iCorrect;
        while true
            iDistractors = PickParts(3);
            positions = randomize(1:4);
            for nPart = 1:3
                newFigure = [];
                for nPos = positions
                    trialFigure = iCorrect;
                    trialFigure(nPos) = iDistractors(nPart);
                    for i = 1:size(iAnsParts, 2)
                        if isequal(trialFigure, iAnsParts(:,i));
                           newFigure = [];
                           break
                        end
                        newFigure = trialFigure;
                    end
                    if ~isempty(newFigure)
                        break
                    end
                end
                if isempty(newFigure)
                    break
                end
                iAnsParts(:,nPart+1) = newFigure;
                positions = setdiff(positions, nPos);
            end
            if ~isempty(newFigure) && size(iAnsParts, 2) == 4
                break
            end
        end
        
        % randomize order of figures
        figurePos = randomize(1:4);
        posCorrect = find(figurePos == 1);
        iAnsParts = iAnsParts(:,figurePos);
    end

end