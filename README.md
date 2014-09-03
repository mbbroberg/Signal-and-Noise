# Signal & Noise
#### A workload generation for the modern storage architecture
--- 

# The Story
Proof of Concept testing in the storage world right now is unfortunate. There's little standardization. There is nearly no documentation. 

This [started as a blog post](http://blog.infinio.com/workload-generation-youre-doing-it-wrong), then [got stage time here](https://www.youtube.com/watch?v=2ZxHF6jXhgY). Interest has made it into this project.

Before this conversation came to light, you may have spun up iometer on one or two VMs in your VMware infrastructure. You send a few threads worth of I/O to your new system and you either say "looks good enough" or "nope, that won't work." 

If the goal is to make an educated decision based on testing practices, you've failed. You can do better if we all start reviewing our assumptions and testing goals.




## Assumptions
You're looking to test both **scale** and **I/O type**. 

##### For Scale
To ensure your tests simulate production, run S&N on **each cluster** you have available to test. If you do not, then you've only tested how well this product will work on a single cluster when your real storage system runs dozens of workloads from dozens of sources. The testers recommend at least ___ clusters. To simulate standalone hosts, you can run S&N using the Vagrantfile *(coming soon)*.

##### For I/O Type
To ensure your tests simulate production, run S&N using fio profiles that have seeded content. This behavior is by design from default, but you may develop your fio profiles in a way that gets away from it. Whatever you do, **ensure your additional workloads start as seed files.** Otherwise you are generating a very diffent I/O pattern than you mean to. 

## How-to

TODO


###This project leverages: 
* [Ubuntu Linux](http://www.ubuntu.com/)
* [fio to generate I/O](http://linux.die.net/man/1/fio)
* [PowerCLI](https://www.vmware.com/support/developer/PowerCLI/PowerCLI55R2/powercli55r2-releasenotes.html) and [PowerShell](http://powershell.com/cs/) for deployment
* [Ansible](http://docs.ansible.com/intro_getting_started.html) for configuration management and ad-hoc commands

