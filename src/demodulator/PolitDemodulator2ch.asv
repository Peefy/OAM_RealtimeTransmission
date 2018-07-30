function [QPSK,check] = PolitDemodulator2ch(DatCh3,fs)

initial = zeros(1,7);             %初始值
initial(7) = 1;
feed = [1 0 0 0 1 0 0 1];             %反馈逻辑
politLength = 127;
c1 = ms_gen(initial,feed,politLength);
polit = 2*c1-1;

initial2 = zeros(1,10);             %初始值
initial2(10) = 1;
feed2 = [1 0 0 0 0 0 0 1 0 0 1];             %反馈逻辑
politLength2 = 1023;
c2 = ms_gen(initial2,feed2,politLength2);
polit2 = 2*c2-1;

% fs = 625e6;
fc = 62.5e6;
Rs = 6.25e6;
n1 = fs/fc;
n2 = fc/Rs;

userlength = 1023;
politlength = 127;

framelength = userlength+politlength;

% channel = repmat(ch,4,1);
% start = floor(abs(randn*framelength*n1*n2));
% Dat = channel(start:end)';

Dat = DatCh3;
datalength = length(Dat);
L = floor(datalength/framelength/n1/n2);
cutoff = L*framelength*n1*n2;
% sig = Dat(1:cutoff);

% plot(sig);
%% 相乘去载波

ts = [0:datalength-1]/fs;
carrier = sin(2*pi*fc*ts);
signal2 = Dat.*carrier;

Wp = (fc/2)/(fs/2); % 截止频率
Ws = fc/(fs/2); % 通带频率
Rp = 0.5; % 通带衰减
Rs = 40; % 阻带衰减

[n,Wn] = buttord(Wp,Ws,Rp,Rs);
[b,a] = butter(n,Wn);

mix2 = filter(b,a,signal2);
% [m,index] = min(abs(mix2(n1*n2+1:n1*n2*framelength)));
ZeroMat = reshape(abs(mix2(n1*n2+1:cutoff+n1*n2)),n1*n2,L*framelength);
ZeroVector = sum(ZeroMat');
[~,index] = min(ZeroVector);

inti = mod(index,n1*n2);
if inti == 0
    inti = n1*n2;
end
% inti = 26;
signal1 = sum(reshape(mix2(inti:cutoff+inti-1),n1*n2,L*framelength));
% scatter(signal1,signal1);
Data1 = 2* (signal1 > 0) - 1;

Cornew = zeros(1,(L-1)*framelength-1);
for i = 1:(L-1)*framelength-1
    Cornew(i) = sum(signal1(i:politlength+i-1).*polit);
end

% Cor = xcorr(Data1(1:end-userlength),polit);
Cor = xcorr(Data1(1:end-userlength),polit);
[PoMax2,ind2] = max(abs(Cor));

[PoMax,ind1] = max(abs(Cornew));
Exp = Cornew(ind1)/PoMax;
Demodu = Exp*Data1(ind1+politlength:ind1+framelength-1);

constellation1 = Exp*signal1(ind1+politlength:ind1+framelength-1);
% scatter(constellation,constellation);
% hold on;
check1 = sum(polit2 .* Demodu);



Signal = Dat(ind1*n1*n2+inti:(ind1+framelength)*n1*n2+inti-1);
F = 0:fs/framelength/n1/n2:fs-fs/framelength/n1/n2;
FreRe = real(fft(Signal.^2));
FreIm = imag(fft(Signal.^2));
Fre = abs(fft(Signal.^2));
Fre(1) = 0;
[~,indF] = max(Fre);
phi = atan(FreIm(indF)/FreRe(indF))/2;
% phi = 0;

fc0 = F(indF)/2;

carriernew = sin(2*pi*fc0*ts+phi);
signal2new = Dat.*carriernew;

mix2new = filter(b,a,signal2new);
signal1new = sum(reshape(mix2new(inti:cutoff+inti-1),n1*n2,L*framelength));
Data1new = 2* (signal1 > 0) - 1;


% Exp2 = Cornew2(ind1)/PoMax;
Demodu2 = Exp*Data1new(ind1+politlength:ind1+framelength-1);

constellation2 = Exp*signal1new(ind1+politlength:ind1+framelength-1);
% scatter(constellation2,constellation2);

check2 = sum(polit2 .* Demodu2);

if(min(abs(constellation2))>min(abs(constellation1)))
    constellation = constellation2;
    check = check2;
else
    constellation = constellation1;
    check = check1;
end

% Random = randn;
SIGN = sign(constellation);
sigma = 1;
% if(abs(Random)>0.6)
    constellationnew = max(constellation)*SIGN + sigma * randn(1,length(constellation));
% else
%     constellationnew = constellation;
% end
% constellationnew = constellation;

if mod(length(constellationnew),2) == 0
    QPSK = reshape(constellationnew,2,length(constellationnew)/2);
else
    QPSK = reshape([constellationnew,constellationnew(end)],2,length(constellationnew)/2+0.5);
end