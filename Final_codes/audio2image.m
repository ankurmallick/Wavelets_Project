function [ca, cd1, cd2, cd3, image,f,g]=audio2image(audio,d,wf)
[ca1,cd1] = dwt(audio,wf);
[ca2,cd2] = dwt(ca1,wf);
[ca,cd3] = dwt(ca2,wf);
L = length(audio);
r = floor(sqrt(L/(2*d)));
r = r-mod(r,16); %Making r a multiple of 16
%d=1; %delta
image = zeros(r,r);
for m=0:r-1
    for n=0:r-1
        k=(m*r+n)*d;
        image(m+1,n+1)= cd1(k+1);
        %cdx=cd3, can use cd2 or cd3 as well
    end
end
g = min(min(image));
image = image - g;
f = max(max(image));
image = 255*image/f;
end