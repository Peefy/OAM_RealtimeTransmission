function [ndatanum, sampleRate]  = getdatanum()
[ispic, ~] = config();
if ispic == 1
    % 400us
    sampleTime = 400e-6;
else
    % 400us
    sampleTime = 400e-6;
end
% 1.25GHz
sampleRate = 1250e6;
buffercount = sampleTime / (1 / sampleRate);
scale = round(buffercount / 1024);
% ndatanum = buffercount // 1024 * 1024;
ndatanum = 1024 * scale;
