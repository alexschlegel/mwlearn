% This program forms part of the Working Memory Capacity Battery, 
% written by Stephan Lewandowsky, Klaus Oberauer, Lee-Xieng Yang, and Ullrich Ecker. 
% The WMCBattery is available online at the website of the Cognitive Science
% Laboratories of the University of Western Australia's School of Psychology:
% http://www.cogsciwa.com ("Software" button on main menu).
% Conditions of Use: Using the WMCBattery is free of charge but the authors 
% request that the associated paper be cited (add details later) 
% when publications arise out of data collection with the WMCBattery. 
% The authors do not guarantee the WMCBattery's functionality. 
% This task requires Matlab version 7.5 (2007b) or higher and the 
% Psychophysics Toolbox version 2.54 or 3.0.8. 
%
% Modified by Ethan Blackwood 10/29/14
%
% Syntax: [MUData, OSData, SSData, SSTMData SSTMDataSum] = WMCBattery(<options>)
%   
% In:
%   mwlt - the MWLearnTest experiment object
%   params - a struct of parameters for each task, read in from MWL.Param
%   <options>:
%       (true if no options specified, false otherwise) run_mu - Run the memory updating task
%       (ditto) run_os - Run the operation span task
%       (ditto) run_ss - Run the sentence span task
%       (ditto) run_sstm - Run the spatial short-term memory task
% Out:
%   MUData, OSData, SSData, SSTMData, SSTMDataSum - paths to the output of each task, or
%   an empty arrray if the task was not run.

function [MUData, OSData, SSData, SSTMData, SSTMDataSum] = WMCBattery(mwlt, params, varargin)
%clear all;
global ptb3
% determine which tasks to run.
opt = ParseArgs(varargin, 'run_mu', false, 'run_os', false, 'run_ss', false, 'run_sstm', false);
if nargin == 2
    opt = structfun(@(f) ~f, opt, 'uni',false);
end

try %to catch errors
    
    %determine which version of sentence span. Choices are:
    % easy
    % hard
    % chinese
    SSversion = params.ss.version;
    if strcmp(SSversion, 'chinese')
        iDir = 'ChineseInstructions/';
    else
        iDir = 'EnglishInstructions/';
    end

    %determine response keys
    expinfo.yeskey = 'slash';          %e.g., for right arrow: 'right';
    expinfo.nokey = 'Z';           %e.g., for left arrow: 'left';
    
    yesno{1}=expinfo.yeskey;
    yesno{2}=expinfo.nokey;         

    %::::::::::::::::: add shared function directory to path
    ptb3=-1;
    fnDir = DirAppend(cd, 'sharedFuns');
    preserveLW = lastwarn;
    lastwarn('');
    addpath(fnDir)
    if strmatch ('Name is nonexistent or not a directory',lastwarn)
        fnDir='';
        error('Faulty WMCBattery installation: Directory ''sharedFuns'' not found')
    end
    lastwarn(preserveLW);

    %::::::::::::::::: get subject number, and set up screen
    getptb;
    screenparms = prepexp(mwlt);
    subject=1;


%     %initial instructions
%     InitInstruct=[iDir 'InitInstruct.jpg'];
%     ima=imread(InitInstruct, 'jpg');
%     dImageWait;
    
    if opt.run_mu
        %display MU instructions and run task
        MUInstruct1=[iDir 'MUInstruct1.jpg'];
        ima=imread(MUInstruct1, 'jpg');
        dImageWait;
        MUInstruct2=[iDir 'MUInstruct2.jpg'];
        ima=imread(MUInstruct2, 'jpg');
        dImageWait;
        if ~strcmp(SSversion, 'chinese')  %one more page for English
            MUInstruct3=[iDir 'MUInstruct3.jpg'];
            ima=imread(MUInstruct3, 'jpg');
            dImageWait;
        end
        cd 'MU'
        [rc, MUData] = MU(subject,screenparms,params.mu);
        cd '..'
        if rc<0, return, end;
    else
        MUData = [];
    end
    
    
    if opt.run_os
        %display OS instructions and run task
        cls(screenparms);
        OSInstruct1=[iDir 'OSInstruct1.jpg'];
        ima=imread(OSInstruct1, 'jpg');
        dImageWait;
        OSInstruct2=[iDir 'OSInstruct2.jpg'];
        ima=imread(OSInstruct2, 'jpg');
        dImageWait;
        cd 'OS'
        [rc, OSData] = OS(subject,screenparms,yesno,params.os);
        cd '..'
        if rc<0, return, end;
    else
        OSData = [];
    end
    

    if opt.run_ss
        %display SS instructions and run task
        switch (SSversion)
            case {'hard','chinese'}
                cls(screenparms);
                SSInstruct1=[iDir 'SSInstruct1.jpg'];
                ima=imread(SSInstruct1, 'jpg');
                dImageWait;
                SSInstruct2=[iDir 'SSInstruct2.jpg'];
                ima=imread(SSInstruct2, 'jpg');
                dImageWait;
            case 'easy'
                SSeasyInstruct1=[iDir 'SSeasyInstruct1.jpg'];
                ima=imread(SSeasyInstruct1, 'jpg');
                dImageWait;
                SSeasyInstruct2=[iDir 'SSeasyInstruct2.jpg'];
                ima=imread(SSeasyInstruct2, 'jpg');
                dImageWait;
        end
        cd 'SS'
        [rc, SSData] = SS(params.ss,subject,screenparms,yesno,SSversion);
        cd '..'
        if rc<0, return, end;
    else
        SSData = [];
    end
    
    
    if opt.run_sstm
        %display SSTM instructions and run task
        cls(screenparms);
        SSTMInstruct1=[iDir 'SSTMInstruct1.jpg'];
        ima=imread(SSTMInstruct1, 'jpg');
        dImageWait;
        SSTMInstruct2=[iDir 'SSTMInstruct2.jpg'];
        ima=imread(SSTMInstruct2, 'jpg');
        dImageWait;
        cd 'SSTM'
        [rc, SSTMData, SSTMDataSum] = SSTM(subject,screenparms,params.sstm);
        cd '..'
        if rc<0, return, end;
    else
        SSTMData = [];
        SSTMDataSum = [];
    end

    %::::::::::::::: normal program termination
    shutDown;


catch errNo
    if strfind(errNo.message,'PsychtoolboxVersion')
        disp('Psychtoolbox not installed. WMCBattery cannot be run');
        return;
    end

    if ptb3>-1, shutDown; end
    if strfind(errNo.message,'User terminated')
        disp(errNo.message);
        return;    %no need for error message if user pressed F12
    end
    if strfind(errNo.message,'does not exist')
        ME = MException('WMC:Installation', 'Faulty WMCBattery installation: Instructions not found');
        throw(ME)
    end
    if strfind(errNo.message,'Cannot CD')
        ME = MException('WMC:Installation', 'Faulty WMCBattery installation: Task folder not found');
        throw(ME)
    end

    rethrow(errNo); %having shut down properly, continue with MatLab error
end


%:::::::::::::: embedded auxiliary functions
    function shutDown
        if ptb3, ListenChar(1); end
        mwlt.Experiment.Show.Blank;
        mwlt.Experiment.Window.Flip;
        fclose('all');
        rmpath(fnDir);
        while KbCheck; end
        FlushEvents('keyDown');
    end

    function dImageWait
        if ptb3
            Screen('PutImage', screenparms.window, ima);
            Screen('Flip', screenparms.window);          
        else
            Screen(screenparms.window, 'PutImage', ima); % put image on screen
        end
        while KbCheck; end      %clear keyboard queue
        KbWait;                 %wait for any key
        cls(screenparms);
    end
end
