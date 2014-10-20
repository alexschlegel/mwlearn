function p = Param(varargin)
% MWL.Param
% 
% Description:	get a mwlearn parameter
% 
% Syntax:	p = MWL.Param(f1,...,fN)
% 
% In:
% 	fK	- the the Kth parameter field
% 
% Out:
% 	p	- the parameter value
%
% Example:
%	p = GO.Param('color','back');

% structs to hold param values
strDirBase = '/mnt/tsestudies/wertheimer/mwlearn';
persistent CIP;
persistent AngleP;
persistent WMP;
persistent AssemblageP;


if(nargin == 0)
    p = [];
    return;
end

% choose param struct
strTest = varargin{1};
cField = setdiff(varargin, strTest, 'stable');
switch strTest
    case 'ci'
        if(isempty(CIP))
            InitializeCIP;
        end
        P = CIP;
    case 'angle'
        if(isempty(AngleP))
            InitializeAngleP;
        end
        P = AngleP;
    case 'wm'
        if(isempty(WMP))
            InitializeWMP;
        end
        P = WMP;
    case 'assemblage'
        if(isempty(AssemblageP))
            InitializeAssemblageP;
        end
        P = AssemblageP;
    otherwise
        p = [];
        return;
end

% get paramter value
p = P;
for k=1:numel(cField)
    field = cField{k};
    switch class(field)
        case 'char'
            if isfield(p, field)
                p = p.(field);
            else
                p = [];
                return;
            end
        otherwise
            if iscell(p)    % if we're indexing into a cell
                p = p{field};
            else
                p = [];
                return;
            end
    end
end
    
%-----------------------------------------------------------------------%
    function InitializeCIP
        %--experiment parameters---------------------------------   
        CIP.numTrial = 40;
        CIP.numPractice = 3;
        CIP.dLevelPractice = 0.05;        
        CIP.time = struct(...
            'prompt'    , 2000, ...
            'construct' , 6000, ...
            'test'      , 2500, ...
            'pause'     , 0, ...
            'feedback'  , 1000 ...
            );
        % image parts
        CIP.partsDir = DirAppend(strDirBase, 'images', 'ci');
        CIP.partsExt = 'png';
        
        
        CIP.color = struct(...
            'back', 'gray' , ...
            'fore', 'lightgray', ...
            'text', 'black'  ...
            );
        %--sizes------------------------------------------------
        % Image sizes in visual angle
        CIP.imSize = struct(... 
            'part', 4, ...
            'figure'  , 8);            
        % width of spacer as fraction of part side
        CIP.spacerFrac = 1/2;
        % with of spacer in VA
        CIP.spacerWidth = floor(CIP.imSize.part*CIP.spacerFrac);
        % ** continuation of imSize **
        CIP.imSize.partStrip = 4*CIP.imSize.part + 3*CIP.spacerWidth;
        
        % psychocurve parameters
        CIP.psychocurve = struct(       ...
            'targetFracCorrect', 3/4,   ...
            'baselineFracCorrect', 1/4, ...
            'xstep', 0.01,              ...
            'start_t', 0.975            ...
            );
        % example figure
        CIP.example = horzcat([5; 3; 4; 9], ...
                              [5; 3; 6; 9], ...
                              [2; 3; 4; 9], ...
                              [5; 3; 4; 7]);
    end

%------------------------------------------------------------------------%
    function InitializeAngleP
        %--experiment parameters--------------------------------------
        AngleP.numTrial = 5;
        % practice
        AngleP.numPractice = 0;
        AngleP.minPracticeAngle = 30;
        AngleP.refAngles = [90 60 45 30 20 15 10 8 6 5 4 3 2 1];
        AngleP.maxRotation = 90;
        % instructions
        AngleP.sample = struct( ...
            'image', 44, ...
            'startAngle', 110, ...
            'degRotCorr', -30, ...
            'degRotIncorr', -20, ...
            'correctPos' , 'left', ...
            'color', 'marigold' ...
            );
        % psychocurve parameters
        AngleP.psychocurve = struct(       ...
            'targetFracCorrect', 3/4,   ...
            'baselineFracCorrect', 1/2, ...
            'xmin', 1,                 ...
            'xmax', 90,                 ...
            'xstep', 1,              ...
            'start_t', 0.975            ...
            );
        AngleP.image = struct(...
            'dir', DirAppend(strDirBase, 'images', 'rotate','png'),...
            'ext', 'png'...
            );
        AngleP.image.num = numel(dir(PathUnsplit(AngleP.image.dir, '*', AngleP.image.ext)));
        AngleP.color = MWL.Angle.GetGoodColors;
        AngleP.time = struct(...
            'prompt'    , 2000, ...
            'instruct'  , 1000, ...
            'rotate'    , 5000, ...
            'test'      , 500,  ...
            'pause'     , 2000, ...
            'feedback'  , 1000  ...
            );
    end
%------------------------------------------------------------------------%
    function InitializeWMP
    
    
    end
%------------------------------------------------------------------------%
    function InitializeAssemblageP
    
    
    end
%-----------------------------------------------------------------------%
end