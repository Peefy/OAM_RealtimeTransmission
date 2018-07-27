function [ndatanum, sampleRate]  = getdatanum()
% 15ms
sampleTime = 15000e-6;
% 1250MHz
sampleRate = 625e6;
buffercount = sampleTime / (1 / sampleRate);
scale = round(buffercount / 1024);
% ndatanum = buffercount // 1024 * 1024;
ndatanum = 1024 * scale;
