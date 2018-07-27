function se = ms_gen(initial,feed,l)
n=length(feed);
% l=2^(n-1)-1;
se(1)=initial(n-1);
for i=2:l
    s=0;
    for m=1:(n-1)
        s=mod(s+initial(m)*feed(m+1),2);
    end
    for k=(n-1):-1:2
        initial(k)=initial(k-1);
    end
    initial(1)=s;
    se(i)=initial(n-1);
end
% cor=2*seq-1;
% rm=zeros(1,length(cor));
% for i=1:length(cor)
%     rm(i+1)=sum(cor.*circshift(cor,[0,i]))/length(cor);
% end
% figure(1)
% plot(rm);
% title('×ÔÏà¹Ø')