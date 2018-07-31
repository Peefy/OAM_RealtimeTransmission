clc;
close all;

%% Para
channel_name = {'Dat_Ch0', 'Dat_Ch1', 'Dat_Ch2', 'Dat_Ch3'};

%% Init Card
mRegs = spcMCreateRegMap();
mErrors = spcMCreateErrorMap();

datalength = 1024 * 50;
cardInfo = initcard(mRegs, datalength);

%% User data store

data = sin(linspace(0,4 * pi,datalength)) * 6666 + ...
     sin(linspace(0,4 * pi,datalength) * 3) * 6666;
Dat_Ch0 = data;
Dat_Ch1 = data;
Dat_Ch2 = data;
Dat_Ch3 = data;
[success, cardInfo, Dat_Ch2] = spcMCalcSignal (cardInfo, cardInfo.setMemsize, 1, 1, 100);
card_write_data(Dat_Ch0, Dat_Ch1, Dat_Ch2, Dat_Ch3, cardInfo, mRegs)
fprintf('data trans success!\r\n');

% card_write_data(Dat_Ch0, Dat_Ch1, Dat_Ch2, Dat_Ch3, cardInfo, mRegs)
% fprintf('data trans success!\r\n');
plot(Dat_Ch0);
hold on;
plot(Dat_Ch2);
%% Close Card
spcMCloseCard (cardInfo);
fprintf('card is closed\r\n');


