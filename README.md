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

## 🚀 Quickstart

## 📚 Cite This Work
If you use this code, please cite the paper.
```latex
@article{wang2023distributed,
  title={Distributed learning for uplink cell-free massive MIMO networks},
  author={Wang, Rui and Dai, Weijie and Jiang, Yi},
  journal={IEEE Transactions on Communications},
  volume={71},
  number={9},
  pages={5595--5606},
  year={2023},
  publisher={IEEE}
}
```

---

## 🔑 License
```text
MIT License
Copyright (c) 2025 Rui Wang
```

## 📬 Contact
Rui Wang

Homepage: https://ruiwangdt.github.io/

Email: ruiwang18@fudan.edu.cn
