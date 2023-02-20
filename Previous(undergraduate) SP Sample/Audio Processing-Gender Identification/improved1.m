clc; clear; close all;
% [y, fs] = audioread('2.wav');
% [x,sr]=audioread('2.wav');
[y, fs] = audioread('man.wav');
[x,sr]=audioread('man.wav');
% y=awgn(y1,10*log(100/2);
% x=awgn(x1,10*log(100/2));
q = length(y);

time = (1:length(y))/fs;
frameSize=floor(30*fs/1000); 
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


%improvement
meen=mean(x);
x= x - meen;
updRate=floor(20*sr/1000);
fRate=floor(30*sr/1000);
n_samples=length(x);
nFrames=floor(n_samples/updRate)-1;
k=1;
pitch=zeros(1,nFrames);
f0=zeros(1,nFrames);
LF=floor(sr/500);
HF=floor(sr/70);
m=1;
avgF0=0;
for t=1:nFrames
       yin=x(k:k+fRate-1);
       cn1=rceps(yin);
       cn=cn1(LF:HF);
       [mx_cep, ind]=max(cn);
       if (mx_cep > 0.08) && (ind >LF)
              a= sr/(LF+ind);
       else
              a=0;
       end
       f0(t)=a;
       if (t>2) && (nFrames>3)
              z=f0(t-2:t);
              md=median(z);
              pitch(t-2)=md;
              if md > 0
                     avgF0=avgF0+md;
                     m=m+1;
              end
       else
              if nFrames<=3
              pitch(t)=a;
              avgF0=avgF0+a;
              m=m+1;
              end
       end
   k=k+updRate;
end
pitch1 = f0;
figure(3)
subplot(311);
plot((1:length(x))/sr, x);
ylabel('amplitude');
xlabel('time');
subplot(312);
xt=1:nFrames;
xt=20*xt;
plot(xt,pitch)
xlim([0,3]);
axis([xt(1) xt(nFrames) 0 max(pitch)+50]);
title('median filtering');
ylabel('pitch frequency/HZ');
xlabel('time');
subplot(313);
xt=1:nFrames;
xt=20*xt;
plot(xt,pitch1)
xlim([0,3]);
axis([xt(1) xt(nFrames) 0 max(pitch1)+50]);
title('no median filtering');
ylabel('/HZ');
xlabel('time');

Mypitch = max(pitch);
if Mypitch>200
    disp("Woman");
end
if (Mypitch>60)&&(Mypitch<200)
    disp("Man");
end
