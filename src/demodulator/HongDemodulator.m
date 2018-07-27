function [testres, result] = HongDemodulator(chdata)

initial = zeros(1,7);             %��ʼֵ
initial(7) = 1;
feed = [1 0 0 0 1 0 0 1];             %�����߼�
politLength = 127;
c1 = ms_gen(initial,feed,politLength);
polit = 2*c1-1; %��Ƶ

initial2 = zeros(1,10);             %��ʼֵ
initial2(10) = 1;
feed2 = [1 0 0 0 0 0 0 1 0 0 1];             %�����߼�
politLength2 = 1023;
c2 = ms_gen(initial2,feed2,politLength2);
polit2 = 2*c2-1; %����

userlength = 1023;
 politlength = 127;

num=length(chdata);  %���ݳ���
fs=625e6;    %����Ƶ��
fc=62.5e6;     %�ز�Ƶ��

df=2000;    %��ʼƵƫ
ts=1/fs;
%����VCO�����棬Ҳ�൱����󲶻�Ƶƫ
K0=10e3;    
 c1=3.11e-1;
 c2=12.39e-11;
%���IIR��ͨ�˲���
N=3;    %�˲�������
R=60;   %���˥��(dB)
Wn=62.5e6; %��ֹƵ��
[lpf_b,lpf_a]=cheby2(N,R,Wn*2/fs);

%�����ز�����źų�ֵ
o_sin=sin(2*pi*fc*(0:num-1)*ts);
o_cos=cos(2*pi*fc*(0:num-1)*ts);
%�˷���������źų�ֵ
mult_i=zeros(1,num);
mult_q=zeros(1,num);
%����������źų�ֵ
pd=zeros(1,num);
%�����ز�Ƶ�ʳ�ֵ
fo=ones(1,num)*fc;

%��ʼcostas�ز�ͬ����·����
%��costas��·ʹ�õ��ı�����ʼ��
len=0;   %��ͨ�˲���������ݳ���
dfreq=0; %��·�˲������
temp=0;  %��·�˲����м����
df=0;    %ÿ����Ҫ���µ�VCO�����ѹ
thera=zeros(1,num); %����VCO����źŵ���λ��
n=2;     %����VCOƵ�ʸ��µĴ���
lvco=20; %����VCOƵ�ʸ��µ�����
m=0;     %ÿ��VCOƵ�ʸ��������ڵļ���ֵ
x_measure=zeros(1,num);
for i=(lvco+1):num;
    %�˷�����
    mult_i(i)=chdata(i).*o_sin(i);
    mult_q(i)=chdata(i).*o_cos(i);
    %��ͨ�˲�
    lpf_i=filter(lpf_b,lpf_a,mult_i(i-20:i));
    lpf_q=filter(lpf_b,lpf_a,mult_q(i-20:i));
    %����˷�����
    len=length(lpf_i);
    %�������ͬ������֧·��������ȡ����ֵ
    %������÷�����������ȡ����ֵ
    %����Ҫ�������洦��
    pd=atan(lpf_q(len)/lpf_i(len));
    %��·�˲���
    dfreq = c1*pd+temp; 
    temp = temp+c2*pd;
    %ÿlvco�����������һ��Ƶ��
    if(mod(i,lvco)==0)
        df=dfreq;
        %�����ϴθ���ʱ�ı����ز���λ
        thera(n)=2*pi*lvco*ts*fo(i-1)+thera(n-1);
        n=n+1;
    end
    %���±����ز�Ƶ�ʼ�����ź�
    fo(i)=fc+K0*df;
    m=mod(i,lvco);
    %Ҫȷ������VCO�����λ�������ز��ź�
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