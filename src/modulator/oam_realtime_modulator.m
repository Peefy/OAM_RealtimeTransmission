clc;
close all;

%% Para
[ndatanum, sampleRate] = getdatanum();
isshowplot = 1;
channel_name = {'Dat_Ch0', 'Dat_Ch1', 'Dat_Ch2', 'Dat_Ch3'};

%% Init Card
mRegs = spcMCreateRegMap();
mErrors = spcMCreateErrorMap();
cardInfo = initcard(mRegs, ndatanum);
sampleTime = 1 / sampleRate;
t = 0 : sampleTime : (ndatanum - 1) * sampleTime; 

%% User data store

%% Close Card
spcMCloseCard (cardInfo);
fprintf('card is closed\r\n');


