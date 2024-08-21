# Ansible Playbook Runner for Windows with WSL

This repository provides scripts and instructions for running an Ansible playbook on a Windows machine using Windows Subsystem for Linux (WSL). The provided scripts include a PowerShell script and a Python script that can be used to execute the Ansible playbook through a simple GUI.

## Prerequisites

Before running the Ansible playbook, ensure that the following prerequisites are met:

- **Windows 10 or Windows 11**: Ensure your system is compatible with WSL.
- **WSL Installed**: You need to have WSL installed and set up on your Windows machine.
- **Ansible Installed in WSL**: Ansible must be installed within the WSL environment.
- **Python Installed on Windows**: Python must be installed on your Windows system to run the Python script.

## Installation Guide

### 1. Install and Set Up WSL

1. **Install WSL**:
   - Open PowerShell as Administrator and run the following command:
     ```powershell
     wsl --install
     ```
   - This command installs WSL 2 and the default Ubuntu LTS version. You may need to restart your computer after installation.

2. **Set Up WSL**:
   - After installation, open the Ubuntu terminal from the Start menu. This will finalize the installation and prompt you to set up your WSL user.
   - Follow the on-screen instructions to create a user and set a password.

### 2. Install Ansible in WSL

1. **Update Package Lists**:
   - Run the following commands in the Ubuntu terminal:
     ```bash
     sudo apt-get update
     ```

2. **Install Ansible**:
   - Install Ansible by running:
     ```bash
     sudo apt-get install ansible -y
     ```

3. **Verify Installation**:
   - Check that Ansible is installed correctly:
     ```bash
     ansible --version
     ```

### 3. Clone or Download the Repository

1. **Clone the Repository**:
   - Clone the repository containing the playbook and scripts to your local machine:
     ```bash
     git clone <your-repository-url>
     ```

2. **Navigate to the Directory**:
   - Change to the directory where the playbook and scripts are located:
     ```bash
     cd <repository-directory>
     ```

### 4. Running the Ansible Playbook from Windows

You can run the playbook using either the PowerShell or Python script provided.

#### 1. Run the PowerShell Script

1. **Open PowerShell as Administrator**.
2. **Navigate to the Script Directory**:
   ```powershell
   cd <path-to-directory>
   ```
3. **Run the Script**:
   ```powershell
   .\Run-AnsiblePlaybooks.ps1
   ```
4. **Use the GUI**:
   - The script will open a GUI where you can select and run the Ansible playbooks.

#### 2. Run the Python Script

1. **Ensure Python is Installed**: Download and install Python from [python.org](https://www.python.org/downloads/) if necessary.
2. **Open Command Prompt or PowerShell**.
3. **Navigate to the Script Directory**:
   ```powershell
   cd <path-to-directory>
   ```
4. **Run the Python Script**:
   ```bash
   python <script_name>.py
   ```
5. **Use the GUI**:
   - The script will open a GUI where you can select and run the Ansible playbooks.

### 5. Running the Ansible Playbook

1. **Select the Playbook**:
   - Use the GUI to select the appropriate playbook (`test-local-playbook.yml`).
2. **Execution**:
   - The playbook will execute, and a message box will inform you of the success or failure of the tasks.

### 6. Check the Results

- **Results Directory**: The results of the playbook execution are saved in a `results` directory within the script's directory.
- **CSV File**: Check the `ansible_results.csv` file in the `results` directory for detailed execution logs.

### 7. Customizing the Playbook

- **Edit the Playbook**: You can customize the provided playbook (`test-local-playbook.yml`) by editing it with any text editor.
- **Adjust Tasks**: Modify tasks as needed for different environments or OS versions.

### 8. Troubleshooting

- **Permissions**: Run PowerShell as Administrator when running the PowerShell script.
- **WSL Integration**: Ensure WSL is up to date and Ansible is correctly installed.
- **Python Dependencies**: Make sure all necessary Python libraries (like `tkinter`) are installed. You can install `tkinter` using:
  ```bash
  sudo apt-get install python3-tk
  ```

### 9. Next Steps

- **Extend the Playbooks**: Add more playbooks or customize existing ones to meet your needs.
- **Share and Collaborate**: Push changes to this repository or share it with others.

### License

This project is licensed under the MIT License

### Acknowledgments

- **Ansible**: [Ansible](https://www.ansible.com/) is an open-source automation tool.
- **WSL**: [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/) allows running a Linux environment directly on Windows.

---

By following these instructions, you should be able to set up and run the provided Ansible playbook on your Windows machine using WSL. If you encounter any issues or have suggestions for improvements, feel free to open an issue or submit a pull request.
```
