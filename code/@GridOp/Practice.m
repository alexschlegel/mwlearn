function Practice(go)
% GridOp.Practice
% 
% Description:	practice the task
% 
% Syntax:	go.Practice()
% 
% Updated: 2013-09-24
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

nRun	= GO.Param('exp','runs');
nTrial	= GO.Param('exp','trialperrun');

nPractice	= 0;
bCorrect	= [];

nCriterion	= 10;
chrLog		= {'<color:red>N</color>','<color:green>Y</color>'};

bContinue	= true;
while bContinue
	nPractice	= nPractice + 1;
	
	if go.YesNo('Show the shape/operation mapping?')
		go.Mapping;
	end
	
	kRun	= randFrom(1:nRun);
	kTrial	= randFrom(1:nTrial);
	
	res			= go.Trial(kRun,kTrial);
	strResponse	= conditional(res.correct,'<color:green>Yes!</color>','<color:red>No!</color>');
	
	bCorrect	= [bCorrect; res.correct];
	
	nCount		= min(nCriterion,numel(bCorrect));
	bCorrectC	= bCorrect(end-nCount+1:end);
	nCorrectC	= sum(bCorrectC);
	
	strPerformance	= ['You were correct on ' num2str(nCorrectC) ' of the last ' num2str(nCount) ' trial' plural(nCount,'','s') '.'];
	strLog			= ['<size:0.5>History: ' join(arrayfun(@(k) chrLog{k},double(bCorrectC)+1,'uni',false),' ') ' (' num2str(nPractice) ' total)</size>'];
	
	strFeedback	= [strResponse '\n\n' strPerformance '\n' strLog];
	
	go.Experiment.Show.Text(strFeedback);
	go.Experiment.Window.Flip;
	
	WaitSecs(1);
	
	bContinue	= go.YesNo([strFeedback '\n\nAgain?']);
end

%save the results
	go.Experiment.Info.Set('go','practice_record',bCorrect);
