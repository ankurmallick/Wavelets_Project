function audio=image2audio(ca,cd1,cd2,cd3,image,d,wf,f,g)
r = size(image,1);
image = f*image/255;
image = image + g;
for m=0:r-1
    for n=0:r-1
        k=(m*r+n)*d;
        cd1(k+1)=image(m+1,n+1);
    end
end
ca2 = idwt(ca,cd3,wf);
%keyboard;
cd2=[cd2; zeros(length(ca2)-length(cd2),1)];
ca1 = idwt(ca2,cd2,wf);
cd1=[cd1; zeros(length(ca1)-length(cd1),1)];
audio = idwt(ca1,cd1,wf);
end