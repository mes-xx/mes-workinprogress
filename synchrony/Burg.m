%[A,E,K]=burg(x,p,Fs)
%Burg AR modeling
%
%Output
% A:AR parameters matrix, the pth row is the final set of p AR parameters
% i.e. A=[1 A1 A2...Ap];
% e(n)=y(n)+A1*y(n-1)+A2*y(n-2)+...+Ap*y(n-p);
% E:error variance vector=[E(0),E(1),E(2),...,E(p)];
% E(p) is useful in calculating power spectrum
% K:a raw vector of reflection coefficients at each calculating step
% (from 1 to order p)
%
%Input
% p:AR order of prediction
% N:signal segment length
% x:signal column vector

function [A,E,K]=Burg(y,p)
% initialization
A=zeros(p+1,p+1);
K=zeros(1,p);
E=zeros(1,p);
N=length(y); % y is a raw vector

Rxx=(y*y')/N;
ef=y; % ef(n)=y(n)
eb=y; % eb(n)=y(n)
L=1;
DEN=y(2:N)*y(2:N)'+y(1:N-1)*y(1:N-1)';
Num=y(2:N)*y(1:N-1)';
K(1)=2*Num/DEN; %K(L)=-R(L)
A(1,1)=-K(1);
E(1)=Rxx*(1-K(1)^2);
ef(2:N)=y(2:N)-K(1)*y(1:N-1);
eb(1:N-1)=y(1:N-1)-K(1)*y(2:N);

% Calculation
for L=2:p
    Num=ef(L+1:N)*eb(1:N-L)';
    Den=ef(L+1:N)*ef(L+1:N)'+eb(1:N-L)*eb(1:N-L)';
    K(L)=2*Num/Den;
    E(L)=E(L-1)*(1-K(L)^2);
    A(L,L)=-K(L);
    for j=1:L-1,
        A(L,j)=A(L-1,j)-K(L)*A(L-1,L-j);
    end;
    efm=ef;ebm=eb;
    ef(L+1:N)=efm(L+1:N)-K(L)*ebm(1:N-L);
    eb(1:N-L)=ebm(1:N-L)-K(L)*efm(L+1:N);
end;
B=zeros(p+1,p+1);B(:,1)=ones(p+1,1);B(2:p+1,2:p+1)=A(1:p,1:p);
A=B(p+1,:);
