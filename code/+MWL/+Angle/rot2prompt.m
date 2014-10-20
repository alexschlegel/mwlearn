function [strAngle, strDirection] = rot2prompt(nDegRot)
% MWL.Angle.rot2prompt
%
% Description: converts a signed integer for the degrees of rotation into
%              an unsigned string (including the degree symbol) and a
%              clockwise or counterclockwise indicator.
%
% Syntax: [strAngle, imArrow] = rot2prompt(mwlt, nDegRot)
%
% In:
%    nDegRot - a signed integer signifying the degrees to rotate (CW =
%              positive)
%
% Out:
%     strAngle - an unsigned string, including the degree symbol, signifying
%               the absolute amount to rotate.
% strDirection - the direction to rotate, either "CW" for clockwise or "CCW
%                for counter-clockwise.
textSizeVA = 1.5;
if nDegRot > 0
    strDirection = ['<size:' num2str(textSizeVA) '>CW</size>'];
else
    strDirection = ['<size:' num2str(textSizeVA) '>CCW</size>'];
end

strAngle = ['<size:' num2str(textSizeVA) '>' num2str(abs(nDegRot)) '°</size>'];
    