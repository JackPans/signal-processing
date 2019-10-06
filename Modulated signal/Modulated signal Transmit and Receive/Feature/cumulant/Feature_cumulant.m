clc;clear all; close all
%% parameter
%% parameter Init
% baseband parameter
signal.fs=64e3;                    % Sample frequency of baseband
signal.fb=10e3;                    % Symbol rate
% IF parameter
signal.IFfs=10e6;                  % Sample frequency of Intermediate frequency 
signal.fc=1e6;                     % Carrier frequency
signal.f_offset=0;                 % Carrier offset
% IF2Base parameter
signal.lpf_lowf_stop=4*signal.fb/(signal.IFfs/2);
% Modulate parameter
signal.type="MPSK";%MPSK,MDPSK,OQPSK,pi4DQPSK
signal.M = 8;                     % Size of signal constellation        
signal.symlen = 300;               % Number of symbol
% shape filter
signal.rolloff=0.5;
signal.span=10;
signal.sps=4;
%
signal.gen_method="Baseband";
% signal.gen_method="IF";
% signal.gen_method="IF2Base";
signal.noiseType="Gauss";
signal.noisePowType="SNR"';
signal.encodeType="bin";
signal.bindataType="Random";
% other parameter Init
signal.f_offset=0;
signal.p_offset=2*pi*0.0;
signal.InitPhase=pi/signal.M*1;
signal.noise=20;
% buffer
signal.LOphaseTemp=0;
signal.LOphaseTemp_ddc=0;
signal.baseconvbuf=[];
signal.ddcconvbuf=[];
signal.baserebuf=[];
signal.Ifrebuf=[];
signal.ddcrebuf=[];
signal.Ifrebuf=zeros(1,32);


%% gen signal
packageN=10;
rxSignal=[];
for ii=1:packageN
    [rxSignalTemp,signal] = gen_MPSK(signal);
    rxSignal=[rxSignal,rxSignalTemp];
end

figure;plot(rxSignal,'x')

rxSignal=resample(rxSignal,4*signal.fb,signal.fs);
rccfilter=rcosdesign(0.5, 6, 4,'sqrt');
rxSignal=conv(rxSignal,rccfilter);
rcclen=length(rccfilter);

figure
plot(rxSignal(1:4:end))
figure
plot(rxSignal(1:4:end),'x')
figure
plot(rxSignal(2:4:end),'x')
figure
plot(rxSignal(3:4:end),'x')
figure
plot(rxSignal(4:4:end),'x')
rxSignal=sym_synch_Gardner(rxSignal);
figure;
plot(rxSignal(end-1000:end),'x')

%%
s=rxSignal(end-1000:end);
C21=Cum(s,21);
C40=Cum(s,40);
C42=Cum(s,42);
C63=Cum(s,63);
C80=Cum(s,80);
Cf=Cum(s,0);

%% SNR