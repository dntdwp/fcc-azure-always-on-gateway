# Setup (tanpa secret — ganti <> dengan punyamu)

## 1. VM Azure

* Size `Standard_B2ats_v2`, Ubuntu 24.04, disk 30GB Standard SSD
* Public IP Static Standard, NSG inbound: SSH 22 only
* SSH: `ssh -i <PATH_KE_PEM> azureuser@<VM_PUBLIC_IP>`
* `.pem` hanya di 1 device, permission ketat, jangan disebar

## 2. Install FCC

```bash
sudo apt update && sudo apt upgrade -y
# install FCC via install.sh, pilih agent yang dipakai
# buat service systemd agar always-on
sudo systemctl enable --now fcc
sudo systemctl status fcc --no-pager
journalctl -u fcc -n 50 --no-pager
curl -s http://127.0.0.1:8082/health
```

Contoh unit: `systemd/fcc.service.example`.

## 3. Admin via tunnel (jangan buka 8082 publik)

```powershell
ssh -i <PATH_KE_PEM> -L 8082:localhost:8082 azureuser@<VM_PUBLIC_IP>
# buka http://localhost:8082/admin
```

* Set Providers (NIM / OpenRouter / OpenAI), Model Default + Fallback, Apply
* Jika `Apply: Failed to fetch`, edit `/home/azureuser/.fcc/.env` via SSH lalu `sudo systemctl restart fcc`

## 4. Tailscale

* Install di VM + tiap device, `tailscale up`
* Device sendiri: login akun yang sama
* Teman: Share machine `fcc-server` via invite, Accept, matikan reusable link setelah join
* Verifikasi: `ping <TAILSCALE_FCC_IP>`, `curl http://<TAILSCALE_FCC_IP>:8082/health`

## 5. Claude Code per device

```powershell
$env:ANTHROPIC_BASE_URL="http://<TAILSCALE_FCC_IP>:8082"
$env:ANTHROPIC_API_KEY="<PROXY_TOKEN>"
$env:CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY="1"
$env:CLAUDE_CODE_DISABLE_MODEL_WINDOW_ENFORCEMENT="1"
claude --model anthropic/nvidia_nim/nvidia/nemotron-3-super-120b-a12b
```

* Jika disuruh login: pilih API key, isi token proxy, pilih `Yes`
* Hanya set satu dari `ANTHROPIC_API_KEY` / `ANTHROPIC_AUTH_TOKEN` agar tidak warning
* `/model` harus muncul model FCC, bukan cuma model lokal

## 6. Operasional

* Cek saldo di dashboard provider (OpenRouter credits/activity, NIM billing, OpenAI usage)
* FCC `Code sessions` hanya tunjukkan token terpakai, bukan sisa
* Rotate key bocor: buat key baru di provider → update Admin/`.env` → restart → hapus key lama
