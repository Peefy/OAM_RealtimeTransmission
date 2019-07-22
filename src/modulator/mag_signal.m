clc;
close all;

%% Para
channel_name = {'Dat_Ch0', 'Dat_Ch1', 'Dat_Ch2', 'Dat_Ch3'};

%% Init Card
mRegs = spcMCreateRegMap();
mErrors = spcMCreateErrorMap();

datalength = 2048;
cardInfo = initcard(mRegs, datalength);

%% User data store

data = AMSignal(datalength);
Dat_Ch0 = data;
Dat_Ch1 = data;
Dat_Ch2 = data;
Dat_Ch3 = data;
plot(Dat_Ch2);
[success, cardInfo, ~] = spcMCalcSignal (cardInfo, cardInfo.setMemsize, 1, 1, 100);
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


