function [QPSK0, QPSK1, QPSK2, QPSK3, check] = WQLdemodulator(data0, data1, data2, data3, fs)
check = 1023;
AI_Ch0 = double(data0);
AI_Ch1 = double(data1);
AI_Ch2 = double(data2);
AI_Ch3 = double(data3);

% 定义初始化参数
fsr = 1.25e9;                                               % 接收端采样率
fst = 560e6;                                                % 发射端采样率
fi = 70e6;                                                  % 中频信号
FrameLenthg = 76000;                                        % 帧长度
DataLength = 24000;                                                             % 序列长度
OAMMode = 4;                                                                    % OAM模式数
PoiltLength = 24000;                                                            % 导频长度
CarrierLength = 24000;  
Zerolength=(FrameLenthg - DataLength - PoiltLength - CarrierLength)/4;
Zerolengthr = Zerolength/fst*fsr; 











%delta_f = 0;
delta_f = 16.667e3;    % 频率偏差
fit = -delta_f+fi;
Blocklengtht = 24000;                                       % 发送端块长度
Blocklengthr = 24000/fst*fsr;                               % 接收端块长度
%STA = 164077+Zerolengthr+Blocklengthr;   

suoyou=length(AI_Ch0);
%STA = 164077+Zerolengthr+Blocklengthr;   
STA = 1;   % 截取数据段起始点
END = floor(suoyou);                        % 截取数据段接收点
%%

Signal = AI_Ch0(STA:END);                                   % 截取数据段\

% 相乘去除载波
ts = [0:floor(suoyou)-1]/fsr;
I_lo = sin(2*pi*fit*ts);
I_signal2 = Signal.*I_lo;

% 定义滤波器系数
Wp = (fit/2)/(fsr/2);     % 通带截止频率
Ws = fit/(fsr/2);         % 阻带截止频率
Rp = 0.5;               % 通带衰减
Rs = 40;                % 阻带衰减
% 设计滤波器
[n,Wn] = buttord(Wp,Ws,Rp,Rs);
[b,a] = butter(n,Wn);

% I路滤波
I_mix2 = filter(b,a,I_signal2);


% Q路滤波
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






















STA =STA1 ;   % 截取数据段起始点
END = floor(STA + 2*Blocklengthr +Zerolengthr- 1);                        % 截取数据段接收点
%%
Signal = AI_Ch0(STA:END);                                   % 截取数据段\



% S=AI_Ch0(STA:END);
% N=length(S);
% Y = fft(S,N); %做FFT变换
% Ayy = (abs(Y)); %取模
% title('FFT 模值');
% Ayy=Ayy/(N/2); %换算成实际的幅度
% Ayy(1)=Ayy(1)/2;
% F=([1:N]-1)*fsr/N; %换算成实际的频率值
% figure(44)
% plot(F(1:N/2),Ayy(1:N/2)); %显示换算后的FFT模值结果
% title('幅度-频率曲线图');


% 相乘去除载波
ts = [0:floor(2*Blocklengthr+Zerolengthr)-1]/fsr;
I_lo = sin(2*pi*fit*ts);
I_signal2 = Signal.*I_lo;



% N=length(I_signal2);
% Y = fft(I_signal2,N); %做FFT变换
% Ayy = (abs(Y)); %取模
% title('FFT 模值');
% Ayy=Ayy/(N/2); %换算成实际的幅度
% Ayy(1)=Ayy(1)/2;
% F=([1:N]-1)*fsr/N; %换算成实际的频率值
% figure(45)
% plot(F(1:N/2),Ayy(1:N/2)); %显示换算后的FFT模值结果
% title('幅度-频率曲线图');


% 定义滤波器系数
Wp = (fit/2)/(fsr/2);     % 通带截止频率
Ws = fit/(fsr/2);         % 阻带截止频率
Rp = 0.5;               % 通带衰减
Rs = 40;                % 阻带衰减
% 设计滤波器
[n,Wn] = buttord(Wp,Ws,Rp,Rs);
[b,a] = butter(n,Wn);

% I路滤波
I_mix2 = filter(b,a,I_signal2);


% Q路滤波
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

Signal = AI_Ch1(STA:END);                                   % 截取数据段\
% 相乘去除载波
ts = [0:floor(2*Blocklengthr+Zerolengthr)-1]/fsr;
I_lo = sin(2*pi*fit*ts);
I_signal2 = Signal.*I_lo;


% 定义滤波器系数
Wp = (fit/2)/(fsr/2);     % 通带截止频率
Ws = fit/(fsr/2);         % 阻带截止频率
Rp = 0.5;               % 通带衰减
Rs = 40;                % 阻带衰减
% 设计滤波器
[n,Wn] = buttord(Wp,Ws,Rp,Rs);
[b,a] = butter(n,Wn);

% I路滤波
I_mix2 = filter(b,a,I_signal2);

% Q路滤波
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

Signal = AI_Ch2(STA:END);                                   % 截取数据段\
% 相乘去除载波
ts = [0:floor(2*Blocklengthr+Zerolengthr)-1]/fsr;
I_lo = sin(2*pi*fit*ts);
I_signal2 = Signal.*I_lo;


% 定义滤波器系数
Wp = (fit/2)/(fsr/2);     % 通带截止频率
Ws = fit/(fsr/2);         % 阻带截止频率
Rp = 0.5;               % 通带衰减
Rs = 40;                % 阻带衰减
% 设计滤波器
[n,Wn] = buttord(Wp,Ws,Rp,Rs);
[b,a] = butter(n,Wn);

% I路滤波
I_mix2 = filter(b,a,I_signal2);

% Q路滤波
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

Signal = AI_Ch3(STA:END);                                   % 截取数据段\
% 相乘去除载波
ts = [0:floor(2*Blocklengthr+Zerolengthr)-1]/fsr;
I_lo = sin(2*pi*fit*ts);
I_signal2 = Signal.*I_lo;


% 定义滤波器系数
Wp = (fit/2)/(fsr/2);     % 通带截止频率
Ws = fit/(fsr/2);         % 阻带截止频率
Rp = 0.5;               % 通带衰减
Rs = 40;                % 阻带衰减
% 设计滤波器
[n,Wn] = buttord(Wp,Ws,Rp,Rs);
[b,a] = butter(n,Wn);

% I路滤波
I_mix2 = filter(b,a,I_signal2);


% Q路滤波
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
% title('模态1')
% subplot(2,2,2)
% plot(real(X1(2,:)),imag(X1(2,:)),'o');
% title('模态-1')
% subplot(2,2,3)
% plot(real(X1(3,:)),imag(X1(3,:)),'o');
% title('模态2')
% subplot(2,2,4)
% plot(real(X1(4,:)),imag(X1(4,:)),'o');
% title('模态-2');
