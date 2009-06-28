%analyzes snippet data from a tank and makes triangle waves for further
%testing

tank  = 'sensorimotor';
block = inputdlg('block name');
block = block{1};
store = 'Snip';
twid  = inputdlg('triangle width');
twid = eval(twid{1});

tt = tdtOpenTank(tank, block);
strobe = snip2strobe(tt, store);
tdtCloseTank(tt);
twav = strobe2twav(strobe, twid);