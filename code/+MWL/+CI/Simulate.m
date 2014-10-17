function [tError, bError, p, trials2thresh] = Simulate(dLevel, b, varargin)
% MWL.CI.Simulate
%
% Description: do a constructive imagery simulation.
%
% Syntax: MWL.CI.Simulate(dLevel, b, <options>)
%
% In:
%   dLevel - the subject's ability level (0 => 1)
%        b - the weibull slope parameter
%   <options>:    
%       noise - (0) the maximum allowed deviation from the predicted accuracy. For
%               instance, if the trial is at the subject's dLevel, the weibull
%               function would predict an accuracy of 0.75, but if noise = 0.1
%               this could range from 0.65 to 0.85.
%   errThresh - (<none>) the target threshold in tError.
%   numTrials - (100) the number of trials to run if no errThresh is
%               specified
%   maxTrials - (1000) the maximum number of trials to run with an
%               errThresh
%        plot - (false) plot tError and bError
%
% Out:
%                p - the PsychoCurve object generated during the run
%           tError - a cell that contains, for each trial, the absolute value of the
%                    difference between the actual and estimated dLevels.
%           bError - same as dError but for b values.
%    trials2thresh - if a theshold is specified, the number of trials necessary to reach a dError of
%                    errThresh or below

% parse input arguments
opt = ParseArgs(varargin, ...
            'noise', 0, ...
            'errThresh', [], ...
            'numTrials', 100, ...
            'maxTrials', 1000, ...
            'plot'     , false ...
            );
        
% PsychoCurve parameters
a = MWL.Param('ci','psychocurve','targetFracCorrect');
g = MWL.Param('ci','psychocurve','baselineFracCorrect');
xstep = MWL.Param('ci','psychocurve','xstep');
t = MWL.Param('ci','psychocurve','start_t');

function bResponseCorrect = SimRun(x)
        pCorrect = weibull(x, 1-dLevel, b, [], g, a);
        pCorrect = pCorrect + (2*rand-1)*opt.noise;
        bResponseCorrect = rand < pCorrect;
    end

p = PsychoCurve('F',@SimRun, 'a', a, 'g', g, 'xstep', xstep, 't', t);

if ~isempty(opt.errThresh)
    iters = 0;
    tErrorCurrent = Inf;
    while iters < opt.maxTrials && tErrorCurrent > opt.errThresh
        p.Run('itmin', 1, 'itmax', 1, 'silent', true);
        iters = iters + 1;
        tErrorCurrent = abs(1-p.t-dLevel);
    end
    trials2thresh = iters;
    if tErrorCurrent > opt.errThresh
        disp(['WARNING: threshold not reached for d = ' num2str(dLevel) ', b = ' num2str(b) '.']);
    end
else
    p.Run('itmin', opt.numTrials, 'itmax', opt.numTrials, 'silent', true);
    trials2thresh = [];
end

tEst = p.hist.t;
dLevelEst = 1-tEst;
tError = abs(dLevelEst - dLevel);

bEst = p.hist.b;
bError = abs(bEst - b);

if opt.plot
    plot(tError);
    legend('t error');
    figure;
    plot(bError);
    legend('b error');
end

end
