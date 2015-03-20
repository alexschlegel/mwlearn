function score = Ravens(data,testType)
% MWL.Rating.Ravens
% 
% Description:	score a Ravens test, given the subject responses
% 
% Syntax:	score = Ravens(data,testType)
% 
% What do I want to do?
% have input data and input test type
%   Do I simply use PrepMWL here?
% ifo = ??
% fix input data so that all variables (but not needed if simple comparison
% (==)?
% is fill in necessary to get same size data across all id and to get same
%   key for all? answer = no by test run
% then have a scoring function
%   compare input for each subject with same answer key
% will have to reshape and copy answer key over and over to get comparisons
%   will also have to sum (function) along each id to get individual scores
%   within a larger "matrix"
%
% to get individual score - match id with place in this "matrix" -
%   separate thing...
%
% Potential functions: struct - to organize which test scored (do raven's
% for now...)
% reshape answer key
% copy answer key over to match size of input data
% == function
% (eventually, a -1 function for other tests besides Raven's)
%
% Important side note: How could I modify this function in case no one
% finishes the last question (ie. size of data file would not match size of
% answer key)?!?!?
% 
%  Test A key: [7,4,3,1,8,4,2,6,7,3,8,7,7,6,4,8,5,1]
%  Test B key: [5,1,1,6,5,6,2,1,4,8,7,6,3,2,5,5,3,2]
%
%
%
% Prereq Steps
% data =
% importdata(/mnt/tsestudies/wertheimer/mwlearn/data/behavioral/card_rotation_a_responses.xls)
% use data.data as input
%
%
% So use case to separate which answer key to be used and reshaped to match
%   input data after running the switch function

switch testType
    case 'a'
        rawkey = [7,4,3,1,8,4,2,6,7,3,8,7,7,6,4,8,5,1];
    case 'b'
        rawkey = [5,1,1,6,5,6,2,1,4,8,7,6,3,2,5,5,3,2];
end

repeats = size(data);

reformat = repeats(1);

keyfull = repmat(rawkey,reformat,1);

comparison = keyfull == data;

score = sum(comparison,2);



% Other option??
%if testType == 'a'
%    rawkey = [7,4,3,1,8,4,2,6,7,3,8,7,7,6,4,8,5,1];
%elseif testType == 'b'
%    rawkey = [5,1,1,6,5,6,2,1,4,8,7,6,3,2,5,5,3,2];
%else disp('error')
%end



% In:
% 	data		- an numerical array of the subject responses (1 through 8)
%	testType	- the Ravens test type ('A' or 'B')
% 
% Out:
% 	score	- the test score
% 
% Updated: 2015-03-05
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
