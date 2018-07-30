function [QPSK1,QPSK2,QPSK3,QPSK4] =  PolitDemodulator2(DatCh0,DatCh1,fs);

[QPSKTemp1,check1] = PolitDemodulator2ch(DatCh0,fs);
[QPSKTemp2,check2] = PolitDemodulator2ch(DatCh1,fs);

QPSK1 = QPSKTemp1(:,1:end/2);
QPSK2 = QPSKTemp1(:,end/2+1:end);
QPSK3  = QPSKTemp2(:,1:end/2);
QPSK4 = QPSKTemp2(:,end/2+1:end);