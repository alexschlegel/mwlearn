function addEvent(a,eventType,info)
% Assemblage.addEvent
% 
% Description:	add an event to the Assemblage history
% 
% Syntax:	a.addEvent(eventType,info)
% 
% In:
% 	eventType	- a string describing the eventType
%	info		- extra info to store with the event
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
a.history{end+1}	= {eventType, info};

switch eventType
	case 'add'
		el	= a.part(info);
		
		action	= conditional(~isequalwithequalnans(unless(GetFieldPath(el.param,'parent'),NaN),NaN),'Add','Imagine');
		thing	= el.naturalDefinition;
		instruct	= sprintf('%s %s %s',action,aan(thing),thing);
	case 'remove'
		el	= a.part(info);
		instruct	= sprintf('Remove the %s',el.naturaLocation);
	case 'rotate'
		%instruct	= ['Rotate the ' a.naturalName() ' ' naturalangle(info)];
		instruct	= ['Rotate ' naturalangle(info)];
	otherwise
		error('Invalid event type');
end

a.instruction{end+1}	= instruct;
