function score = Folding(data,testType)
% MWL.Rating.Folding
% 
% Description:	score a paper folding test, given the subject responses
% 
% Syntax:	score = Folding(data,testType)
% In:
% 	data		- an numerical array of the subject responses (1 through 10)
%	testType	- the folding test type ('A' or 'B')
% 
% What do I want to do?
% Take data in, separate by a and b
% repmat as in raven's case
% sizes should match because some have done all 10 (not a good excuse...)
% then convert 0 to -1 after ==
% then sum and make sure sum along right dimension
%
%
% Test A key: [a d b d b e a c e e]
% Test B key: [c b a e b a e d d c]
%
%
switch testType
    case 'a'
        rawkey = [a d b d b e a c e e];
    case 'b'
        rawkey = [c b a e b a e d d c];
end

%
%
%
%
% Out:
% 	score	- the test score
% 
% Updated: 2015-03-05
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
