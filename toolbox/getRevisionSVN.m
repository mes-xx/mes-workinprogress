function [ output ] = getRevisionSVN( pathToWorkingCopy )
%GETSVNREVISION Gets Subversion revision number for given working directory
%   output = getRevisionSVN( pathToWorkingCopy )
%   output is some text that includes information on what revision we are
%   using. The function assumes that TortoiseSVN is installed to C:\Program
%   Files\TortoiseSVN.

% Assume TortoiseSVN is installed in the defualt directory
[errorCode, output] = dos(['"C:\Program Files\TortoiseSVN\bin\SubWCRev.exe" ' pathToWorkingCopy]);
% Call the TortiseSVN tool to find the revision number

if ( errorCode )
    error(['SubWCRev.exe exited with error code ' num2str(errorCode) ': ' output]);
end