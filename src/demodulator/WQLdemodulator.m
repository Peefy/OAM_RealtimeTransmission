function [QPSK0, QPSK1, QPSK2, QPSK3, check] = WQLdemodulator(data0, data1, data2, data3, fs)
check = 1023;
AI_Ch0 = double(data0);
AI_Ch1 = double(data1);
AI_Ch2 = double(data2);
AI_Ch3 = double(data3);

% �����ʼ������
fsr = 1.25e9;                                               % ���ն˲�����
fst = 560e6;                                                % ����˲�����
fi = 70e6;                                                  % ��Ƶ�ź�
FrameLenthg = 76000;                                        % ֡����
DataLength = 24000;                                                             % ���г���
OAMMode = 4;                                                                    % OAMģʽ��
PoiltLength = 24000;                                                            % ��Ƶ����
CarrierLength = 24000;  
Zerolength=(FrameLenthg - DataLength - PoiltLength - CarrierLength)/4;
Zerolengthr = Zerolength/fst*fsr; 











%delta_f = 0;
delta_f = 16.667e3;    % Ƶ��ƫ��
fit = -delta_f+fi;
Blocklengtht = 24000;                                       % ���Ͷ˿鳤��
Blocklengthr = 24000/fst*fsr;                               % ���ն˿鳤��
%STA = 164077+Zerolengthr+Blocklengthr;   

suoyou=length(AI_Ch0);
%STA = 164077+Zerolengthr+Blocklengthr;   
STA = 1;   % ��ȡ���ݶ���ʼ��
END = floor(suoyou);                        % ��ȡ���ݶν��յ�
%%

Signal = AI_Ch0(STA:END);                                   % ��ȡ���ݶ�\

% ���ȥ���ز�
ts = [0:floor(suoyou)-1]/fsr;
I_lo = sin(2*pi*fit*ts);
I_signal2 = Signal.*I_lo;

% �����˲���ϵ��
Wp = (fit/2)/(fsr/2);     % ͨ����ֹƵ��
Ws = fit/(fsr/2);         % �����ֹƵ��
Rp = 0.5;               % ͨ��˥��
Rs = 40;                % ���˥��
% ����˲���
[n,Wn] = buttord(Wp,Ws,Rp,Rs);
[b,a] = butter(n,Wn);

% I·�˲�
I_mix2 = filter(b,a,I_signal2);


% Q·�˲�
Q_lo = cos(2*pi*fit*ts);
Q_signal2 = Signal.*Q_lo;
Q_mix2 = filter(b,a,Q_signal2);


jiange=32;


ggg=I_mix2(1:jiange:suoyou);
fff=Q_mix2(1:jiange:suoyou);
i=0;
for m=1:(suoyou/jiange)
    if(abs(ggg(m))<2&&abs(fff(m))<2)
       i=i+1;
        in(i)=m;
    end
end



ppos = 2;
inn=in(2:length(in));
inflag=inn-in(1:length(in)-1);
mm=find(inflag>500);

    
if(isempty(mm))
else
nn=mm(2:length(mm));
nnm=nn-mm(1:length(mm)-1)

jl=find(nnm>20)



for i=1:length(jl)-1
if((round(nnm(jl(i+1))/nnm(jl(i)))==2)&&jl(i)>2)
    ppos=i;
    break
end
end 
end

if(isempty(mm))
STA1=1;
else
STA1= inn(mm(jl(ppos))-2)*jiange ; 
end






















STA =STA1 ;   % ��ȡ���ݶ���ʼ��
END = floor(STA + 2*Blocklengthr +Zerolengthr- 1);                        % ��ȡ���ݶν��յ�
%%
Signal = AI_Ch0(STA:END);                                   % ��ȡ���ݶ�\



% S=AI_Ch0(STA:END);
% N=length(S);
% Y = fft(S,N); %��FFT�任
% Ayy = (abs(Y)); %ȡģ
% title('FFT ģֵ');
% Ayy=Ayy/(N/2); %�����ʵ�ʵķ���
% Ayy(1)=Ayy(1)/2;
% F=([1:N]-1)*fsr/N; %�����ʵ�ʵ�Ƶ��ֵ
% figure(44)
% plot(F(1:N/2),Ayy(1:N/2)); %��ʾ������FFTģֵ���
% title('����-Ƶ������ͼ');


% ���ȥ���ز�
ts = [0:floor(2*Blocklengthr+Zerolengthr)-1]/fsr;
I_lo = sin(2*pi*fit*ts);
I_signal2 = Signal.*I_lo;



% N=length(I_signal2);
% Y = fft(I_signal2,N); %��FFT�任
% Ayy = (abs(Y)); %ȡģ
% title('FFT ģֵ');
% Ayy=Ayy/(N/2); %�����ʵ�ʵķ���
% Ayy(1)=Ayy(1)/2;
% F=([1:N]-1)*fsr/N; %�����ʵ�ʵ�Ƶ��ֵ
% figure(45)
% plot(F(1:N/2),Ayy(1:N/2)); %��ʾ������FFTģֵ���
% title('����-Ƶ������ͼ');


% �����˲���ϵ��
Wp = (fit/2)/(fsr/2);     % ͨ����ֹƵ��
Ws = fit/(fsr/2);         % �����ֹƵ��
Rp = 0.5;               % ͨ��˥��
Rs = 40;                % ���˥��
% ����˲���
[n,Wn] = buttord(Wp,Ws,Rp,Rs);
[b,a] = butter(n,Wn);

% I·�˲�
I_mix2 = filter(b,a,I_signal2);


% Q·�˲�
Q_lo = cos(2*pi*fit*ts);
Q_signal2 = Signal.*Q_lo;
Q_mix2 = filter(b,a,Q_signal2);


rs0 = 560e6/3000;
N0= fsr/rs0;
UserLength0 =(Blocklengtht)/fst*rs0;
i = 0:round(UserLength0-1);
I0_Dat = I_mix2(floor(i*N0+N0/2));
Q0_Dat = Q_mix2(floor(i*N0+N0/2));
U_Dat = zeros(1,floor(UserLength0));


rs = 7e5;
N = fsr/rs;
UserLength = Blocklengtht/fst*rs;
i = 0:UserLength-1;
WI0_Dat = I_mix2(floor(i*N+N/2+Zerolengthr+Blocklengthr));
WQ0_Dat = Q_mix2(floor(i*N+N/2+Zerolengthr+Blocklengthr));

%%

Signal = AI_Ch1(STA:END);                                   % ��ȡ���ݶ�\
% ���ȥ���ز�
ts = [0:floor(2*Blocklengthr+Zerolengthr)-1]/fsr;
I_lo = sin(2*pi*fit*ts);
I_signal2 = Signal.*I_lo;


% �����˲���ϵ��
Wp = (fit/2)/(fsr/2);     % ͨ����ֹƵ��
Ws = fit/(fsr/2);         % �����ֹƵ��
Rp = 0.5;               % ͨ��˥��
Rs = 40;                % ���˥��
% ����˲���
[n,Wn] = buttord(Wp,Ws,Rp,Rs);
[b,a] = butter(n,Wn);

% I·�˲�
I_mix2 = filter(b,a,I_signal2);

% Q·�˲�
Q_lo = cos(2*pi*fit*ts);
Q_signal2 = Signal.*Q_lo;
Q_mix2 = filter(b,a,Q_signal2);

rs0 = 560e6/3000;
N0= fsr/rs0;
UserLength0 =(Blocklengtht)/fst*rs0;
i = 0:round(UserLength0-1);
I1_Dat = I_mix2(floor(i*N0+N0/2));
Q1_Dat = Q_mix2(floor(i*N0+N0/2));
U_Dat = zeros(1,floor(UserLength0));


rs = 7e5;
N = fsr/rs;
UserLength = Blocklengtht/fst*rs;
i = 0:UserLength-1;
WI1_Dat = I_mix2(floor(i*N+N/2+Zerolengthr+Blocklengthr));
WQ1_Dat = Q_mix2(floor(i*N+N/2+Zerolengthr+Blocklengthr));
% for i = 1:round(UserLength0)
%     if abs(I0_Dat(i))>abs(Q0_Dat(i))
%         U0_Dat(i) = I0_Dat(i);
%     else
%         U0_Dat(i) = Q0_Dat(i);
%     end
% end
% 
% 
% 
% for i = 1:UserLength
%     if abs(I_Dat(i))>abs(Q_Dat(i))
%         U_Dat(i) = I_Dat(i);
%     else
%         U_Dat(i) = Q_Dat(i);
%     end
% end

%%

Signal = AI_Ch2(STA:END);                                   % ��ȡ���ݶ�\
% ���ȥ���ز�
ts = [0:floor(2*Blocklengthr+Zerolengthr)-1]/fsr;
I_lo = sin(2*pi*fit*ts);
I_signal2 = Signal.*I_lo;


% �����˲���ϵ��
Wp = (fit/2)/(fsr/2);     % ͨ����ֹƵ��
Ws = fit/(fsr/2);         % �����ֹƵ��
Rp = 0.5;               % ͨ��˥��
Rs = 40;                % ���˥��
% ����˲���
[n,Wn] = buttord(Wp,Ws,Rp,Rs);
[b,a] = butter(n,Wn);

% I·�˲�
I_mix2 = filter(b,a,I_signal2);

% Q·�˲�
Q_lo = cos(2*pi*fit*ts);
Q_signal2 = Signal.*Q_lo;
Q_mix2 = filter(b,a,Q_signal2);

rs0 = 560e6/3000;
N0= fsr/rs0;
UserLength0 =(Blocklengtht)/fst*rs0;
i = 0:round(UserLength0-1);
I2_Dat = I_mix2(floor(i*N0+N0/2));
Q2_Dat = Q_mix2(floor(i*N0+N0/2));
U_Dat = zeros(1,floor(UserLength0));


rs = 7e5;
N = fsr/rs;
UserLength = Blocklengtht/fst*rs;
i = 0:UserLength-1;
WI2_Dat = I_mix2(floor(i*N+N/2+Zerolengthr+Blocklengthr));
WQ2_Dat = Q_mix2(floor(i*N+N/2+Zerolengthr+Blocklengthr));
%%

Signal = AI_Ch3(STA:END);                                   % ��ȡ���ݶ�\
% ���ȥ���ز�
ts = [0:floor(2*Blocklengthr+Zerolengthr)-1]/fsr;
I_lo = sin(2*pi*fit*ts);
I_signal2 = Signal.*I_lo;


% �����˲���ϵ��
Wp = (fit/2)/(fsr/2);     % ͨ����ֹƵ��
Ws = fit/(fsr/2);         % �����ֹƵ��
Rp = 0.5;               % ͨ��˥��
Rs = 40;                % ���˥��
% ����˲���
[n,Wn] = buttord(Wp,Ws,Rp,Rs);
[b,a] = butter(n,Wn);

% I·�˲�
I_mix2 = filter(b,a,I_signal2);


% Q·�˲�
Q_lo = cos(2*pi*fit*ts);
Q_signal2 = Signal.*Q_lo;
Q_mix2 = filter(b,a,Q_signal2);


rs0 = 560e6/3000;
N0= fsr/rs0;
UserLength0 =(Blocklengtht)/fst*rs0;
i = 0:round(UserLength0-1);
I3_Dat = I_mix2(floor(i*N0+N0/2));
Q3_Dat = Q_mix2(floor(i*N0+N0/2));
U_Dat = zeros(1,floor(UserLength0));


rs = 7e5;
N = fsr/rs;
UserLength = Blocklengtht/fst*rs;
i = 0:UserLength-1;
WI3_Dat = I_mix2(floor(i*N+N/2+Zerolengthr+Blocklengthr));
WQ3_Dat = Q_mix2(floor(i*N+N/2+Zerolengthr+Blocklengthr));



Y0=I0_Dat+Q0_Dat*1i;

Y1=I1_Dat+Q1_Dat*1i;

Y2=I2_Dat+Q2_Dat*1i;

Y3=I3_Dat+Q3_Dat*1i;
Y=[Y0;Y1;Y2;Y3];

X=[1,1,1,1;
    -1,1,1,1;
    1,-1,1,1;
    1,1,-1,1;
    1,1,1,-1;
    -1,-1,1,1;
    -1,1,-1,1;
    -1,1,1,-1]';
H=Y*pinv(X);

W0=WI0_Dat+WQ0_Dat*1i;

W1=WI1_Dat+WQ1_Dat*1i;

W2=WI2_Dat+WQ2_Dat*1i;

W3=WI3_Dat+WQ3_Dat*1i;
W=[W0;W1;W2;W3];


X1=pinv(H)*W;
QPSK0 = X1(1,:);
QPSK1 = X1(2,:);
QPSK2 = X1(3,:);
QPSK3 = X1(4,:);
% figure(11)
% subplot(2,2,1)
% plot(real(X1(1,:)),imag(X1(1,:)),'o');
% title('ģ̬1')
% subplot(2,2,2)
% plot(real(X1(2,:)),imag(X1(2,:)),'o');
% title('ģ̬-1')
% subplot(2,2,3)
% plot(real(X1(3,:)),imag(X1(3,:)),'o');
% title('ģ̬2')
% subplot(2,2,4)
% plot(real(X1(4,:)),imag(X1(4,:)),'o');
% title('ģ̬-2');
