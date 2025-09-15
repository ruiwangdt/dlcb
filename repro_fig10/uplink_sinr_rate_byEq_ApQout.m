function [SINR,RATE] = uplink_sinr_rate_byEq_ApQout(H,ueWeight,apWeight,cpuWeight,prelogFactor)
% UE-AP-CPU network architecture：Without CSI
%  i)    UE:  K UEs, each with one stream & N tx-antenna;
%             has weight $\ubf_k$ and power constraint per user;
%  ii)   AP:  L APs, each with M rx-antenna & Q output;
%             each has weight $\vbf_l$, no power constraint;
%  iii)  CPU: one CPU, with $Q \times L$ input & K output;
%             has weight $\Wbf$, no power constraint;
%             connects to the APs.
% Last Modified: 2022/04/01
% by Rui Wang, CSRL@CSE Fudan University


[M,Q,L] = size(apWeight);
% [~,K] = size(cpuWeight);%[L*Q,K]
[N,K] = size(ueWeight);%[N,K]

ueWeightDiag = zeros(K*N,K);
for kk = 1:K
    ueWeightDiag((kk-1)*N+(1:N),kk) = ueWeight(:,kk);
end
 
G = zeros(Q*L,K*N);%H:(M*L,K*N);
VVdiag = zeros(Q*L,Q*L);
for ll = 1:L
    Vl = apWeight(:,:,ll);
    G((ll-1)*Q+(1:Q),:) = Vl'*H((ll-1)*M+(1:M),:);
    VVdiag((ll-1)*Q+(1:Q),(ll-1)*Q+(1:Q)) = Vl'*Vl;
end


SINR = zeros(K,1);
RATE = zeros(K,1);
for kk = 1:K
    %Compute numerator and denominator of instantaneous SINR
    numerator = abs(cpuWeight(:,kk)'*G(:,(kk-1)*N+(1:N))*ueWeight(:,kk))^2;
    denominator = norm(cpuWeight(:,kk)'*G*ueWeightDiag)^2+cpuWeight(:,kk)'*VVdiag*cpuWeight(:,kk) - numerator;

    %Compute instantaneous SE for one channel realization
    SINR(kk,1) = real(numerator/denominator);
    RATE(kk,1) = prelogFactor*real(log2(1+SINR(kk,1)));
end

end