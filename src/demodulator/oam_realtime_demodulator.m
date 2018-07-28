clc;
close all;

%% Para
[ndatanum, sampleRate] = getdatanum();
isshowplot = 1;
channel_name = {'Dat_Ch0', 'Dat_Ch1', 'Dat_Ch2', 'Dat_Ch3'};
fileheader = 'Console';

%% Init Card
mRegs = spcMCreateRegMap();
mErrors = spcMCreateErrorMap();
cardInfo = initcard(mRegs, ndatanum);

%% User data store
sampleTime = 1 / sampleRate;
t = 0 : sampleTime : (ndatanum - 1) * sampleTime; 
count = 4;
truecount = 0;
for i = 1 : count
    [Dat_Ch0, Dat_Ch1, Dat_Ch2, Dat_Ch3] = ...
        card_read_data(cardInfo, mRegs, mErrors, sampleRate);
    if isshowplot ~= 0
        figure;
        plot (t, Dat_Ch0, 'b', t, Dat_Ch1, 'g', ...
            t, Dat_Ch2, 'r', t, Dat_Ch3, 'y');     
    end
    WriteToFile(Dat_Ch0, Dat_Ch1, Dat_Ch2, Dat_Ch3, fileheader, num2str(i));
end

%% Close Card
spcMCloseCard (cardInfo);
fprintf('card is closed\r\n');


