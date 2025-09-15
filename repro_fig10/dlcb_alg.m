function [perfmsIn,perfmsOut,paras] = ...
    dlcb_alg(txSig,ueBeam,ueTheta,apWeight,H,eta,nIter,Tin,prelogFactor,rateCalOn)
% UE-AP-CPU network architecture：Without CSI
%  i)    UE:  K UEs, each with one stream & N tx-antenna;
%             has weight $\ubf_k$ and power constraint per user;
%  ii)   AP:  L APs, each with M rx-antenna & Q output;
%             each has weight $\vbf_l$, no power constraint;
%  iii)  CPU: one CPU, with $Q \times L$ input & K output;
%             has weight $\Wbf$, no power constraint;
%             connects to the APs.
% Last Modified: 2022/05/06
% by Rui Wang, CSRL@CSE Fudan University

[~,blockSize] = size(txSig);
[N,K] = size(ueBeam);
[M,Q,L] = size(apWeight);
% [L*Q,K] = size(cpuWeight);
alpha = 0.3;
beta = 0.9;

momnV = zeros(M,Q,L);
momnP = zeros(N,K);
momnTheta = zeros(K,1);
rateIterOut = zeros(K,nIter);
rateIterIn = zeros(K,nIter*Tin);

iterIndx = 0;
for bb = 1:nIter
    %forward
    s = txSig;  %(K,blocksize)
    x = zeros(K*N,blockSize);
    ueWeight = zeros(N,K);
    for kk = 1:K
        ueWeight(:,kk) = ueBeam(:,kk)/norm(ueBeam(:,kk),2)*exp(-ueTheta(kk,1)^2);
        x((kk-1)*N+(1:N),:) = ueWeight(:,kk)*s(kk,:);
    end
    y = H*x + eta(:,(bb-1)*blockSize+(1:blockSize)); %(M*L,blockSize)

    for jj = 1:Tin
        iterIndx = iterIndx + 1;
        r = zeros(L*Q,blockSize);
        for ll = 1:L
            Vl = apWeight(:,:,ll);
            r((ll-1)*Q+(1:Q),:) = Vl'*y((ll-1)*M+(1:M),:);%(L,blockSize)
        end
        cpuWeight = (r*r')\(r*s');
        shat = cpuWeight'*r;%(K,blocksize)

        %performance
        if rateCalOn == 1
            [~,rateIterIn(:,iterIndx)] = uplink_sinr_rate_byEq_ApQout(H,ueWeight,apWeight,cpuWeight,prelogFactor);
        end

        if jj == 1
            rateIterOut(:,bb) = rateIterIn(:,iterIndx);
        end

        %backward
        coDshatC = zeros(K,blockSize);
        for kk = 1:K
            coDshatC(kk,:) = (shat(kk,:)-s(kk,:))./norm(s(kk,:)-shat(kk,:))^2;
        end

        coDrC = cpuWeight*coDshatC;     %(Q*L,blockSize)
        coDvCsum = zeros(M,Q,L);
        for ll = 1:L
            coDvCsum(:,:,ll) = y((ll-1)*M+(1:M),:)*coDrC((ll-1)*Q+(1:Q),:)';
        end

        momnV = beta*momnV + (1-beta)*coDvCsum/blockSize;
        apWeight = apWeight - alpha*momnV;
    end

    coDxC = zeros(K*N,blockSize);
    for ll = 1:L
        Vl = apWeight(:,:,ll);
        coDxC = coDxC + H((ll-1)*M+(1:M),:)'*Vl*coDrC((ll-1)*Q+(1:Q),:);
    end

    coDuCsum = zeros(N,K);
    coDpCsum = zeros(N,K);
    coDthetaCsum = zeros(K,1);
    for kk = 1:K
        coDuCsum(:,kk) = coDxC((kk-1)*N+(1:N),:)*s(kk,:)';
        coDpCsum(:,kk) = exp(-ueTheta(kk,1)^2)/norm(ueBeam(:,kk),2)*coDuCsum(:,kk)...
            -exp(-ueTheta(kk,1)^2)/norm(ueBeam(:,kk),2)^3*ueBeam(:,kk)*real(ueBeam(:,kk)'*coDuCsum(:,kk));
        coDthetaCsum(kk,1) = real(-4*ueTheta(kk,1)*exp(-ueTheta(kk,1)^2)/norm(ueBeam(:,kk),2)*ueBeam(:,kk)'*coDuCsum(:,kk));
    end

    momnP = beta*momnP + (1-beta)*coDpCsum/blockSize;
    ueBeam = ueBeam - alpha*momnP;
    momnTheta = beta*momnTheta + (1-beta)*coDthetaCsum/blockSize;
    ueTheta = ueTheta - alpha*momnTheta;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%    Output      %%%%%%%%%%%%%%%%%%%%%%%%%%%%
perfmsIn.rateIter = rateIterIn;
perfmsOut.rateIter = rateIterOut;

paras.ueBeam = ueBeam;
paras.ueTheta = ueTheta;
paras.apWeight = apWeight;
paras.cpuWeight = cpuWeight;

end




