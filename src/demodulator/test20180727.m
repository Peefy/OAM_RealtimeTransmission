clear;
clc;
close all;

load('jxf0730.mat');

data = AI_Ch1;

fs = 625e6;

[QPSK1,QPSK2,QPSK3,QPSK4] = PolitDemodulator2(AI_Ch0,AI_Ch1,fs);

scatter(QPSK1(1,:),QPSK1(2,:));
hold on;
scatter(QPSK2(1,:),QPSK2(2,:));
hold on;
scatter(QPSK3(1,:),QPSK3(2,:));
hold on;
scatter(QPSK4(1,:),QPSK4(2,:));
hold on;

check