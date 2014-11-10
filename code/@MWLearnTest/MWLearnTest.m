classdef MWLearnTest < PTB.Object
% MWLearnTest
%
% Description: A test battery for mwlearn participants.
%              Consists of the following components:
%                   -- CI object construction test ('ci')
%                   -- Mental rotation angle test  ('angle')
%                   -- Working memory test battery (Lewandowsky et al.
%                   2010) ('wm')
%                   -- Assemblage mental imagery test ('assemblage')
%
% Syntax: mwlt = MWLearnTest(<options>)
%
%           subfunctions:
%               Start(<options>):   start the object
%               End:                end the object
%               Run(<options>):     execute a mwlearntest run
%                   RunCI(<options>)
%                   RunAngle(<options>)       helper functions that 
%                   RunWM(<options>)          call mwlt.Run
%                   RunAssemblage(<options>)
%
% In:
%   
%   <options>:
%           debug:   (0) the debug level (0, 1 or 2)
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
                'debug'     ,   0  ...
                );
            opt.name = 'mwlearntest';
            opt.context = 'psychophysics';
            opt.input_scheme = 'lrud';
            opt.disable_key = false;
            opt.background = MWL.Param('ci','color','back');
                                    
            % options for the PTB.Experiment object
            cOpt = opt2cell(opt);
            
            % get existing subjects
            global strDirData
            cSubjectFiles = FindFiles(strDirData, '^\w\w\w?\w?\.mat$');
            
            % initialize the experiment
            mwlt.Experiment = PTB.Experiment(cOpt{:});
            
            % infer session
            if opt.debug > 0
                opt.session = 0;
            else
                subInit = mwlt.Experiment.Info.Get('subject','init');
                % check whether a subject file exists for this experiment
                bPreDefault = ~any(strcmp(cSubjectFiles,PathUnsplit(strDirData, subInit, 'mat')));
                opt.session = NaN;
                mwlt.Experiment.Scheduler.Pause;  % so that prompt doesn't get covered by log entries
                while isnan(opt.session)
                    strSession = mwlt.Experiment.Prompt.Ask('Select session:',...
                        'choice',{'pre','post'},'default', ...
                        conditional(bPreDefault,'pre','post'));
                    switch strSession
                        case 'pre'
                            opt.session = 1;
                        case 'post'
                            opt.session = 2;
                        otherwise
                            continue
                    end
                end
                mwlt.Experiment.Scheduler.Resume;
            end
                    
            % set the session
            mwlt.Experiment.Info.Set('mwlt','session', opt.session);
            
            % initialize tests run to false
            mwlt.Experiment.Info.Set('mwlt','tests', struct(...
                'ci', false, 'angle', false, 'wm', false, 'assemblage', false));
            
         end      
        %----------------------------------------------------------------------%
        function End(mwlt,varargin)
            % end the mwlearntest object
            v = varargin;
            
            mwlt.Experiment.End(v{:});
        end
    end
    

end