classdef MWLearnTest < PTB.Object
% MWLearnTest
%
% Description: A test battery for mwlearn participants.
%              Consists of the following components:
%                   -- CI object construction test
%                   -- Mental rotation angle test
%                   -- Working memory test battery (Lewandowsky et al. 2010)
%                   -- Assemblage mental imagery test
%
% Syntax: mwlt = MWLearnTest(<options>)
%
%           subfunctions:
%               Start(<options>):   start the object
%               End:                end the object
%               Prepare:            prepare necessary info 
%               Run(<options>):`    execute a mwlearntest run
%
% In:
%   
%   <options>:
%           state:   ('d2') the debug level or session
%                       'd2' = debug level 2
%                       'd1' = debug level 1
%                      'pre' = pretest session (debug level 0)
%                     'post' = posttest session (debug level 0)
%
% Updated: 2014-09-30

    % PUBLIC PROPERTIES---------------------------------------------%
    properties
        Experiment;
    end
    % PUBLIC PROPERTIES--------------------------------------------%
    
    % PRIVATE PROPERTIES-------------------------------------------%
    properties (SetAccess=private, GetAccess=private)
        argin;
    end
    % PRIVATE PROPERTIES-------------------------------------------%
    
    % PUBLIC METHODS-----------------------------------------------%
    methods
        function mwlt = MWLearnTest(varargin)
            mwlt = mwlt@PTB.Object([],'mwlearntest');
            mwlt.argin = varargin;
            
            % parse the inputs
            opt = ParseArgs(varargin, ...
                'state'     ,   'd2'  ...
                );
            opt.name = 'mwlearntest';
            opt.context = 'psychophysics';
            opt.input_scheme = 'lrud';
            opt.background = MWL.Param('ci','color','back');
            
            % set debug and session
            switch opt.state
                case 'd2'
                    opt.debug = 2;
                    opt.session = 0;
                case 'd1'
                    opt.debug = 1;
                    opt.session = 0;
                case 'pre'
                    opt.debug = 0;
                    opt.session = 1;
                case 'post'
                    opt.debug = 0;
                    opt.session = 2;
                otherwise
                    error('Invalid state');
            end
                                    
            % options for the PTB.Experiment object
            cOpt = Opt2Cell(opt);
            
            % initialize the experiment
            mwlt.Experiment = PTB.Experiment(cOpt{:});
            
            % set the session
            mwlt.Experiment.Info.Set('mwlt','session', opt.session);
            
            % initialize tests run to false
            mwlt.Experiment.Info.Set('mwlt','tests', struct(...
                'ci', false, 'angle', false, 'wm', false, 'assemblage', false));
            
            % start
            mwlt.Start;
        end
        %----------------------------------------------------------------------%
        function Start(mwlt,varargin)
            % start the mwlt object
            mwlt.argin = append(mwlt.argin, varargin);
        end
        %----------------------------------------------------------------------%
        function End(mwlt,varargin)
            % end the mwlearntest object
            v = varargin;
            
            mwlt.Experiment.End(v{:});
        end
    end
    

end