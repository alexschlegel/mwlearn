function s = PaperKeys()
% MWL.Behavioral.PaperKeys
% 
% Description:	get the keys for the paper-based tests
% 
% Syntax:	s = PaperKeys()
% 
% Out:
% 	s	- a struct of keys for the paper-based tests
% 
% Updated: 2015-03-20
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent keys

if isempty(keys)
	keys	= struct(...
				'ravens', struct(...
					'a'	, [7; 4; 3; 1; 8; 4; 2; 6; 7; 3; 8; 7; 7; 6; 4; 8; 5; 1]	, ...
					'b'	, [5; 1; 1; 6; 5; 6; 2; 1; 4; 8; 7; 6; 3; 2; 5; 5; 3; 2]	  ...
					), ...
				'paper_folding', struct(...
					'a'	, {{'a'; 'd'; 'b'; 'd'; 'b'; 'e'; 'a'; 'c'; 'e'; 'e'}}	, ...
					'b'	, {{'c'; 'b'; 'a'; 'e'; 'b'; 'a'; 'e'; 'd'; 'd'; 'c'}}	  ...
					), ...
				'card_rotation', struct(...
					'a'	, {{'d'; 's'; 's'; 'd'; 'd'; 's'; 'd'; 's'; 's'; 's'; 's'; 'd'; 's'; 's'; 's'; 's'; 's'; 'd'; 'd'; 'd'; 's'; 's'; 's'; 'd'; 's'; 's'; 'd'; 's'; 'd'; 'd'; 'd'; 's'; 'd'; 's'; 'd'; 'd'; 's'; 's'; 'd'; 's'; 's'; 'd'; 's'; 's'; 's'; 's'; 'd'; 'd'; 's'; 'd'; 's'; 'd'; 'd'; 's'; 's'; 's'; 'd'; 'd'; 's'; 's'; 'd'; 's'; 'd'; 'd'; 'd'; 'd'; 's'; 's'; 'd'; 's'; 's'; 'd'; 's'; 'd'; 'd'; 's'; 'd'; 'd'; 's'; 's'}}	, ...
					'b'	, {{'s'; 's'; 'd'; 'd'; 's'; 's'; 'd'; 'd'; 's'; 'd'; 'd'; 'd'; 's'; 's'; 's'; 's'; 'd'; 'd'; 's'; 's'; 's'; 's'; 's'; 'd'; 's'; 'd'; 's'; 's'; 'd'; 'd'; 'd'; 's'; 's'; 's'; 's'; 'd'; 'd'; 'd'; 's'; 's'; 'd'; 's'; 's'; 'd'; 's'; 'd'; 'd'; 'd'; 's'; 's'; 'd'; 'd'; 'd'; 'd'; 'd'; 's'; 's'; 's'; 's'; 's'; 'd'; 'd'; 's'; 's'; 's'; 's'; 'd'; 'd'; 'd'; 'd'; 'd'; 's'; 's'; 'd'; 'd'; 'd'; 's'; 's'; 's'; 's'}}	  ...
					), ...
				'surface_development', struct(...
					'a'	, {{'b'; 'a'; 'a'; 'e'; 'b'; 'e'; 'd'; 'a'; 'f'; 'a'; 'a'; 'b'; 'a'; 'b'; 'e'; 'a'; 'c'; 'g'; 'h'; 'a'; 'f'; 'e'; 'c'; 'd'; 'b'; 'a'; 'a'; 'd'; 'c'; 'e'}}	, ...
					'b'	, {{'c'; 'b'; 'e'; 'a'; 'b'; 'a'; 'd'; 'h'; 'c'; 'b'; 'd'; 'b'; 'a'; 'f'; 'g'; 'f'; 'c'; 'd'; 'g'; 'e'; 'c'; 'h'; 'b'; 'd'; 'f'; 'c'; 'g'; 'd'; 'f'; 'h'}}	  ...
					) ...
				);
end

s	= keys;
