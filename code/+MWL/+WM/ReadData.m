function ReadData(mwlt, MUData, OSData, SSData, SSTMData, SSTMSumData)
% MWL.WM.ReadData
%
% Description: Reads in data files from working memory battery and stores
%              the data in the experiment info struct.
%              Always reads in the data for the last run.
%
% Syntax: MWL.WM.ReadData(mwlt, MUData, OSData, SSData, SSTMData, SSTMSumData)
%
% In:
%  mwlt - the MWLearnTest experiment object
%  MUData - path to the memory updating data, or empty if not run.
%  OSData - path to the operation span data, or empty if not run.
%  SSData - path so the sentence span data, or empty if not run.
%  SSTMData - path to the spatial short-term memory data, or empty if not run.
%
% Side-effects: Saves info to the experiment info struct for each test run.

% determine which tests have been run
global strDirCode;

runTest.mu = ~isempty(MUData);
runTest.os = ~isempty(OSData);
runTest.ss = ~isempty(SSData);
runTest.sstm = ~isempty(SSTMData);
if runTest.sstm && isempty(SSTMSumData)
    warning('huh? no sum data');
    skipSum = true;
else
    skipSum = false;
end

mwlt.Experiment.Info.Set('mwlt',{'wm','tests'}, runTest);
%------------------------------------------------------------------------------%
% read memory updating data
if runTest.mu
    MUParams = MWL.Param('wm','mu');
    nTrials = MUParams.numTrial;
    nPractice = MUParams.numPractice;
    muInfo = struct('nPos',cell(1,nTrials),'nOp',cell(1,nTrials),'start',cell(1,nTrials),...
        'opLoc',cell(1,nTrials),'op',cell(1,nTrials),'testOrder',cell(1,nTrials),...
        'answer',cell(1,nTrials),'response',cell(1,nTrials), 'bCorrect', cell(1,nTrials));
    
    % read in trial data
    MUTrials = PathUnsplit(DirAppend(strDirCode, 'WMBattery','MU'),'mutrials','txt');
    idMUT = fopen(MUTrials);
    C = textscan(idMUT, ['%*f %u16%u8' repmat('%u16',1,6) repmat('%u8',1,8) ...
        repmat('%d8',1,8) repmat('%u8',1,6) repmat('%u16',1,6)],'HeaderLines',nPractice,'CollectOutput',true);
    fclose(idMUT);
    % format trial data
    for t = 1:nTrials
        muInfo(t).nPos = double(C{1}(t));
        muInfo(t).nOp = double(C{2}(t));
        muInfo(t).start = double(C{3}(t,1:muInfo(t).nPos));
        muInfo(t).opLoc = double(C{4}(t,1:muInfo(t).nOp));
        muInfo(t).op = double(C{5}(t,1:muInfo(t).nOp));
        muInfo(t).testOrder = double(C{6}(t,1:muInfo(t).nPos));
        muInfo(t).answer = double(C{7}(t,1:muInfo(t).nPos));
    end
    
    % read in results
    idMU = fopen(MUData);
    C = textscan(idMU, ['%*f%*f' repmat('%c',1,6)  repmat('%f',1,6)],'CollectOutput',true);
    fclose(idMU);
    % format results
    for t = 1:nTrials
        muInfo(t).response = C{1}(t,1:muInfo(t).nPos);
        muInfo(t).bCorrect = logical(C{2}(t,1:muInfo(t).nPos));
    end
    % save trial data and results
    mwlt.Experiment.Info.Set('mwlt',{'wm','mu'},muInfo);
end
%------------------------------------------------------------------------------------%
% read operation span data
if runTest.os
    OSParams = MWL.Param('wm','os');
    nTrials = OSParams.numTrial;
    
    osInfo = ParseSpanTask(OSData, nTrials);
    
    % save data
    mwlt.Experiment.Info.Set('mwlt',{'wm','os'},osInfo);
    
end
%---------------------------------------------------------------------------------%
% read sentence span data
if runTest.ss
    SSParams = MWL.Param('wm','ss');
    nTrials = SSParams.numTrial;
    
    ssInfo.trial = ParseSpanTask(SSData, nTrials);    
    ssInfo.version = SSParams.version;
    
    % save data
    mwlt.Experiment.Info.Set('mwlt',{'wm','ss'},ssInfo);
    
end
%--------------------------------------------------------------------------------%
% read spatial short-term memory data
if runTest.sstm
    SSTMParams = MWL.Param('wm','sstm');
    nTrials = SSTMParams.numTrial;
    sstmInfo.trial = struct('score',cell(1,nTrials),'rt',cell(1,nTrials),'numDot',cell(1,nTrials),'dots',cell(1,nTrials));
    % read in data
    idSSTM = fopen(SSTMData);
    C = textscan(idSSTM,'%*f%*f%f%f%f',nTrials,'HeaderLines',2);
    for p = 1:5
        fgetl(idSSTM);
    end
    for t = 1:nTrials
        sstmInfo.trial(t).score = C{1}(t);
        sstmInfo.trial(t).rt = C{2}(t);
        sstmInfo.trial(t).numDot = C{3}(t);
        sstmInfo.trial(t).dots = struct('posRes',cell(1,sstmInfo.trial(t).numDot),...
                                        'posRes_transformed',cell(1,sstmInfo.trial(t).numDot),...
                                        'posAns',cell(1,sstmInfo.trial(t).numDot),...
                                        'score',cell(1,sstmInfo.trial(t).numDot));
        D = textscan(idSSTM,['%*f' repmat('%f',1,7) '%*f'],sstmInfo.trial(t).numDot);
        for u = 1:sstmInfo.trial(t).numDot
            sstmInfo.trial(t).dots(u).posRes = horzcat(D{1}(u), D{2}(u));
            sstmInfo.trial(t).dots(u).posRes_transformed = horzcat(D{3}(u), D{4}(u));
            sstmInfo.trial(t).dots(u).posAns = horzcat(D{5}(u),D{6}(u));
            sstmInfo.trial(t).dots(u).score = D{7}(u);
        end
    end
    fclose(idSSTM);
    
    if ~skipSum
        idSSTMSum = fopen(SSTMSumData);
        sstmInfo.maxScore = cell2mat(textscan(idSSTMSum, '%*s%*s%*s%*s%f',1));
        sstmInfo.score = cell2mat(textscan(idSSTMSum, '%*f%f',1));
        sstmInfo.fracScore = sstmInfo.score ./ sstmInfo.maxScore;
        fclose(idSSTMSum);
    end
    mwlt.Experiment.Info.Set('mwlt',{'wm','sstm'},sstmInfo);
end
end
%-----------------------------------------------------------------------------%
%-----------------------------------------------------------------------------%
function taskInfo = ParseSpanTask(dataFile, nTrials)
% Parse data from either OS or SS task.
taskInfo = struct('nLetter',cell(1,nTrials),...
    'letterAns',cell(1,nTrials),'letterResp',cell(1,nTrials),'bLetterCorrect',cell(1,nTrials), 'letterRT',cell(1,nTrials),...
    'sentenceAns',cell(1,nTrials),'sentenceResp',cell(1,nTrials),'bSentenceCorrect',cell(1,nTrials),'sentenceRT',cell(1,nTrials));
% read in data
id = fopen(dataFile);
C = textscan(id, ['%*f%*f %f' repmat('%c',1,16) repmat('%f',1,8)...
    repmat('%d8',1,8) repmat('%d16',1,8) repmat('%f',1,8)], 'CollectOutput',true);
fclose(id);
% format data
for t = 1:nTrials
    taskInfo(t).nLetter = C{1}(t);
    taskInfo(t).letterAns = C{2}(t,1:taskInfo(t).nLetter);
    taskInfo(t).letterResp = C{2}(t,9:taskInfo(t).nLetter + 8);
    taskInfo(t).bLetterCorrect = taskInfo(t).letterAns == taskInfo(t).letterResp;
    taskInfo(t).letterRT = C{3}(t,1:taskInfo(t).nLetter);
    taskInfo(t).sentenceAns = logical(C{4}(t,1:taskInfo(t).nLetter));
    taskInfo(t).sentenceResp = double(C{5}(t,1:taskInfo(t).nLetter));
    taskInfo(t).sentenceResp(taskInfo(t).sentenceResp==-9) = NaN; % set 'no response' to NaN
    taskInfo(t).bSentenceCorrect = taskInfo(t).sentenceAns == taskInfo(t).sentenceResp;
    taskInfo(t).sentenceRT = C{6}(t,1:taskInfo(t).nLetter);
end
end
