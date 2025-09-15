% UE-AP-CPU network architecture：
% Ours:  uplink without CSI
%  i)    UE:  K UEs, each with one stream & N tx-antenna;
%             each has power constraint & weights;
%  ii)   AP:  L APs, each with M rx-antenna & Q output;
%             each has weight $\vbf_l$, no power constraint;
%  iii)  CPU: one CPU, with $Q \times L$ input & K output;
%             has weight $\Wbf$, no power constraint;
%             connects to the APs.
% Last Modified: 2022/05/14
% by Rui Wang, CSRL@CSE Fudan University

clear
close all
clc

% network architecture
K = 16;     %nUE
L = 16;     %nAP
M = 4;      %nApRxAnt
N = 2;
Q = 1;

% rng(0);

% parameters
pathlossIndx = 0;
TxPwr = 20;         %dBm
noisePwr = -96;     %dBm
APgap = 50;
minD  = 10;
snrDb = 20;         %dB
prelogFactor = 1;

% weight coefficient
weightCoeff = 0.1;

% pilot
nPilot = 64;
F = hadamard(nPilot);
pilot  = F(1:K,:);
nIter  = 30;
TinSet = 1:5;

% channel set
nChan = 100;
if pathlossIndx == 1
    [belta,~,~,~,~] = gen_beta_UEloc_APloc(L,K,APgap,minD);
    alpha = db2mag(TxPwr+belta-noisePwr);
else
    alpha = db2mag(snrDb);
end

rate = zeros(K,nIter,nChan,length(TinSet));
for chanIndx = 1:nChan
    chanIndx
    % gen channel
    Hunit = (randn(M*L,K*N)+1j*randn(M*L,K*N))/sqrt(2);
    if pathlossIndx == 1
        H = zeros(M*L,K*N);
        for ll = 1:L
            H((ll-1)*M+(1:M),:) = Hunit((ll-1)*M+(1:M),:)*diag(repelem(alpha(:,ll),N));
        end
    else
        H = Hunit*alpha;
    end

    % DLCB
    eta = (randn(L*M,nPilot*nIter)+1j*randn(L*M,nPilot*nIter))/sqrt(2); %noise
    ueBeam = (randn(N,K) + 1j*randn(N,K))/sqrt(2)*weightCoeff;
    ueTheta = randn(K,1)*weightCoeff;
    apWeight = (randn(M,Q,L) + 1j*randn(M,Q,L))/sqrt(2)*weightCoeff;
    rateCalOn = 1;
    for tt = 1:length(TinSet)
        Tin = TinSet(tt);
        [~,perfmsOut,~] = dlcb_alg(pilot,ueBeam,ueTheta,apWeight,H,eta,nIter,Tin,prelogFactor,rateCalOn);
        rate(:,:,chanIndx,tt) = perfmsOut.rateIter;
        clear perfmsOut
    end

end
rateMean = mean(rate,3);
sumRateMean = sum(rateMean,1);

%%
figure
colorSet = ['g','m','b','r','k','c'];
lsSet = ['-','--',':','-.','-'];
Len = {};
for tt = 1:length(TinSet)
    color = colorSet(tt);
    ls = lsSet(tt);
    plot(1:nIter,sumRateMean(:,:,:,tt),'Color',color,'LineStyle',ls,'LineWidth',1.5);hold on
    lgname = ['T_{in}=',num2str(TinSet(tt))];
    Len = [Len {lgname}];
end
xlabel('Number of OTA iterations (t)')
ylabel('Average sum rate (bps/Hz)')
legend(Len,Location='southeast')
titleName = strcat('K=', num2str(K),',N=', num2str(N),',L=', num2str(L), ...
    ',M=', num2str(M),',Q=', num2str(Q),',nPilot=', num2str(nPilot),...
    ',Tin=', num2str(Tin),',nIter=', num2str(nIter),...
    ',nChan=', num2str(nChan),',loss=', num2str(pathlossIndx));
title(titleName)
grid
figName = strcat('covgTinSumRate_', 'K', num2str(K),'N', num2str(N),...
    'L', num2str(L), 'M', num2str(M),'Q',num2str(Q),...
    'Pilot', num2str(nPilot),'chan', num2str(nChan),...
    'Coeff', num2str(weightCoeff),'Loss', num2str(pathlossIndx),'.fig');
savefig(gcf,figName)
