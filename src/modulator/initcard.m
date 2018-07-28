function cardInfo = initcard(mRegs, nDatanum)

[success, cardInfo] = spcMInitCardByIdx (0);
if (success == true)
    cardInfoText = spcMPrintCardInfo (cardInfo);
    fprintf (cardInfoText);
else
    spcMErrorMessageStdOut (cardInfo, 'Error: Could not open card\n', true);
    return;
end

if ((cardInfo.cardFunction ~= mRegs('SPCM_TYPE_AO')) && (cardInfo.cardFunction ~= mRegs('SPCM_TYPE_DO')) && (cardInfo.cardFunction ~= mRegs('SPCM_TYPE_DIO')))
    spcMErrorMessageStdOut (cardInfo, 'Error: Card function not supported by this example\n', false);
    return;
end
% (1) Singleshot\n  (2) Continuous\n  (3) Single Restart\n 
replayMode = 2; %  Continuous
[~, sampleRate, timeout] = getdatanum();
cardInfo.setMemsize = nDatanum;
samplerate = sampleRate;
timeout_ms = timeout;

% ----- set the samplerate and internal PLL, no clock output -----
[success, cardInfo] = spcMSetupClockPLL (cardInfo, samplerate, 0);  % clock output : enable = 1, disable = 0
if (success == false)
    spcMErrorMessageStdOut (cardInfo, 'Error: spcMSetupClockPLL:\n\t', true);
    return;
end
fprintf ('\n ..... Sampling rate set to %.1f MHz\n', cardInfo.setSamplerate / 1000000);


% ----- set channel mask for max channels -----
if cardInfo.maxChannels == 64
    chMaskH = hex2dec ('FFFFFFFF');
    chMaskL = hex2dec ('FFFFFFFF');
else
    chMaskH = 0;
    chMaskL = bitshift (1, cardInfo.maxChannels) - 1;
end



switch replayMode
    
    case 1
        % ----- singleshot replay -----
        [success, cardInfo] = spcMSetupModeRepStdSingle (cardInfo, chMaskH, chMaskL, nDatanum);
        if (success == false)
            spcMErrorMessageStdOut (cardInfo, 'Error: spcMSetupModeRecStdSingle:\n\t', true);
            return;
        end
        fprintf (' .............. Set singleshot mode\n');
        
        % ----- set software trigger, no trigger output -----
        [success, cardInfo] = spcMSetupTrigSoftware (cardInfo, 0);  % trigger output : enable = 1, disable = 0
        if (success == false)
            spcMErrorMessageStdOut (cardInfo, 'Error: spcMSetupTrigSoftware:\n\t', true);
            return;
        end
        fprintf (' ............. Set software trigger\n');
        
    case 2
        % ----- endless continuous mode -----
        [success, cardInfo] = spcMSetupModeRepStdLoops (cardInfo, chMaskH, chMaskL, nDatanum, 0);
        if (success == false)
            spcMErrorMessageStdOut (cardInfo, 'Error: spcMSetupModeRecStdSingle:\n\t', true);
            return;
        end
        fprintf (' .............. Set continuous mode\n');
        
        % ----- set software trigger, no trigger output -----
        [success, cardInfo] = spcMSetupTrigSoftware (cardInfo, 0);  % trigger output : enable = 1, disable = 0
        if (success == false)
            spcMErrorMessageStdOut (cardInfo, 'Error: spcMSetupTrigSoftware:\n\t', true);

            return;
        end
        fprintf (' ............. Set software trigger\n Wait for timeout (%d sec) .....', timeout_ms / 1000);

    case 3
        % ----- single restart (one signal on every trigger edge) -----
        [success, cardInfo] = spcMSetupModeRepStdSingleRestart (cardInfo, chMaskH, chMaskL, nDatanum, 0);
        if (success == false)
            spcMErrorMessageStdOut (cardInfo, 'Error: spcMSetupTrigSoftware:\n\t', true);
            return;
        end
        fprintf (' .......... Set single restart mode\n');
        
        % ----- set extern trigger, positive edge -----
        [success, cardInfo] = spcMSetupTrigExternal (cardInfo, mRegs('SPC_TM_POS'), 1, 0, 1, 0);
        if (success == false)
            spcMErrorMessageStdOut (cardInfo, 'Error: spcMSetupTrigSoftware:\n\t', true);
            return;
        end
        fprintf (' ............... Set extern trigger\n Wait for timeout (%d sec) .....', timeout_ms / 1000);
end

% ----- type dependent card setup -----
switch cardInfo.cardFunction

    % ----- analog generator card setup -----
    case mRegs('SPCM_TYPE_AO')
        % ----- program all output channels to +/- 1 V with no offset and no filter -----
        for i=0 : cardInfo.maxChannels-1  
            [success, cardInfo] = spcMSetupAnalogOutputChannel (cardInfo, i, 1000, 0, 0, 16, 0, 0); % 16 = SPCM_STOPLVL_ZERO, doubleOut = disabled, differential = disabled
            if (success == false)
                spcMErrorMessageStdOut (cardInfo, 'Error: spcMSetupInputChannel:\n\t', true);
                return;
            end
        end
   
   % ----- digital acquisition card setup -----
   case { mRegs('SPCM_TYPE_DO'), mRegs('SPCM_TYPE_DIO') }
       % ----- set all output channel groups ----- 
       for i=0 : cardInfo.DIO.groups-1                             
           [success, cardInfo] = spcMSetupDigitalOutput (cardInfo, i, mRegs('SPCM_STOPLVL_LOW'), 0, 3300, 0);
       end
end


