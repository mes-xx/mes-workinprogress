% function [freq,power]=arspec(y,fsamp,order,Nfreq)
% this part of the code to determine the power spectrum given the AR
% parameters and the error
% Spectrum(f)=e(L)/1+A(L,1)*exp(-j*2*Pi*f/Fs)+ ...+A(L,L)*exp(-j2*Pi*f*L/Fs)^2

function [power,freq]=arspec(y,order,Nfreq)

power=zeros(Nfreq,1);freq=power;
[a,e]=Burg(y,order);

for i=1:Nfreq
    den=0;
    for k=2:order+1
        den=a(k)*exp(-j*2*pi*(i-1)*(k-1)/Nfreq)+den;
    end
    power(i)=e(order)/abs(1+den)^2;freq(i)=i;
end
