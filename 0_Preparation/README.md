<a name="top"></a>
# Preparing for the SDSC Summer Institute 2025

You will get the most out of the SDSC Summer Institute if you prepare prior to the event. By brushing up on your knowledge of Linux and installing all necessary software on your laptop before we start, you’ll be able to focus your attention on the skills and topics that are most relevant to high performance and data intensive computing.

This section contains a set of detailed start-up instructions for setting up your account, connecting to Expanse and configuring your laptop to run the visualization software. Please read the documents and exercises carefully, and complete all necessary steps before the event. Feel free to ask questions or if you have any problems with the start-up tasks.

## Preparation Checklist

Here is a summary of tasks to be completed before the institute begins:

- [ ] **Set up your accounts:**
    - [ ] [Create a GitHub account](#github).
    - [ ] Look for an email about your Expanse training account.
- [ ] **Install required software:**
    - [ ] [Install required software](./software_requirements.md) on your laptop.
    - [ ] [Install Slack](#slack) and join the workspace.
    - [ ] [Install Zoom](#zoom).
- [ ] **Review basic HPC skills:**
    - [ ] [Connecting Securely to SDSC HPC Systems](#basic-hpc-skills)
    - [ ] [Basic Linux Skills for Expanse](#basic-hpc-skills)
    - [ ] [Interactive Computing on Expanse](#basic-hpc-skills)
    - [ ] [Using GitHub on Expanse](#basic-hpc-skills)
- [ ] **Attend Preparation Day:**
    - [ ] [Join the virtual Prep Day on Tuesday, July 29, 2025, from 9am-11am (Pacific Time).](https://github.com/sdsc/sdsc-summer-institute-2025/tree/main/1.0_preparation_day_welcome_and_orientation)

Contents
* [Expanse User Guide](#expanse-user-guide)
* [HPC Systems Accounts](#hpc-systems-accounts)
* [Computer Requirements](#computer-requirements)
* [Preparation Activities](#preparation-activities)
   * [Basic HPC Skills](#basic-hpc-skills)
   * [Launching Jupyter Notebooks](#launching-jupyter-notebooks)
* [Software Requirements](#software-requirements)
* [GitHub, Slack, and Zoom](#github-slack-and-zoom)
    * [Github](#github)
    * [Slack](#slack)
    * [Zoom](#zoom)
  
## Expanse User Guide
We will cover the basics of using Expanse during the institute. However, the [Expanse User Guide](https://www.sdsc.edu/support/user_guides/expanse.html) is a comprehensive resource that you should keep handy for reference. After the institute, you may need to review details about specific configurations. Here are some key points from the guide that you may find useful:

*   **System Architecture**: Expanse has different types of nodes for various computational needs, including standard compute nodes, GPU nodes with NVIDIA V100s, and large-memory nodes.
*   **File Systems**: You will have access to different file systems:
    *   `$HOME` (`/home`): 100GB for source code and configuration files (backed up). **Do not run jobs from here.**
    *   `/expanse/lustre/scratch`: Large, high-performance space for temporary job data. **Not backed up, and files are purged after 90 days.**
    *   `/expanse/lustre/projects`: Project-specific storage space.
    *   `/scratch/$USER/job_$SLURM_JOB_ID`: Fast, temporary local storage on compute nodes, available only during job execution.
*   **Connecting**: Connect to Expanse via SSH with two-factor authentication (2FA).
*   **Software Environment**: Manage software with `module`. Use `module spider <package_name>` to find available packages.
*   **Running Jobs**: Submit jobs to the Slurm scheduler with `sbatch`. Use `srun` for interactive sessions. Example scripts are in `/cm/shared/examples/sdsc/` on Expanse.

Please keep the link to the full guide ready. It will be a valuable resource for you.

[Back to Top](#top)
<hr>

##  HPC Systems Accounts
You will need a training account to access SDSC’s Expanse HPC system for the HPC & Data Science Summer Institute. This account will be created for you by our team. 

An email will be sent from consult@sdsc.edu with the subject line "HPC & Data Science 2025 Summer Institute: Account Set-Up" that will include your training account username and password and instructions.
We will send this email in time for  "Prep Day," where we will be covering how to manage your training account, along with other useful information. 

As a reminder, we are asking all attendees to use the training accounts that we are providing, even if you already have your own account. This will minimize problems related to custom configurations (e.g. environment variables, choice of shell, etc.) that may cause some of the hands-on examples to break. 

This training account may be used:
  * Via SSH directly to login.expanse.sdsc.edu
  * Via a special page on the Expanse Portal: https://portal.expanse.sdsc.edu/training
  * * For this institute, please do not use portal.expanse.sdsc.edu.

[Back to Top](#top)
<hr>

 ## Computer Requirements
* Laptop Required: The HPC and Data Science Summer Institute is designed as a hands-on program and does require that you bring a laptop with administrative privileges and wireless connectivity.
* WiFi will be available throughout the SDSC building
* Remember your charger. There will be extension cords throughout the room for charging devices.

[Back to Top](#top)
<hr>

## Preparation Activities
The Summer Institute is a combination of in-depth lectures and hands-on learning. The following documents will guide you through the necessary steps needed to be prepared to get to work when you arrive at the Institute.

### Basic HPC Skills
* [Connecting Securely to SDSC HPC Systems](https://github.com/sdsc-hpc-training-org/hpc-security): A guide to securely connecting to SDSC's High-Performance Computing (HPC) systems, covering SSH, passwordless login with SSH keys, and two-factor authentication.
    * WATCH - [Indispensable Security: Tips to Use SDSC's HPC Resources Securely](https://education.sdsc.edu/training/interactive/202007_security_tips/index.php): An interactive video tutorial on security best practices for using SDSC's HPC resources.
* [Basic Linux Skills for Expanse](https://github.com/sdsc-hpc-training-org/basic_skills/tree/master/basic_linux_skills_expanse): A tutorial covering fundamental Linux commands for navigating the file system, managing files and directories, and understanding file permissions on the Expanse supercomputer.
* [Interactive Computing on Expanse](https://github.com/sdsc-hpc-training-org/basic_skills/tree/master/interactive_computing): Learn how to request and use interactive sessions on Expanse for both CPU and GPU nodes, allowing for real-time code development and data exploration.
* [Using GitHub on Expanse](https://github.com/sdsc-hpc-training-org/basic_skills/tree/master/using_github): Instructions on how to set up and use Git and GitHub on SDSC systems for version control and collaboration.

### Launching Jupyter Notebooks
There are several methods for launching a secure Jupyter Notebook on Expanse:
* Using the ```galyleo``` shell utility: https://github.com/mkandes/galyleo
* Using the Expanse Portal:   https://portal.expanse.sdsc.edu
* Setting up CONDA Environments and Jupyter Notebook on Expanse:  [https://github.com/sdsc-hpc-training-org/notebooks-sharing](https://github.com/sdsc-hpc-training-org/notebooks-sharing)

[Back to Top](#top)
<hr>

## Software Requirements
The document below contains a list of software being used at the institute and installation instructions:
* [Software Requirements](./software_requirements.md)

[Back to Top](#top)
<hr>

## GitHub, Slack, and Zoom

### Github
* Training material will be located on the SDSC Summer Institute [GitHub repo](https://github.com/sdsc/sdsc-summer-institute-2025/tree/main) and one of the Wednesday sessions will require a GitHub account.
* If you do not already have one, you can create a free personal GitHub account [here](https://docs.github.com/en/github/getting-started-with-github/signing-up-for-github/signing-up-for-a-new-github-account).  
* For basic GitHub usage on SDSC systems, see [here](https://github.com/sdsc-hpc-training-org/basic_skills/tree/master/using_github)

### Slack
* We will also be using Slack as our main platform for announcements, where participants can communicate and ask for help. Download ([Windows](https://slack.com/downloads/windows), [MacOS](https://slack.com/downloads/mac), or [Linux](https://slack.com/downloads/linux)) and [get started](https://slack.com/help/articles/218080037-Getting-started-for-new-Slack-users). Zoom chat will be disabled during the preparation day. Make sure to turn on your Slack notifications to receive alerts.
* See "Preparation Information | HPC & Data Science Summer Institute 2025" email received for the link to join the Slack workspace for this institute.

### Zoom
* We will be using Zoom for preparation day on Tuesday, July 29, 2025, from 9am-11am (Pacific Time).
* You will need to install the latest [Zoom](https://zoom.us/download) client, which is available for Windows, MacOS and Linux. Once installed, you can test your microphone and camera interface with Zoom [here](https://zoom.us/test). You can find more information on Zoom system requirements, including bandwidth requirements [here](https://support.zoom.us/hc/en-us/articles/201362023-System-Requirements-for-PC-Mac-and-Linux).

Connection details were sent as a calendar invite to all HPC & DS participants. You would have received an invite for the preparation day on Tuesday, July 29, 2025, from 9am - 11am (Pacific Time) early in July. 

Note: While Prep Day is a virtual event, the main HPC & Data Science Summer Institute sessions (Monday, August 4 - Friday, August 8) will be held in person and will not be available remotely.

[Back to Top](#top)

