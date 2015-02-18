function SyncData()
% MWL.SyncData
% 
% Description:	copy data from the mwlearn/data folder from kohler and koffka
%				to wertheimer
% 
% Syntax:	MWL.SyncData()
% 
% Updated: 2014-11-14
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

cComputerFrom	= {'kohler';'koffka'};
strComputerTo	= 'wertheimer';

%make sure the directories exist
	cDirFrom	= cellfun(@(c) DirAppend('/','mnt','tsestudies',c,'mwlearn','data'),cComputerFrom,'uni',false);
	strDirTo	= DirAppend('/','mnt','tsestudies',strComputerTo,'mwlearn','data');
	
	bFromExist	= cellfun(@isdir,cDirFrom);
	if ~all(bFromExist)
		error('The following directories do not exist:\n%s',join(cDirFrom(~bFromExist),10));
	end
	
	if ~isdir(strDirTo)
		error('The destination directory does not exist:\n%s',strDirTo);
	end

%copy the files
	nComputerFrom	= numel(cComputerFrom);
	for kF=1:nComputerFrom
		strDirFrom	= cDirFrom{kF};
		
		%find the source files
		cPathFrom	= FindFiles(strDirFrom);
		nPathFrom	= numel(cPathFrom);
		
		for kP=1:nPathFrom
			strPathFrom	= cPathFrom{kP};
			strPathTo	= PathChangeBase(strPathFrom,strDirFrom,strDirTo);
			
			if FileExists(strPathTo)
				reSubject	= '^\w\w\[0-9]?.mat$';
				if regexp(PathGetFileName(strPathFrom),reSubject)
				%subject .mat file
				
					%is it already merged?
					if ~MATVarExists(strPathTo,'merged')
					%nope, but is it just a duplicate of the source?
						dFrom	= dir(strPathFrom);
						dTo		= dir(strPathTo);
						
						if dFrom.bytes~=dTo.bytes || dFrom.datenum~=dTo.datenum
						%nope, merge the current and existing subject info structs
							status(sprintf('Merging subject files for %s',PathGetFilePre(strPathFrom)));
							
							ifoSFrom	= MATLoad(strPathFrom,'ifoSubject');
							ifoSTo		= MATLoad(strPathTo,'ifoSubject');
							ifoSubject	= StructMerge(ifoSFrom,ifoSTo);
							merged		= true;
							save(strPathTo,'ifoSubject','merged');
						end
					end
				else
				%something else, make sure the copies match
					dFrom	= dir(strPathFrom);
					dTo		= dir(strPathTo);
					
					if dFrom.bytes~=dTo.bytes || dFrom.datenum~=dTo.datenum
						warning('The following files conflict (not syncing):\n%s\n%s',strPathFrom,strPathTo);
					end
				end
			else
				status(sprintf('Copying to destination: %s',strPathFrom));
				FileCopy(strPathFrom,strPathTo);
			end
		end
	end
