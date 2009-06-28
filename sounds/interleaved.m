clear all
amp = 0.5;

y = [];

% baseline hold period
y = [ y mySound(0,0,1.26) ];

% cue
y = [ y mySound(10000, amp, 0.9) ];

% response
yr = [];
dfdt = (log(10000)-log(4000)) / 3 * 0.09;
dadt = (log(0.5)-log(0.05)) / 3 * 0.09;

logfreq = log(4000):dfdt:log(10000);
logfreq = [logfreq log(10000)*ones(1,15)];
logfreq = logfreq + (rand(size(logfreq))-0.5); % add some noise
logfreq = conv(logfreq, [0.5 0.5]); %low pass
logfreq = logfreq(2:end-1);


logamp = log(0.05):dadt:log(0.5);
logamp = [logamp log(0.5)*ones(1,15)];
logamp = logamp + 0.03*(rand(size(logamp))-0.5); % add some noise
logamp = conv(logamp, [0.5 0.5]); %low pass
logamp = logamp(2:end-1);

freqBuf = [];
ampBuf = [];

for ii = 1:length(logfreq)
    freq = exp(logfreq(ii));
    amp = exp(logamp(ii));
    freqBuf = [freqBuf freq];
    ampBuf  = [ampBuf amp];
    yr = [yr mySound(freq, amp, 0.045) mySound(10000,0.5,0.045)];
end
    
y = [y yr];

sound(y, 44e3)
wavwrite(y,44e3,'interleaved.wav')