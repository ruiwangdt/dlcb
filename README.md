# DLCB: Distributed Learning for uplink Cell-free massive MIMO Beamformin

**Official open-source reference for “Distributed Learning for Uplink Cell-Free Massive MIMO Networks,” IEEE Transactions on Communications, 2023**, DOI: 10.1109/TCOMM.2023.3288578.


> DLCB models an uplink cell-free network as a **quasi-neural network** and borrows the idea of **backpropagation** algorithm to jointly optimize UE/AP/CPU weights **without explicit CSI**. Each AP compresses its vector observation into a **scalar** for the CPU, reducing fronthaul load, and the method supports **MMSE** and **MSR** objectives.  
> See the paper for details.  

---

## ✨ Key Features
- **No explicit CSI exchange** among APs; distributed optimization via BP
- **Fronthaul-friendly**: APs forward scalars to CPU
- **Objective-agnostic**: MMSE and MSR supported
- **Algorithm 1 & 2 implementations** (multi-antenna UEs; single-antenna UEs)
- **5G NR-aware** training schedule (TDD, minislot framing)
- **Reproducible simulations** for rate curves and overhead studies

## 🧭 Repository Structure
