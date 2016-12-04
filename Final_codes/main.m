close all
clear all
%%

% myImage = imread('lena.jpg');
% myImage = double(myImage);
% %myImage = myImage*255/max(max(myImage));
% %myImage = myImage(1:192,1:192);
msLen = 16;
error = 0;

% for i = 1:1
%     duplicate = 10; % number of times the data must be repeated
%     %message = 'What are you doing?'; %
%     message = char(floor(94*rand(1, msLen)) + 32);
%     message = reshape(dec2bin(message,8)',1,8*length(message));
%     threshold = 919;
%     sd = 88; % seed
% 
%     myImageModified =  imageStegano(myImage,message,duplicate,threshold,sd);
%     %figure;imshow(mat2gray(myImageModified));
%     %figure;imshow(mat2gray(myImage));
% 
%     mssg = imageStegano_detect(myImageModified,length(message)*duplicate,duplicate,threshold,sd);
%     %disp(mssg);
% end
tic;
    [P,Fs] = audioread('DKB.mp3');
    audioFile = P(9*Fs:50*Fs,1);
    delta = 2;
    wf = 'haar';
    [ca, cd1, cd2, cd3, myImage, scale,shift] = audio2image(audioFile,delta,wf);
    
    duplicate = 10; % number of times the data must be repeated
    %message = 'What are you doing?'; %
    %rng(i);
    %message = char(floor(94*rand(1, msLen)) + 32);
    message = 'ankur';
    messageBin = reshape(dec2bin(message,8)',1,8*length(message));
    threshold = 50;
    sd = 88; % seed

    myImageModified =  imageStegano(myImage,messageBin,duplicate,threshold,sd);
    %figure;imshow(mat2gray(myImageModified));
    %figure;imshow(mat2gray(myImage));
    
    audioNew = image2audio(ca,cd1,cd2,cd3,myImageModified,delta,wf,scale,shift);
    
    L=length(audioNew);
    audioFile1=[audioFile ; zeros(length(audioNew)-length(audioFile),1)];
    A=audioFile1-audioNew;
    A=A.^2;
    A1=sum(A(:))/L;
    M=(max(audioFile))^2;
    PSNR=10*log10(M/A1);
    %% decoding
    [ca, cd1, cd2, cd3, myImageDetected, scale,shift] = audio2image(audioNew,delta,wf);

    mssg = imageStegano_detect(myImageDetected,length(messageBin)*duplicate,duplicate,threshold,sd);
    disp(mssg);
    disp(PSNR);
    %     if ~strcmp(mssg,message)
%         badSeq(error+1,:) = message;
%     end
%     error = error + 1 - strcmp(mssg,message);
%figure; imshow(uint8(myImage));
%figure; imshow(uint8(myImageDetected));
toc;
disp(error)