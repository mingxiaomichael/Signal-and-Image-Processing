clc; clear; close all;
[y1, fs] = audioread('1.wav');
y=awgn(y1,10*log(100/2));


time = (1:length(y))/fs;
frameSize=floor(30*fs/1000); 
q = length(y);

for i = 1:1:10
startIndex=round(q * (rand(1, 1)));
endIndex=startIndex+frameSize-1;
frame = y(startIndex:endIndex);
frameSize=length(frame);
frame2=frame.*hamming(length(frame));
rwy = rceps(frame2);
ylen=length(rwy);
cepstrum=rwy(1:ylen/2); 
LF=floor(fs/500); 
HF=floor(fs/70);
cn=cepstrum(LF:HF);
[mx_cep, ind]=max(cn);

nFrames=floor(q/(endIndex - startIndex))-1; 
k=1;
pitch=zeros(1,nFrames);

if (mx_cep > 0.08) && (ind >LF)  
    a= fs/(LF+ind);
else
    a=0;
end

figure(1);
plot(time, y); axis tight
ylim=get(gca, 'ylim');
line([time(startIndex), time(startIndex)], ylim, 'color', 'r');
line([time(endIndex), time(endIndex)], ylim, 'color', 'r');
title('audio waveform');

figure(2);
subplot(2,1,1);
plot(frame);
title('waveform of the frame');
subplot(2,1,2);
plot(cepstrum);
title('cepstral');

pitch = a;

time0 = startIndex / 8000;
disp(time0);
Mypitch = max(pitch);
if Mypitch>200
    disp("Woman");
end
if (Mypitch>=60)&&(Mypitch<=200)
    disp("Man");
end
if (Mypitch<60)||(Mypitch>500)
    disp("noise");
end
end