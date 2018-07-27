function [demodu, check] = Demodulator(Dat_Ch2, fs)

fc = 62.5e6;
Rs = 6.25e6;
n1 = fs/fc;
n2 = fc/Rs;

framelength = 1023;
zerolength = 177;

Dat = Dat_Ch2;
datalength = length(Dat);
L = floor(datalength/(framelength+zerolength)/n1/n2);
cutoff = L*framelength*n1*n2;
sig = Dat(1:cutoff);

initial = zeros(1,10);             %³õÊ¼Öµ
initial(10) = 1;
feed = [1 0 0 0 0 0 0 1 0 0 1];             %·´À¡Âß¼­
politLength = 1023;
c1 = ms_gen(initial,feed,politLength);
polit = 2*c1-1;

%% ÕÒzeros
datMat = reshape(sig,n1,cutoff/n1);
datSum = sum(abs(datMat'));
[~,ind] = min(datSum);
signal = Dat(ind:end);

%% Ïà³ËµÍÍ¨ÂË²¨
ts = [0:datalength-ind]/fs;
carrier = sin(2*pi*fc*ts);
signal2 = signal.*carrier;
T = zeros(1,n1);
for i=1:n1
    signal2mat = reshape(signal2(i:i-1+cutoff),n1*n2,L*framelength);
    T(i) = sum(abs(sum(signal2mat)));
end

[~,index] = max(T);
Data = sum(reshape(signal2(index:index-1+cutoff),n1*n2,L*framelength));

%%
ZL = zerolength;
zerotemp = zeros(1,cutoff/n1/n2);
for i=1:ZL
    zerotemp = zerotemp + circshift(abs(Data),[0,-1]);
end
[~,ind] = min(zerotemp);

%% Ïà³ËµÍÍ¨ÂË²¨
user = Data(ind+zerolength:(framelength+zerolength)+ind-1);

% demodu = 2*(user>0) - 1;
demodu = user;

check = sum((2*(demodu > 0)-1).*polit);
