function card_write_data(Dat_Ch0, Dat_Ch1, Dat_Ch2, Dat_Ch3, cardInfo, mRegs)

[~, ~, timeout] = getdatanum();
timeout_ms = timeout;

if cardInfo.cardFunction == mRegs('SPCM_TYPE_AO')

    switch cardInfo.setChannels
        
        case 1
            % ----- get the whole data for one channel with offset = 0 ----- 
            errorCode = spcm_dwSetData (cardInfo.hDrv, 0, cardInfo.setMemsize, cardInfo.setChannels, 0, Dat_Ch0);
        case 2
            % ----- get the whole data for two channels with offset = 0 ----- 
            errorCode = spcm_dwSetData (cardInfo.hDrv, 0, cardInfo.setMemsize, cardInfo.setChannels, 0, Dat_Ch0, Dat_Ch1);
        case 4
            % ----- set data for four channels with offset = 0 ----- 
            errorCode = spcm_dwSetData (cardInfo.hDrv, 0, cardInfo.setMemsize, cardInfo.setChannels, 0, Dat_Ch0, Dat_Ch1, Dat_Ch2, Dat_Ch3);
    end
    
else
 
    % ----- digital data -----
    [success, Data] = spcMCalcDigitalSignal (cardInfo.setMemsize, cardInfo.setChannels);
    
    errorCode = spcm_dwSetRawData (cardInfo.hDrv, 0, length (Data), Data, 1);
end

if (errorCode ~= 0)
    [success, cardInfo] = spcMCheckSetError (errorCode, cardInfo);
    spcMErrorMessageStdOut (cardInfo, 'Error: spcm_dwSetData:\n\t', true);
    return;
end

% ----- we'll start and wait until the card has finished or until a timeout occurs -----
errorCode = spcm_dwSetParam_i32 (cardInfo.hDrv, mRegs('SPC_TIMEOUT'), timeout_ms);
if (errorCode ~= 0)
    [success, cardInfo] = spcMCheckSetError (errorCode, cardInfo);
    spcMErrorMessageStdOut (cardInfo, 'Error: spcm_dwSetParam_i32:\n\t', true);
    return;
end

% ----- set command flags -----
commandMask = bitor (mRegs('M2CMD_CARD_START'), mRegs('M2CMD_CARD_ENABLETRIGGER'));
commandMask = bitor (commandMask, mRegs('M2CMD_CARD_WAITREADY'));

errorCode = spcm_dwSetParam_i32 (cardInfo.hDrv, mRegs('SPC_M2CMD'), commandMask);
if (errorCode ~= 0)
    
    [success, cardInfo] = spcMCheckSetError (errorCode, cardInfo);
    
    if errorCode == 263  % 263 = ERR_TIMEOUT 
        errorCode = spcm_dwSetParam_i32 (cardInfo.hDrv, mRegs('SPC_M2CMD'), mRegs('M2CMD_CARD_STOP'));
        fprintf (' OK\n ................... replay stopped\n');

    else
        spcMErrorMessageStdOut (cardInfo, 'Error: spcm_dwSetParam_i32:\n\t', true);
        return;
    end
end

fprintf (' ...................... replay done\n');
