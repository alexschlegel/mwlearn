function troubleMakers()
% MWL.troubleMakers;
%
% Description: Finds the people with messed up behavioral sessions
%
% Syntax:  MWL.TroubleMakers();
% 
% In:
% Out:
%
%
% Notes:

ifo = MWL.GetSubjectInfo;
loadThis = ifo.path.session.behavioral;
nSubs = length(ifo.n);
goodFieldNames = {'session'; 'tests'; 'ci'; 'angle'; 'assemblage'; 'wm'};

for subject = 1:nSubs
    for session = 1:2
        if ~ isempty(loadThis{subject, session})
        s = load(loadThis{subject, session});
        names = fieldnames(s.PTBIFO.mwlt);            
            if isequal(names, goodFieldNames)
                disp(['subject ' num2str(subject) ', session ' num2str(session) ' is OK.']);
            else
                disp(['subject ' num2str(subject) ', session ' num2str(session) ' is a TROUBLEMAKER!']);
            end
        else
            disp(['subject ' num2str(subject) ', session ' num2str(session) ' is missing.']);
        end
    end
end