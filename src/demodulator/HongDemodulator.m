function [testres, result] = HongDemodulator(chdata)

initial = zeros(1,7);             %初始值
initial(7) = 1;
feed = [1 0 0 0 1 0 0 1];             %反馈逻辑
politLength = 127;
c1 = ms_gen(initial,feed,politLength);
polit = 2*c1-1; %导频

initial2 = zeros(1,10);             %初始值
initial2(10) = 1;
feed2 = [1 0 0 0 0 0 0 1 0 0 1];             %反馈逻辑
politLength2 = 1023;
c2 = ms_gen(initial2,feed2,politLength2);
polit2 = 2*c2-1; %数据

userlength = 1023;
 politlength = 127;

num=length(chdata);  %数据长度
fs=625e6;    %采样频率
fc=62.5e6;     %载波频率

df=2000;    %初始频偏
ts=1/fs;
%本地VCO的增益，也相当于最大捕获频偏
K0=10e3;    
 c1=3.11e-1;
 c2=12.39e-11;
%设计IIR低通滤波器
N=3;    %滤波器阶数
R=60;   %阻带衰减(dB)
Wn=62.5e6; %截止频率
[lpf_b,lpf_a]=cheby2(N,R,Wn*2/fs);

%本地载波输出信号初值
o_sin=sin(2*pi*fc*(0:num-1)*ts);
o_cos=cos(2*pi*fc*(0:num-1)*ts);
%乘法运算输出信号初值
mult_i=zeros(1,num);
mult_q=zeros(1,num);
%鉴相器输出信号初值
pd=zeros(1,num);
%本地载波频率初值
fo=ones(1,num)*fc;

%开始costas载波同步环路处理
%对costas环路使用到的变量初始化
len=0;   %低通滤波器输出数据长度
dfreq=0; %环路滤波器输出
temp=0;  %环路滤波器中间变量
df=0;    %每次需要更新的VCO输入电压
thera=zeros(1,num); %本地VCO输出信号的相位　
n=2;     %本地VCO频率更新的次数
lvco=20; %本地VCO频率更新的周期
m=0;     %每个VCO频率更新周期内的计数值
x_measure=zeros(1,num);
for i=(lvco+1):num;
    %乘法运算
    mult_i(i)=chdata(i).*o_sin(i);
    mult_q(i)=chdata(i).*o_cos(i);
    %低通滤波
    lpf_i=filter(lpf_b,lpf_a,mult_i(i-20:i));
    lpf_q=filter(lpf_b,lpf_a,mult_q(i-20:i));
    %鉴相乘法运算
    len=length(lpf_i);
    %如果采用同相正交支路相乘运算获取鉴相值
    %如果采用反正切运算求取鉴相值
    %则不需要进行增益处理
    pd=atan(lpf_q(len)/lpf_i(len));
    %环路滤波器
    dfreq = c1*pd+temp; 
    temp = temp+c2*pd;
    %每lvco个采样点更新一次频率
    if(mod(i,lvco)==0)
        df=dfreq;
        %计算上次更新时的本地载波相位
        thera(n)=2*pi*lvco*ts*fo(i-1)+thera(n-1);
        n=n+1;
    end
    %更新本地载波频率及输出信号
    fo(i)=fc+K0*df;
    m=mod(i,lvco);
    %要确保本地VCO输出相位连续的载波信号
    o_sin(i+1)=sin(2*pi*fo(i)*m*ts+thera(n-1));
    o_cos(i+1)=cos(2*pi*fo(i)*m*ts+thera(n-1));
    
     signal_Bxamp=2*sqrt(lpf_i(len).^2+lpf_q(len).^2);
     x_measure(i)=sign(2*lpf_i(len))*signal_Bxamp;
end

 mix2=x_measure(100:end);
 for i =1:length(mix2)
       if (mix2(i)*mix2(1)<0)
           index=i;
           break;
       end
 end
mix2_index=mix2(index:end);
row=floor(length(mix2_index)/100);
mix2_reshape=mix2_index(1:100*row);
signalreshpare=reshape(mix2_reshape,100,row);
signalreshpare=signalreshpare';
testres=sum(signalreshpare,2);
Data1 = 2* (testres > 0) - 1;
SS=zeros(length(Data1(1:end-politlength)));
for jj=1:length(Data1(1:end-politlength))
    SS(jj)=sum(Data1(jj:jj+politlength-1).*polit');
end

 [PMax,Pind] = max(abs(SS));
Exp = SS(Pind)/PMax;
Demodu2=Exp*Data1(Pind+politlength:Pind+politlength+userlength-1);

% Cor = xcorr(Data1(1:end-politlength),polit);
%  [PoMax,ind1] = max(abs(Cor));
%  Exp2 = Cor(ind1)/PoMax;
result=sum(polit2' .* Demodu2);
end