function WriteToFile(DatCh0, DatCh1, DatCh2, DatCh3, fileheader, filetail)

channel_name = {'DatCh0', 'DatCh1', 'DatCh2', 'DatCh3'};

assignin('base', channel_name{1}, DatCh0);
assignin('base', channel_name{2}, DatCh1);
assignin('base', channel_name{3}, DatCh2);
assignin('base', channel_name{4}, DatCh3);

for j = 1 : length(channel_name)
    filename = [fileheader, '_', channel_name{j}, '_', filetail, '.mat'];
    save(filename, channel_name{j});
    fprintf('save %s success!\n', filename);
end