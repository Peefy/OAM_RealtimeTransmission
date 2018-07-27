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

%% User data store
sampleTime = 1 / sampleRate;
t = 0 : sampleTime : (ndatanum - 1) * sampleTime; 
count = 4;
for i = 1 : count
    [Dat_Ch0, Dat_Ch1, Dat_Ch2, Dat_Ch3] = ...
        card_read_data(cardInfo, mRegs, mErrors, sampleRate);
    if isshowplot ~= 0
        figure;
        plot (t(1:1000), Dat_Ch0(1:1000), 'b', t(1:1000), Dat_Ch1(1:1000), 'g', ...
            t(1:1000), Dat_Ch2(1:1000), 'r', t(1:1000), Dat_Ch3(1:1000), 'y');      
    end
    WriteToFile(Dat_Ch0, Dat_Ch1, Dat_Ch2, Dat_Ch3, 'Console', num2str(i));
end

%% Close Card
spcMCloseCard (cardInfo);
fprintf('card is closed\r\n');


