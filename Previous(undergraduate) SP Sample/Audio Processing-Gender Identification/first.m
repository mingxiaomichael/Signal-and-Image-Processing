clc; clear; close all;
% [y, fs] = audioread('2.wav');%input audio
% [x,sr]=audioread('2.wav');
[y, fs] = audioread('man.wav');%input audio
[x,sr]=audioread('man.wav');
% y=awgn(y1,10*log(100/2));%Gaussian noise
% x=awgn(x1,10*log(100/2));
q = length(y);
%sampling, the first peak is the pitch frequency
time = (1:length(y))/fs;
frameSize=floor(30*fs/1000);     %frame length 30ms, 240 points   floor<=x
startIndex=round(q * (rand(1, 1)));  %random starting
endIndex=startIndex+frameSize-1; %ending
frame = y(startIndex:endIndex);  %get the frame
frameSize=length(frame);
frame2=frame.*hamming(length(frame));  % hamming filter
%cepstral
rwy = rceps(frame2);
ylen=length(rwy);
cepstrum=rwy(1:ylen/2);
LF=floor(fs/500);
HF=floor(fs/70);
cn=cepstrum(LF:HF);
[mx_cep, ind]=max(cn); %find the peak
if (mx_cep > 0.08) && (ind >LF)  
    a= fs/(LF+ind);
else
    a=0;
end
pitch = a;

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
plot(cn);
title('cepstral');

if pitch>200
    disp("Woman");
end
if (pitch>60)&&(pitch<200)
    disp("Man");
end


