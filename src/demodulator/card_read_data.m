function [ch0, ch1, ch2, ch3] = card_read_data(cardInfo, mRegs, mErrors, fs)
% ***** start card for acquistion *****

% ----- we'll start and wait until the card has finished or until a timeout occurs -----
timeout_ms = 5000;
sampleRate = 625e6;
if nargin == 4
    sampleRate = fs;
end
cardInfo.setSamplerate = sampleRate;
fprintf ('\n Sampling rate set to %.1f MHz', cardInfo.setSamplerate / 1000000);
errorCode = spcm_dwSetParam_i32 (cardInfo.hDrv, mRegs('SPC_SAMPLERATE'), sampleRate);
if (errorCode ~= 0)
    [~, cardInfo] = spcMCheckSetError (errorCode, cardInfo);
    spcMErrorMessageStdOut (cardInfo, 'Error: spcm_dwSetParam_i32:\n\t', true);
    return;
end
errorCode = spcm_dwSetParam_i32 (cardInfo.hDrv, mRegs('SPC_TIMEOUT'), timeout_ms);
if (errorCode ~= 0)
    [~, cardInfo] = spcMCheckSetError (errorCode, cardInfo);
    spcMErrorMessageStdOut (cardInfo, 'Error: spcm_dwSetParam_i32:\n\t', true);
    return;
end

fprintf ('\n Card timeout is set to %d ms\n', timeout_ms);
fprintf (' Starting the card and waiting for ready interrupt ...\n');

% ----- set command flags -----
commandMask = bitor (mRegs('M2CMD_CARD_START'), mRegs('M2CMD_CARD_ENABLETRIGGER'));
commandMask = bitor (commandMask, mRegs('M2CMD_CARD_WAITREADY'));

errorCode = spcm_dwSetParam_i32 (cardInfo.hDrv, mRegs('SPC_M2CMD'), commandMask);
if ((errorCode ~= 0) && (errorCode ~= 263))
    [~, cardInfo] = spcMCheckSetError (errorCode, cardInfo);
    spcMErrorMessageStdOut (cardInfo, 'Error: spcm_dwSetParam_i32:\n\t', true);
    return;
end

if errorCode == mErrors('ERR_TIMEOUT')
   spcMErrorMessageStdOut (cardInfo, ' ... Timeout occurred !!!', false);
   return;
else
    % ***** transfer data from card to PC memory *****
    fprintf (' Starting the DMA transfer and waiting until data is in PC memory ...\n');
    
    % ***** get analog input data *****
    if cardInfo.cardFunction == mRegs ('SPCM_TYPE_AI')
        % ----- set dataType: 0 = RAW (int16), 1 = Amplitude calculated (float) -----
        dataType = 1;
        switch cardInfo.setChannels
            case 1
                % ----- get the whole data for one channel with offset = 0 ----- 
                [errorCode, Dat_Ch0] = spcm_dwGetData (cardInfo.hDrv, 0, cardInfo.setMemsize, cardInfo.setChannels, dataType);
            case 2
                % ----- get the whole data for two channels with offset = 0 ----- 
                [errorCode, Dat_Ch0, Dat_Ch1] = spcm_dwGetData (cardInfo.hDrv, 0, cardInfo.setMemsize, cardInfo.setChannels, dataType);
            case 4
                % ----- get the whole data for four channels with offset = 0 ----- 
                [errorCode, Dat_Ch0, Dat_Ch1, Dat_Ch2, Dat_Ch3] = spcm_dwGetData (cardInfo.hDrv, 0, cardInfo.setMemsize, cardInfo.setChannels, dataType);
            case 8
                % ----- get the whole data for eight channels with offset = 0 ----- 
                [errorCode, Dat_Ch0, Dat_Ch1, Dat_Ch2, Dat_Ch3, ~, ~, ~, ~] = spcm_dwGetData (cardInfo.hDrv, 0, cardInfo.setMemsize, cardInfo.setChannels, dataType);
            case 16
                % ----- get the whole data for sixteen channels with offset = 0 ----- 
                [errorCode, Dat_Ch0, Dat_Ch1, Dat_Ch2, Dat_Ch3, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = spcm_dwGetData (cardInfo.hDrv, 0, cardInfo.setMemsize, cardInfo.setChannels, dataType);
        end
    else
        % ***** get digital input data *****
        
        % ----- get whole digital data in one multiplexed data block -----
        [errorCode, RAWData] = spcm_dwGetRAWData (cardInfo.hDrv, 0, cardInfo.setMemsize, 2);
        
        % ----- demultiplex digital data (DigData (channelIndex, value)) -----
        spcMDemuxDigitalData (RAWData, cardInfo.setMemsize, cardInfo.setChannels);
    end
    
    if (errorCode ~= 0)
        [~, cardInfo] = spcMCheckSetError (errorCode, cardInfo);
        spcMErrorMessageStdOut (cardInfo, 'Error: spcm_dwGetData:\n\t', true);
        return;
    end
end

ch0 = Dat_Ch0 / 0.5;
ch1 = Dat_Ch1 / 0.5;
ch2 = Dat_Ch2 / 0.5;
ch3 = Dat_Ch3 / 0.5;

% ch0 = Dat_Ch0 ;
% ch1 = Dat_Ch1 ;
% ch2 = Dat_Ch2 ;
% ch3 = Dat_Ch3 ;

