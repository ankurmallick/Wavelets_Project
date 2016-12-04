function [message] = imageStegano_detect(myImage, numIters, duplicate, threshold, sd)

wf = 'haar';
[cA1,cH1,cV1,cD1] = dwt2(myImage,wf);
[cA2,cH2,cV2,cD2] = dwt2(cA1,wf);
[cA3,cH3,cV3,cD3] = dwt2(cA2,wf);
myImage_trans = [[[cA3 cH3; cV3 cD3] cH2; cV2 cD2] cH1; cV1 cD1];
%disp('detect');
%disp([max(max(myImage_trans)) min(min(myImage_trans))]);
%save('tr2','myImage_trans');
r = size(myImage,2);
numIters = numIters/2;

U = 1:1:r/2*r/2;
V = reshape(U,r/2,r/2);
V(1:r/16,1:r/16) = -1;
V1 = reshape(V,1,r/2*r/2);
V1(V1 == -1) = [];
rng(sd); K = datasample(V1,numIters,'replace',false);
blockX = floor(2*K/r) + 1;
blockY = mod(K,r/2);
blockY(find(blockY == 0)) = r/2;

count0 = 0; count1 = 0;
for j = 1:numIters
    block = myImage_trans(blockX(j)*2-1:blockX(j)*2,blockY(j)*2-1:blockY(j)*2);
    blockType = block >= threshold;
%    keyboard
    if blockType == [0 0; 0 0]
        mssgType = 3;
    elseif blockType == [0 0; 0 1]
        mssgType = 0;
    elseif blockType == [0 0; 1 0]
        mssgType = 1;
    elseif blockType == [0 0; 1 1]
        mssgType = 0;
    elseif blockType == [0 1; 0 0]
        mssgType = 2;
    elseif blockType == [0 1; 0 1]
        mssgType = 1;
    elseif blockType == [0 1; 1 0]
        mssgType = 2;
    elseif blockType == [0 1; 1 1]
        mssgType = 0;
    elseif blockType == [1 0; 0 0]
        mssgType = 3;
    elseif blockType == [1 0; 0 1]
        mssgType = 0;
    elseif blockType == [1 0; 1 0]
        mssgType = 1;
    elseif blockType == [1 0; 1 1]
        mssgType = 1;
    elseif blockType == [1 1; 0 0]
        mssgType = 2;
    elseif blockType == [1 1; 0 1]
        mssgType = 2;
    elseif blockType == [1 1; 1 0]
        mssgType = 3;
        %count1 = count1 + 1;
    elseif blockType == [1 1; 1 1]
        mssgType = 3;
        %count0 = count0 + 1;
    end
   
    if mssgType == 0
        detectedMessage(2*j-1:2*j) = '00';
    elseif mssgType == 1
        detectedMessage(2*j-1:2*j) = '01';
    elseif mssgType == 2
        detectedMessage(2*j-1:2*j) = '10';
    elseif mssgType == 3;
        detectedMessage(2*j-1:2*j) = '11';
    end
    %disp([block]);
end

mssgLen = 2*numIters/duplicate;
message = char(bin2dec(reshape(detectedMessage(1:mssgLen)',8,mssgLen/8)'))';
%figure;imshow(uint8(myImage_trans))

%keyboard
%disp([numIters length(detectedMessage) count0 count1]);