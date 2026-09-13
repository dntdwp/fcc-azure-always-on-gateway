# FCC Always-On Azure — Multi-Device AI Gateway

FCC (`free-claude-code`) jalan 24/7 di Azure VM, diakses dari PC + laptop + teman via Tailscale tanpa ada device yang harus nyala terus.

## Arsitektur

```
PC / Laptop / Teman (Tailscale)
  → http://<TAILSCALE_FCC_IP>:8082 (/health, /v1/models)
  → VM Azure (FCC 6.2.0 + systemd) → NVIDIA NIM / OpenRouter / OpenAI
```

* VM: `Standard_B2ats_v2`, Ubuntu 24.04, region Asia Tenggara
* FCC: `fcc-server` via systemd (`Restart=always`), Uvicorn `0.0.0.0:8082`
* Admin UI local-only `127.0.0.1:8082/admin`, diakses via `ssh -L 8082:localhost:8082`
* NSG: inbound SSH (22) only, port 8082 tidak dibuka publik
* Tailscale: 1 tailnet, device sendiri join akun sama, teman via Share/invite

## Client (Claude Code)

```powershell
$env:ANTHROPIC_BASE_URL="http://<TAILSCALE_FCC_IP>:8082"
$env:ANTHROPIC_API_KEY="<PROXY_TOKEN>"
$env:CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY="1"
$env:CLAUDE_CODE_DISABLE_MODEL_WINDOW_ENFORCEMENT="1"
claude --model anthropic/nvidia_nim/nvidia/nemotron-3-super-120b-a12b
```

* `curl /health` harus `{"status":"healthy"}`
* `curl /v1/models` harus list model FCC
* Di `claude`, `/model` pilih model `anthropic/...`

## Model & biaya

* Default: `nvidia_nim/...` (jatah NIM, reset berkala)
* Fallback: `open_router/...` (pay-as-you-go, tidak ada reset per 5 jam)
* Varian `:free` / `openrouter/free` untuk darurat saldo 0 (rate-limit)
* Model bayar via OpenRouter (misal Claude Fable) butuh top up, error khas: `402 Upstream provider OPENROUTER ... only afford 800`

Detail langkah: `docs/setup.md`.

## Credit

Gateway memakai [free-claude-code](https://github.com/Alishahryar1/free-claude-code) oleh Alishahryar1 (MIT). Repo ini hanya dokumentasi setup pribadi multi-device, bukan fork/afliasi resmi.
