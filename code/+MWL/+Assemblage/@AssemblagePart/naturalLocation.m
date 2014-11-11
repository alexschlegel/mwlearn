function strLocation = naturalLocation(part,varargin)
% AssemblagePart.naturalLocation
% 
% Description:	construct a string describing the location of the part
% 
% Syntax:	strLocaion = part.naturalLocation([excludePart]=NaN,[excludeNeighbor],NaN)
% 
% In:
% 	[excludePart]		- a part to exclude from the process
%	[excludeNeighbor]	- a neighbor to exclude from the process
% 
% Updated: 2014-11-11
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[excludePart,excludeNeighbor]	= ParseArgs(varargin,NaN,NaN);

if ~isequalwithequalnans(excludePart,NaN)
	excludePart	= part.assemblage.part(excludePart).param.idx;
end

if ~isequalwithequalnans(excludeNeighbor,NaN)
	excludeNeighbor	= part.assemblage.part(excludeNeighbor).param.idx;
end

loc		= '';
sep		= ' ';
extra	= '';

nPart	= part.assemblage.partCount(part.part,excludePart);
if nPart==1
	%unique!
	sep	= '';
else %try for something like "bottom-leftmost"
	iPart	= part.assemblage.findPart(part.part, excludePart);
	iMe		= part.param.idx;
	iOther	= setdiff(iPart,iMe);
	nOther	= numel(iOther);
	
	gridMe		= part.param.grid;
	gridOther	= arrayfun(@(idx) part.assemblage.part(idx).param.grid,iOther,'uni',false);
	gridOx		= cellfun(@(g) g(1),gridOther);
	gridOy		= cellfun(@(g) g(2),gridOther);
	
	mnX = min(gridOx);
	mxX = max(gridOx);
	mnY = min(gridOy);
	mxY = max(gridOy);
	
	hAbs	= NaN;
	if gridMe(1)==mnX && gridMe(1)==mxX
		h	= NaN;
	elseif gridMe(1) <= mnX
		h		= 'left';
		hAbs	= conditional(gridMe(1)~=mnX,h,hAbs);
	elseif gridMe(1) >= mxX
		h		= 'right';
		hAbs	= conditional(gridMe(1)~=mxX,h,hAbs);
	else
		h	= NaN;
	end
	
	vAbs	= NaN;
	if gridMe(2)==mnY && gridMe(2)==mxY
		v	= NaN;
	elseif gridMe(2) <= mnY
		v		= 'top';
		vAbs	= conditional(gridMe(2)~=mnY,v,vAbs);
	elseif gridMe(2) >= mxY
		v		= 'bottom';
		vAbs	= conditional(gridMe(2)~=mxY,v,vAbs);
	else
		v	= NaN;
	end
	
	if ~isequalwithequalnans(h,NaN) && ~isequalwithequalnans(v,NaN)
		loc	= sprintf('%s-%s',v,h);
	elseif ~isequalwithequalnans(hAbs,NaN)
		loc	= hAbs;
	elseif ~isequalwithequalnans(vAbs,NaN)
		loc	= vAbs;
	elseif nOther==2
		loc	= 'middle';
	else %gettin' weird
		sep			= '';
		
		neighbors	= [];
		nAttachment	= numel(part.param.attachment);
		for kA=1:nAttachment
			nbr	= part.param.attachment(kA);
			if ~isequalwithequalnans(nbr,NaN) && excludePart~=nbr && excludeNeighbor~=nbr
				neighbors(end+1)	= nbr;
			end
		end
		nNeighbor	= numel(neighbors);
		
		%this should only happen when a weird part has a weird dangler, in
		%which case this function is being called from naturalRelativeLocation,
		%in which case the current part probably isn't a good candidate to
		%include in the other part's location name
			if nNeighbor==0
				strLocation	= NaN;
				return
			end
		
		possibleExtra	= {};
		for kN=1:nNeighbor
			nbr	= neighbors(kN);
			str	= part.naturalRelativeLocation(nbr,true,excludePart);
			
			if ~isequalwithequalnans(str,NaN)
				possibleExtra{end+1}	= str;
			end
		end
		
		extraLength	= cellfun(@numel,possibleExtra);
		mnLength	= min(extraLength);
		extra		= possiblExtra(find(extraLength==mnLength,1));
		
		extra = sprintf(' %s',extra);
	end
end

strLocation	= sprintf('%s%s%s%s',loc,sep,part.part,extra);
