function [ndatanum, sampleRate]  = getdatanum()
[ispic, ~] = config();
if ispic == 1
    % 15ms
    sampleTime = 15000e-6;
else
    % 600us
    sampleTime = 600e-6;
end
% 625MHz
sampleRate = 625e6;
buffercount = sampleTime / (1 / sampleRate);
scale = round(buffercount / 1024);
% ndatanum = buffercount // 1024 * 1024;
ndatanum = 1024 * scale;
