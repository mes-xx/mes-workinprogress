function debugdisp( str )
%DEBUGDISP displays date, time and the input string if global DEBUG_TEXT=1

global DEBUG_TEXT;

if isempty(DEBUG_TEXT)
    warning('DEBUG_TEXT is empty. You should set it before calling debugdisp(). Defaulting to DEBUG_TEXT=1.')
    DEBUG_TEXT = 1;
end

if DEBUG_TEXT
    disp([ sprintf('%04d/%02d/%02d %02d:%02d:%02.0f',clock) ' ' str ])
end