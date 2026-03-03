"""
ansible_gui.py — cross-platform GUI front-end for running Ansible playbooks via WSL.

Discovers .yml files in the playbooks/ directory next to this script.
Logs each run to results/run-log.csv.
"""

import csv
import os
import subprocess
import sys
import tkinter as tk
from datetime import datetime
from pathlib import Path
from tkinter import messagebox

SCRIPT_DIR = Path(__file__).parent.resolve()
PLAYBOOK_DIR = SCRIPT_DIR / "playbooks"
RESULTS_DIR = SCRIPT_DIR / "results"
LOG_FILE = RESULTS_DIR / "run-log.csv"
LOG_HEADER = ["Timestamp", "Playbook", "Status", "Output"]

# Inventory path inside WSL — relative to the WSL user home
WSL_INVENTORY = "inventory"


def get_wsl_home() -> str:
    """Resolve the WSL default user's home directory dynamically."""
    result = subprocess.run(
        ["wsl", "echo", "$HOME"],
        capture_output=True, text=True
    )
    return result.stdout.strip()


def discover_playbooks() -> list[str]:
    """Return sorted list of .yml filenames in the playbooks directory."""
    if not PLAYBOOK_DIR.exists():
        return []
    return sorted(p.name for p in PLAYBOOK_DIR.glob("*.yml"))


def write_log(playbook: str, status: str, output: str) -> None:
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)
    write_header = not LOG_FILE.exists() or LOG_FILE.stat().st_size == 0
    with open(LOG_FILE, mode="a", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        if write_header:
            writer.writerow(LOG_HEADER)
        writer.writerow([
            datetime.now().isoformat(timespec="seconds"),
            playbook,
            status,
            output.replace("\n", " "),
        ])


def run_playbook(playbook: str, wsl_home: str) -> None:
    cmd = [
        "wsl", "ansible-playbook",
        "-i", f"{wsl_home}/{WSL_INVENTORY}",
        f"{wsl_home}/playbooks/{playbook}",
    ]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        output = result.stdout + result.stderr

        if result.returncode != 0:
            status = "Failed"
            messagebox.showerror("Failed", f"{playbook} failed.\n\n{output}")
        elif "FAILED! =>" in output:
            status = "Partial"
            messagebox.showwarning("Partial Success", f"{playbook} ran with failures.\n\n{output}")
        else:
            status = "Success"
            messagebox.showinfo("Success", f"{playbook} completed successfully.\n\n{output}")

    except FileNotFoundError:
        status = "Error"
        output = "wsl not found — is WSL installed?"
        messagebox.showerror("Error", output)
    except Exception as exc:
        status = "Error"
        output = str(exc)
        messagebox.showerror("Error", f"Unexpected error: {exc}")

    write_log(playbook, status, output)


def create_gui(playbooks: list[str], wsl_home: str) -> None:
    root = tk.Tk()
    root.title("Ansible WSL Playbook Runner")
    root.resizable(False, False)

    tk.Label(root, text="Select a playbook to run:", pady=8).pack()

    for pb in playbooks:
        tk.Button(
            root,
            text=pb,
            width=40,
            command=lambda p=pb: run_playbook(p, wsl_home),
        ).pack(pady=3, padx=12)

    tk.Label(root, text=f"Log: {LOG_FILE}", fg="gray", font=("", 8)).pack(pady=6)
    root.mainloop()


def main() -> None:
    playbooks = discover_playbooks()
    if not playbooks:
        print(f"No .yml playbooks found in {PLAYBOOK_DIR}. Add playbooks and rerun.", file=sys.stderr)
        sys.exit(1)

    wsl_home = get_wsl_home()
    if not wsl_home:
        print("Could not resolve WSL home directory. Is WSL running?", file=sys.stderr)
        sys.exit(1)

    create_gui(playbooks, wsl_home)


if __name__ == "__main__":
    main()
