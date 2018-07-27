function cardInfo = initcard(mRegs, nDataNum)

datanum = 249984;

if nargin == 2
    datanum = nDataNum;
end

deviceString = '/dev/spcm0';

[success, cardInfo] = spcMInitDevice (deviceString);
if (success == true)
    % ----- print info about the board -----
    cardInfoText = spcMPrintCardInfo (cardInfo);
    fprintf (cardInfoText);
else
    spcMErrorMessageStdOut (cardInfo, 'Error: Could not open card\n', true);
    return;
end

% ----- check whether we support this card type in the example -----
if (cardInfo.cardFunction ~= mRegs('SPCM_TYPE_AI')) && (cardInfo.cardFunction ~= mRegs('SPCM_TYPE_DI')) & (cardInfo.cardFunction ~= mRegs('SPCM_TYPE_DIO'))
    spcMErrorMessageStdOut (cardInfo, 'Error: Card function not supported by this example\n', false);
    return;
end

% ***** do card setup *****

% ----- set channel mask for max channels -----
if cardInfo.maxChannels == 64
    chMaskH = hex2dec ('FFFFFFFF');
    chMaskL = hex2dec ('FFFFFFFF');
else
    chMaskH = 0;
    chMaskL = bitshift (1, cardInfo.maxChannels) - 1;
end

% ----- standard single, all channels, memsize=16k, posttrigge=8k -> pretrigger=8k  -----    
[success, cardInfo] = spcMSetupModeRecStdSingle (cardInfo, chMaskH, chMaskL, datanum, datanum / 2.0);
if (success == false)
    spcMErrorMessageStdOut (cardInfo, 'Error: spcMSetupModeRecStdSingle:\n\t', true);
    return;
end

% ----- we try to set the samplerate to 10 MHz on internal PLL, no clock output -----
if cardInfo.maxSamplerate >= 10000000
    [success, cardInfo] = spcMSetupClockPLL (cardInfo, 10000000, 0);  % clock output : enable = 1, disable = 0
else
    % ----- set samplerate to the max samplerate of the card, if max samplerate is less than 10 MHz -----
    [success, cardInfo] = spcMSetupClockPLL (cardInfo, cardInfo.maxSamplerate, 0); % clock output : enable = 1, disable = 0
end
if (success == false)
    spcMErrorMessageStdOut (cardInfo, 'Error: spcMSetupClockPLL:\n\t', true);
    return;
end

% ----- we set software trigger, no trigger output -----
[success, cardInfo] = spcMSetupTrigSoftware (cardInfo, 0);  % trigger output : enable = 1, disable = 0
if (success == false)
    spcMErrorMessageStdOut (cardInfo, 'Error: spcMSetupTrigSoftware:\n\t', true);
    return;
end

% ----- type dependent card setup -----
switch cardInfo.cardFunction
    % ----- analog acquistion card setup (1 = AnalogIn) -----
    case 1
        % ----- program all input channels to +/-1 V and 50 ohm termination (if it's available) -----
        for i=0 : cardInfo.maxChannels-1  
            [success, cardInfo] = spcMSetupAnalogInputChannel (cardInfo, i, 500, 1, 0, 0);  
            %setup for M3i card series including new features:
            %[success, cardInfo] = spcMSetupAnalogPathInputCh (cardInfo, i, 0, 1000, 1, 0, 0, 0);  
            if (success == false)
                spcMErrorMessageStdOut (cardInfo, 'Error: spcMSetupInputChannel:\n\t', true);
                return;
            end
        end
          
   % ----- digital acquisition card setup (3 = DigitalIn, 5 = DigitalIO) -----
   case { 3, 5 }
       % ----- set all input channel groups, no 110 ohm termination ----- 
       for i=0 : cardInfo.DIO.groups-1
           [~, cardInfo] = spcMSetupDigitalInput (cardInfo, i, 0);
       end
end