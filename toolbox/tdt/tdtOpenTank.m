function tankHandle = tdtOpenTank( tank, block, server, client )
%tdtOpenTank opens a TDT tank for reading.
%tdtOpenTank( tank, block, server, client )
%   tank = Name of the tank to open (REQUIRED)
%   block = Name of the block to select (defaults to 'Block-1')
%   server = Name of TTank server (defaults to 'Local')
%   client = Name of the client (defaults to 'matlab')
%Returns an ActiveX control with the tank ready to be read. Be sure to
%close the tank and release the server when finished!

switch nargin
    case 0
        disp('Too few arguments!')
        return;
    case 1
        %only tank specified, use default block, server, and client
        block  = 'Block-1';
        server = 'Local';
        client = 'matlab';
    case 2
        %only tank and block specified; use default server and client
        server = 'Local';
        client = 'matlab';
    case 3
        %only tank, block, and server specified; use default client
        client = 'matlab';
end

tt = actxcontrol('TTank.X');

if ( invoke(tt, 'ConnectServer', server, client) ~= 1 )
    warning('Could not connect to server.')
end

if ( invoke(tt, 'OpenTank', tank, 'R') ~= 1 )
    warning('Could not open tank.')
end

if ( invoke(tt, 'SelectBlock', block) ~= 1 )
    warning('Could not select block.')
end

tankHandle = tt;