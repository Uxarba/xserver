# XLibre — nSuite Edition 🜁
## Hardware-Accelerated Foundation for the Dell Canvas 8K

![XLibre NSUITE EDITION](file:///home/afr0s/.gemini/antigravity/brain/10d31bda-ddbe-4e46-bd38-916c83d87012/media__1774038969282.jpg)

### **VICTORY 2026-03-20: The Hardware Reality Pass** 🏆🚬

This is the curated, sovereign fork of **X11Libre**, specifically hardened and optimized for the **NILA Project** and the **Dell Canvas 8K** ecosystem (Intel Arc DG2). 

---

## 🏗️ Core Breakthroughs
- **Dell Canvas 8K Calibration**: Validated visual output and stylus-first input logic.
- **Intel Arc (DG2) Acceleration**: Full `modesetting` + `glamor` integration.
- **Atomic Async Patch**: Custom implementation in `present.c` for tear-free, low-latency page flips.
- **Non-Root TTY Orchestration**: Secure, isolated session startup via `nSession.sh` without global state drift.
- **Input Bypass**: Resolved `libinput` ABI mismatches through curated module staging.

## 🚀 Deployment
### 1. Launch Production Session
Switch to an available TTY (e.g., VT3) and run:
```bash
./_ns/scripts/nSession.sh
```

### 2. Monitoring & Logs
Logs are incrementally versioned in `_ns/logs/session_YYYYMMDD_HHMMSS/`.
- `xorg.log`: Server initialization.
- `openbox.log`: Window manager orchestration.
- `n_preview.log`: nAudio / preview daemon health.

---

## 📐 The Strata Canon
This repository adheres to the **NILA Architecture Maxims**:
1. **Layer 0 Isolation**: This server is a pure foundation. It knows nothing of the UI engines above it.
2. **Data-Centric**: Communication flows through sovereign protocols (X11 + XNAMESPACE).
3. **No Global Drift**: Zero installation to `/usr`. Everything runs from the curated vendor node.

---

## 🤝 Credits & Lineage
Based on the excellent work of the [X11Libre Project](https://github.com/X11Libre/xserver). Modified and hardened by **Uxarba** for the NILA nameless collective.

**"Still Alive. Release on time."** 🍰🜁
