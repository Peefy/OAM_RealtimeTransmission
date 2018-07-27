function png = Compress(bitData)
M=64;N=64;K=1;
data = bitData + 48;
data1=reshape(data,8,length(data)/8);
data1= char(data1);
data2=reshape(bin2dec(data1'),M,N,K);
png = uint8(data2);
imshow(imresize(png, [368 368]));
end
