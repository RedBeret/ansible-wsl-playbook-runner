import subprocess
import tkinter as tk
from tkinter import messagebox
import csv
import os
from datetime import datetime

def run_playbook(playbook):
    try:
        # Adjust the command to use `wsl` to run Ansible from WSL
        result = subprocess.run(
            ["wsl", "ansible-playbook", "-i", "/home/redberet/inventory", f"/home/redberet/{playbook}"],
            capture_output=True, text=True, check=True
        )
        output = result.stdout
        status = "Success"
        messagebox.showinfo("Success", f"{playbook} ran successfully!\nOutput:\n{output}")
    except subprocess.CalledProcessError as e:
        output = e.stderr
        status = "Failed"
        messagebox.showerror("Error", f"Failed to run {playbook}.\nError:\n{output}")

    # Write the result to a CSV file
    write_csv(playbook, status, output)

def write_csv(playbook, status, output):
    # Ensure the results directory exists
    results_dir = "results"
    if not os.path.exists(results_dir):
        os.makedirs(results_dir)

    # Define the CSV file path
    csv_file = os.path.join(results_dir, "ansible_results.csv")

    # Write the results to the CSV file
    with open(csv_file, mode='a', newline='') as file:
        writer = csv.writer(file)
        # Write header if the file is new
        if file.tell() == 0:
            writer.writerow(["Timestamp", "Playbook", "Status", "Output"])

        # Write the result row
        writer.writerow([datetime.now(), playbook, status, output])

def create_gui():
    root = tk.Tk()
    root.title("Ansible Playbook Runner")
    
    label = tk.Label(root, text="Choose a playbook to run:")
    label.pack(pady=10)
    
    playbook_buttons = [
        ("Run Test Playbook", "test-playbook.yml"),
        ("Run Local Playbook", "test-local-playbook.yml"),
    ]
    
    for text, playbook in playbook_buttons:
        button = tk.Button(root, text=text, command=lambda p=playbook: run_playbook(p))
        button.pack(pady=5)
    
    root.mainloop()

if __name__ == "__main__":
    create_gui()
