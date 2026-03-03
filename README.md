# Ansible WSL Playbook Runner

GUI front-end for running Ansible playbooks through WSL on Windows — no terminal required.

Drop a `.yml` file into `playbooks/` and it shows up as a button. Every run is logged to `results/run-log.csv`.

Two launchers included — PowerShell (Windows Forms) or Python (tkinter), same behavior.

## Quick start

**Prerequisites:**
- Windows 10/11 with WSL installed (`wsl --install`)
- Ansible in WSL: `sudo apt install ansible -y`
- Python 3.9+ on Windows (Python GUI only)

**Setup:**
```bash
git clone git@github.com:RedBeret/ansible-wsl-playbook-runner.git
cd ansible-wsl-playbook-runner

# Copy playbooks and inventory into your WSL home
wsl cp -r playbooks/ ~/playbooks/
wsl cp inventory ~/inventory
```

**Run (PowerShell GUI):**
```powershell
# Right-click → "Run with PowerShell", or from an elevated prompt:
powershell -ExecutionPolicy Bypass -File .\Run-AnsiblePlaybooks.ps1
```

**Run (Python GUI):**
```powershell
python ansible_gui.py
```

## Adding playbooks

Drop any `.yml` into `playbooks/`, copy it to WSL, and reopen the GUI — it appears automatically:
```bash
wsl cp playbooks/your-playbook.yml ~/playbooks/
```

## Included playbooks

| Playbook | What it does |
|---|---|
| `test-local.yml` | Smoke test — confirms Ansible is working, checks filesystem write |
| `system-info.yml` | Reports OS, CPU, memory, disk, and network interfaces |

## Run log

Every execution is appended to `results/run-log.csv` (`results/` is gitignored):

```
Timestamp,Playbook,Status,Output
2025-01-15 14:22:01,test-local.yml,Success,...
```

## Architecture

```
.
├── Run-AnsiblePlaybooks.ps1   # PowerShell/WinForms GUI
├── ansible_gui.py             # Python/tkinter GUI
├── inventory                  # Ansible inventory (localhost)
├── playbooks/
│   ├── test-local.yml         # WSL smoke test
│   └── system-info.yml        # System facts report
└── results/                   # Run logs (gitignored)
```

## Key decisions

- **Dynamic discovery** — no hardcoded playbook lists; add a file, it appears
- **No hardcoded paths** — WSL home resolved at runtime via `wsl echo $HOME`
- **Proper CSV logging** — uses `Export-Csv` (PS) and `csv.writer` (Python) so commas in output don't corrupt the log
- **Closure fix** — PowerShell button callbacks use `.GetNewClosure()` to capture loop variables by value, not reference

## License

MIT
