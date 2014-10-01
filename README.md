# Signal & Noise
<!--*A workload generation for the modern architecture*-->
 

## The Story
Proof of Concept testing in the storage world right now is unfortunate. There's little standardization. There is nearly no documentation. 

For me, this [started as a blog post](http://blog.infinio.com/workload-generation-youre-doing-it-wrong), then [got stage time at VMworld](https://www.youtube.com/watch?v=2ZxHF6jXhgY). Interest has made it into this project that could be much more within our community.

Before this conversation came to light, you may have spun up iometer on one or two VMs in your VMware infrastructure. You send a few threads worth of I/O to your new system and you either say "looks good enough" or "nope, that won't work." 

If the goal is to make an educated decision for production based on testing, you've failed. You can do better if we all start reviewing our assumptions and testing goals.




## Assumptions
You're looking to test both **scale** and **I/O type**. 

##### For Scale
To ensure your tests simulate production, run S&N on **each cluster** you have available to test. If you do not, then you've only tested how well this product will work on a single cluster when your real storage system runs dozens of workloads from dozens of sources. The testers recommend **at least 3 VMs per host**. To simulate standalone hosts, you can run S&N using the Vagrantfile *(coming soon)*.

##### For I/O Type
To ensure your tests simulate production, run S&N using fio profiles that have seeded content. This behavior is by design from default, but you may develop your own fio profiles or use other example profiles in a way that gets away from it. Whatever you do, **ensure your additional workloads start as seed files.** Otherwise you are generating a very diffent I/O pattern than you mean to. 

## How-to

##### Prereqs
* VMware environment managed by vCenter
* Cluster with unused network which has DHCP enabled
* Windows system to run Powershell script
* Familiarity with PowerCLI *(can be learned in ~1 hour)*

##### Running S&N
* Use `Connect-VIServer` to connect to your vCenter
* Then, edit `Deploy-Template-Dhcp.ps1` to represent your environment
* Next, check the `$DataStore`, `$Folder` and `$Cluster` settings in particular under Step 1 (in the script)
* Next, choose the appropriate number of VMs to deploy and their preferred prefix.

**Note:** Each VM has a random likelihood of being either a higher cacheable workload or a lower cacheable workload. Both produce around ~100 IOPS at 4KB

##### What's it do?
* `Deploy-Template-Dhcp.ps1` deploys 1 or more workload VMs and boots them up
* On startup, each VM uses `wlconfig.py` to discover its peers on the subnet (including itself)
* `Crontab` is set to run either at a higher cacheable workload or lower. These scripts are located in `/user/`
* The workloads are variable time periods and result in random peak workloads quite representative of a production virtualized workload

##### Tips and Tricks
Every VM has [Ansible](http://docs.ansible.com/intro_getting_started.html) installed for its ad-hoc commands. That means you can login to ANY of the consoles and administrate over the entire set of workloads. I often run: 
* Run `ansible all -m shell -a "ps aux | grep bash" --ask-pass` to verify each VM is actively running workload
* Run `ansible all -m shell -a "pkill bash-fio" --ask-pass` to stop all workloads without turning the VMs off
* Use `ansible all:\!10.1.1.40 -m shell -a "reboot" --sudo --ask-pass` to reboot all VMs without rebooting the VM you sent the command from. Change the IP appropriately - leave the `!`

###This project leverages: 
* [Ubuntu Linux](http://www.ubuntu.com/)
* [fio to generate I/O](http://linux.die.net/man/1/fio)
* [PowerCLI](https://www.vmware.com/support/developer/PowerCLI/PowerCLI55R2/powercli55r2-releasenotes.html) and [PowerShell](http://powershell.com/cs/) for deployment
* [Ansible](http://docs.ansible.com/intro_getting_started.html) for configuration management and ad-hoc commands

