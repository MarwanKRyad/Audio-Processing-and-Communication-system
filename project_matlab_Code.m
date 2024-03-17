duration = 10; 
fs = 44100;
bits = 16;
load Hd.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%record two sound %%%%%%%%%%%%%%%%%%%%%%%%%%%
record = audiorecorder(fs, bits, 1);

disp('start recording');
recordblocking(record, duration);
disp('recording finished');
audiodata = getaudiodata(record);
%we record first sound in duration= 10sec

filename = 'input1.wav';
audiowrite(filename, audiodata, fs);
%we save the first recorded sound 

disp('recording segment 2');
recordblocking(record, duration);
disp('recording finished');
audiodata2 = getaudiodata(record);
%we record second sound in duration= 10sec

filename2 = 'input2.wav';
audiowrite(filename2, audiodata2, fs);
%we save the second recorded sound

delete(record);






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%input%%%%%%%%%%%%%%%%%%%%%%%%%%%
[x1,fs]=audioread('input1.wav');
[x2,fs]=audioread('input2.wav');
%here we store the two sounds in two variables X1 and X2
N=length(x1);


input_1=fftshift(fft(x1,N));
input_2=fftshift(fft(x2,N));
%here we made a fast fourier transform (to be the signal in Frequency domain
% and we also made a shift so that the center of the signal was at zero

f=(-N/2:N/2-1)*fs/N;

subplot(3,3,1);
plot (f,abs(input_1));

subplot(3,3,2);
plot (f,abs(input_2));
%here we plot the audio signal at the frequency domain before the filter





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%filter%%%%%%%%%%%%%%%%%%%%%%%%%%%
y1=filter(Hd,x1);
y2=filter(Hd,x2);
%here we made a sound filter in time domain

output1=fftshift(fft(y1,N));
output2=fftshift(fft(y2,N));
%here we convert to Frequency domain then make shift ,as we did previously


subplot(3,3,3);
plot (f,abs(output1));

subplot(3,3,4);
plot (f,abs(output2));
%here we plot the audio signal at the frequency domain after the filter





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%modulation%%%%%%%%%%%%%%%%%%%%%%%%%%%
fa1 = 5e3; 
fb2=  15e3;
%here we define the frequency at which the modulation will be performed
t = (0:length(y1)-1) / fs; 


cosine_wave_transpose1 = cos(2*pi*fa1*t).';
cosine_wave_transpose2 = cos(2*pi*fb2*t).';

modulated_signal1 = y1 .* cosine_wave_transpose1;
modulated_signal2 = y2 .* cosine_wave_transpose2;
%here we define modulation function a do convolution
% with input signal in time domain

transmitted_in_time_domain=modulated_signal1+modulated_signal2;
%we add the two signal to send it to channel
modulation1=fftshift(fft(modulated_signal1,N));
modulation2=fftshift(fft(modulated_signal2,N));
transmitted_in_ferq_domain=fftshift(fft(transmitted_in_time_domain,N));
%here we convert the signals to frequency domain to plot them

subplot(3,3,5);
plot (f,abs(modulation1));
subplot(3,3,6);
plot (f,abs(modulation2));
%plot the two signals after make modulation

subplot(3,3,7);
plot (f,abs(transmitted_in_ferq_domain));
%plot the two signals after collecting them in one signal






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%receiver_demodulation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
demodulation1_time_domain1=transmitted_in_time_domain.* cosine_wave_transpose1;
demodulation_time_domain2=transmitted_in_time_domain.* cosine_wave_transpose2;
%here we do convolution to the signal received at the end of the channel

filtered_demodulation1_time_domain1=2*filter(Hd,demodulation1_time_domain1);
filtered_demodulation1_time_domain2=2*filter(Hd,demodulation_time_domain2);
%here we make a filter to extract the signal we want in time domain,
% then we multiply the amplitude by 2

demodulation1_freq_domain1=fftshift(fft(filtered_demodulation1_time_domain1,N));
demodulation1_freq_domain2=fftshift(fft(filtered_demodulation1_time_domain2,N));
%here we convert the signals to frequency domain to plot them

subplot(3,3,8);
plot (f,abs(demodulation1_freq_domain1));

subplot(3,3,9);
plot (f,abs(demodulation1_freq_domain2));
%here we plot the signals in frequency domain after demodulation and filter

audiowrite('output1.wav',filtered_demodulation1_time_domain1,fs);
audiowrite('output2.wav',filtered_demodulation1_time_domain2,fs);
%here we save the audio signal
