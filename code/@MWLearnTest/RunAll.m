function RunAll(mwlt)
% RunAll
%
% Description: Run all mental workspace tests
%
% Syntax: mwlt.RunAll

mwlt.RunCI;
mwlt.RunAngle;
mwlt.RunAssemblage;
mwlt.RunWM('lock',false);

end