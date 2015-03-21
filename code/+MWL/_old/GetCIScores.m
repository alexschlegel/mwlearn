function [constructScore] = GetCIScores(strPath)
    allResults = load(strPath);
    constructScore = 1 - allResults.PTBIFO.mwlt.ci.psychoCurve.t;
end