function [constellation, check] = PolitDemodulator(Dat_Ch2, fs)

initial = zeros(1,7);             %初始值
initial(7) = 1;
feed = [1 0 0 0 1 0 0 1];             %反馈逻辑
politLength = 127;
c1 = ms_gen(initial,feed,politLength);
polit = 2*c1-1;

% initial2 = zeros(1,10);             %初始值
% initial2(10) = 1;
% feed2 = [1 0 0 0 0 0 0 1 0 0 1];             %反馈逻辑
% politLength2 = 1023;
% c2 = ms_gen(initial2,feed2,politLength2);
% polit2 = 2*c2-1;

politLength2 = 32768;

% fs = 625e6;
fc = 62.5e6;
Rs = 6.25e6;
n1 = fs/fc;
n2 = fc/Rs;

userlength = 32768;
politlength = 127;

framelength = userlength+politlength;

% channel = repmat(ch,4,1);
% start = floor(abs(randn*framelength*n1*n2));
% Dat = channel(start:end)';

Dat = Dat_Ch2;
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
[m,index] = min(abs(mix2(n1*n2+1:n1*n2*framelength)));
inti = mod(index,n1*n2);
if inti == 0
    inti = n1 * n2;
end
signal1 = sum(reshape(mix2(inti:cutoff+inti-1),n1*n2,L*framelength));
Data1 = 2* (signal1 > 0) - 1;

Cor = xcorr(Data1(1:end-userlength),polit);

[PoMax,ind1] = max(abs(Cor));

Exp = Cor(ind1)/PoMax;

% Depolit = Data1(end-framelength-ind1+1:end-userlength-ind1);
% Exp = sign(sum(Depolit.*polit));
% demodu = Exp*Data1(end-userlength-ind1+1:end-ind1);

Demodu = Exp*Data1(ind1-(L-1)*framelength+1:ind1-(L-1)*framelength+userlength);

constellation = Exp*signal1(ind1-(L-1)*framelength+1:ind1-(L-1)*framelength+userlength);
check = 1023;
%check = sum(polit2 .* Demodu);