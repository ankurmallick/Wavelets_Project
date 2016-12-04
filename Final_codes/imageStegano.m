function [myImage_steg] = imageStegano(myImage, message, duplicate, threshold, sd)

wf = 'haar';
[cA1,cH1,cV1,cD1] = dwt2(myImage,wf);
[cA2,cH2,cV2,cD2] = dwt2(cA1,wf);
[cA3,cH3,cV3,cD3] = dwt2(cA2,wf);
myImage_trans = [[[cA3 cH3; cV3 cD3] cH2; cV2 cD2] cH1; cV1 cD1];
%save('tr1','myImage_trans');
r = size(myImage,2);
% numBlocks = (63/64)*r^2/4;

dupMessage = repmat(message,1,duplicate);
numIters = length(dupMessage)/2;

U = 1:1:r/2*r/2;
V = reshape(U,r/2,r/2);
V(1:r/16,1:r/16) = -1;
V1 = reshape(V,1,r/2*r/2);
V1(V1 == -1) = [];
rng(sd); K = datasample(V1,numIters,'replace',false);
%keyboard
blockX = floor(2*K/r) + 1;
blockY = mod(K,r/2);
blockY(blockY == 0) = r/2;

for j = 1:numIters
    block = myImage_trans(blockX(j)*2-1:blockX(j)*2,blockY(j)*2-1:blockY(j)*2);
    class = sum(sum(block > threshold));
    mssgType = bin2dec(dupMessage(2*j-1:2*j));
    
    if class == 1 && mssgType == 0
        blockType = [0 0; 0 1];
    elseif class == 1 && mssgType == 1
        blockType = [0 0; 1 0];
    elseif class == 1 && mssgType == 2
        blockType = [0 1; 0 0];
    elseif class == 1 && mssgType == 3
        blockType = [1 0; 0 0];
    elseif class == 3 && mssgType == 0
        blockType = [0 1; 1 1];
    elseif class == 3 && mssgType == 1
        blockType = [1 0; 1 1];
    elseif class == 3 && mssgType == 2
        blockType = [1 1; 0 1];
    elseif class == 3 && mssgType == 3
        blockType = [1 1; 1 0];
    elseif block(1,1) >= threshold && mssgType == 0
        blockType = [1 0; 0 1];
    elseif block(1,1) >= threshold && mssgType == 1
        blockType = [1 0; 1 0];
    elseif block(1,1) >= threshold  && mssgType == 2
        blockType = [1 1; 0 0];
    elseif block(1,1) >= threshold && mssgType == 3
        blockType = [1 1; 1 1];
    elseif block(1,1) < threshold && mssgType == 0
        blockType = [0 0; 1 1];
    elseif block(1,1) < threshold && mssgType == 1
        blockType = [0 1; 0 1];
    elseif block(1,1) < threshold && mssgType == 2
        blockType = [0 1; 1 0];
    elseif block(1,1) < threshold && mssgType == 3
        blockType = [0 0; 0 0];
    end
    
    % replacing old block with the modified block
    block_th = block >= threshold;
    if class == 0
        newBlock = 1.01*blockType*threshold + block.*(ones(2) - blockType);
    elseif class == 4
        newBlock = block.*(ones(2) - blockType) - 1.01*threshold*(ones(2) - blockType);
    elseif mssgType == 3 && class == 2
        if blockType(1,1) == 0
            newBlock = block.*(ones(2)-block_th) - block_th*1.01*threshold;
        else
            newBlock = block.*block_th + (ones(2)-block_th)*1.01*threshold;
        end
    else
        diffe = bitxor(block_th,blockType);
        change = find(diffe == 1);
        change = flipud(change);
        newBlock = block;
        newBlock(diffe > 0) = block(change);
     end
    
    myImage_trans(blockX(j)*2-1:blockX(j)*2,blockY(j)*2-1:blockY(j)*2) = newBlock;
    %disp([block]);
end

%figure;imshow(uint8(myImage_trans));
%disp([max(max(myImage)) min(min(myImage))]);
image3 = idwt2(myImage_trans(1:r/8,1:r/8),myImage_trans(1:r/8,r/8+1:r/4),myImage_trans(r/8+1:r/4,1:r/8),myImage_trans(r/8+1:r/4,r/8+1:r/4),wf);
image2 = idwt2(image3,myImage_trans(1:r/4,r/4+1:r/2),myImage_trans(r/4+1:r/2,1:r/4),myImage_trans(r/4+1:r/2,r/4+1:r/2),wf);
myImage_steg = idwt2(image2,myImage_trans(1:r/2,r/2+1:r),myImage_trans(r/2+1:r,1:r/2),myImage_trans(r/2+1:r,r/2+1:r),wf);

%disp([max(max(myImage_trans)) min(min(myImage_trans))]);