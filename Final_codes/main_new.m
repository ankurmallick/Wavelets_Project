close all
clear all

%% User Input
prompt = {'Enter the message:'};
message = cell2mat(inputdlg(prompt));
if(size(message)==0)
    return;
end
name='Select the audio track';
list = {'Summer of 69', 'Numb','Zinda'};
[Selection, ok]=listdlg('liststring',list,'SelectionMode','single','name',name,'ListSize',[250 80]);
if(ok==0)
    return;
end
if(Selection==1)
    [P,Fs] = audioread('S69.mp3');
    audioFile = P(18*Fs:58*Fs,1);
elseif(Selection==2)
    [P,Fs] = audioread('Numb.mp3');
    audioFile = P(13*Fs:53*Fs,1);
else
    [P,Fs] = audioread('zinda.mp3');
    audioFile = P(5*Fs:45*Fs,1);
end

%% Encryption parameters
prompt = {'Enter the duplication rate:'};
duplicate = str2double(cell2mat(inputdlg(prompt)));
if(size(duplicate)==0)
    return;
end
name='Select the sampling interval';
list = {'1','2','3','4'};
[Selection, ok]=listdlg('liststring',list,'SelectionMode','single','name',name,'ListSize',[250 80]);
if(ok==0)
    return;
end
delta=Selection;
name='Select the wavelet';
list = {'haar','db3','db5'};
[Selection, ok]=listdlg('liststring',list,'SelectionMode','single','name',name,'ListSize',[250 80]);
if(ok==0)
    return;
end
wf=cell2mat(list(Selection));
prompt = {'Enter the value of the seed:'};
sd = str2double(cell2mat(inputdlg(prompt)));
name='Threshold selection';
list = {'Default value','User Input'};
[Selection, ok]=listdlg('liststring',list,'SelectionMode','single','name',name,'ListSize',[250 80]);
if(ok==0)
    return;
end
if(Selection==1)
    threshold = 50;
else
    prompt = {'Enter the value of the threshold:'};
    threshold = str2double(cell2mat(inputdlg(prompt)));
    if(size(threshold)==0)
        return;
    end
end

%% Encryption
[ca, cd1, cd2, cd3, myImage, scale,shift] = audio2image(audioFile,delta,wf); %Audio to Image
messageBin = reshape(dec2bin(message,8)',1,8*length(message));  
myImageModified =  imageStegano(myImage,messageBin,duplicate,threshold,sd); %Encryption
audioNew = image2audio(ca,cd1,cd2,cd3,myImageModified,delta,wf,scale,shift);%Image to Audio

%% PSNR calculation
L=length(audioNew);
audioFile1=[audioFile ; zeros(length(audioNew)-length(audioFile),1)];
A=audioFile1-audioNew;
A=A.^2;
A1=sum(A(:))/L;
M=(max(audioFile))^2;
PSNR=10*log10(M/A1);

%% Input v/s Output

button=questdlg('Do you wish to listen to the original audio?');
if strcmp(button,'Yes')
    soundsc(audioFile(1:Fs*10),Fs);
end
if strcmp(button,'Cancel')
    return;
end
button=questdlg('Do you wish to listen to the modified audio?');
if strcmp(button,'Yes')
    soundsc(audioNew(1:Fs*10),Fs);
end
button=questdlg('Do you wish to view the original image?');
if strcmp(button,'Yes')
    figure
    imshow(mat2gray(myImage));
end
button=questdlg('Do you wish to view the modified image?');
if strcmp(button,'Yes')
    figure
    imshow(mat2gray(myImageModified));
end

%% Decryption
%Decryption and encryption parameters should match
prompt = {'Enter the duplication rate:'};
duplicate = str2double(cell2mat(inputdlg(prompt)));
if(size(duplicate)==0)
    return;
end
name='Select the sampling interval';
list = {'1','2','3','4'};
[Selection, ok]=listdlg('liststring',list,'SelectionMode','single','name',name,'ListSize',[250 80]);
if(ok==0)
    return;
end
delta=Selection;
name='Select the wavelet';
list = {'haar','db3','db5'};
[Selection, ok]=listdlg('liststring',list,'SelectionMode','single','name',name,'ListSize',[250 80]);
if(ok==0)
    return;
end
wf=cell2mat(list(Selection));
prompt = {'Enter the value of the seed:'};
sd = str2double(cell2mat(inputdlg(prompt)));
name='Threshold selection';
list = {'Default value','User Input'};
[Selection, ok]=listdlg('liststring',list,'SelectionMode','single','name',name,'ListSize',[250 80]);
if(ok==0)
    return;
end
if(Selection==1)
    threshold = 50;
else
    prompt = {'Enter the value of the threshold:'};
    threshold = str2double(cell2mat(inputdlg(prompt)));
    if(size(threshold)==0)
        return;
    end
end
[ca, cd1, cd2, cd3, myImageDetected, scale,shift] = audio2image(audioNew,delta,wf);
mssg = imageStegano_detect(myImageDetected,length(messageBin)*duplicate,duplicate,threshold,sd);
h=msgbox(mssg);
fprintf('Output PSNR: ');
disp(PSNR);