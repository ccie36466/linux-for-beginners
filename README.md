# Linux for Beginners: lab files and scripts

The scripts, configuration files and practice data from the book **Linux for Beginners: The practical guide to the command line, Ubuntu, networking, SSH, security and shell scripting** by Simson Lubin (2× CCIE #36466), published by cciecorporation.com.

Every script here is exactly as printed in the book, passes [ShellCheck](https://www.shellcheck.net/) with no warnings (checked automatically on every change), and was run on Ubuntu Server 26.04 LTS.

## Get the files

On your Linux lab machine:

```bash
sudo apt install -y git
git clone https://github.com/ccie36466/linux-for-beginners.git
cd linux-for-beginners
```

No Git? Download a zip instead:

```bash
wget -O lfb.zip https://github.com/ccie36466/linux-for-beginners/archive/refs/heads/main.zip
sudo apt install -y unzip && unzip lfb.zip && cd linux-for-beginners-main
```

## What's inside

| Folder | Chapter | Files |
|---|---|---|
| `ch06-text-files/` | 6. Reading and Editing Text Files | `bashrc-aliases.txt`: the aliases to add to `~/.bashrc` |
| `ch07-text-tools/` | 7. Pipes, Redirection and Text Power Tools | `access.log`: the practice web log |
| `ch12-ssh/` | 12. SSH: Secure Remote Access | `10-hardening.conf`: the SSH hardening drop-in |
| `ch16-scripting/` | 16. Shell Scripting Fundamentals | `hello.sh`, `args.sh`, `checkdisk.sh`, `netcheck.sh`, `servers.txt` |
| `ch17-scheduling/` | 17. Scheduling with cron and systemd Timers | `disk-check.service`, `disk-check.timer` |
| `ch18-projects/1-nginx/` | 18. Project 1: a web server | `mysite`: the Nginx site configuration |
| `ch18-projects/2-snapshot-backup/` | 18. Project 2: snapshot backups | `snapshot-backup.sh` plus its service and timer |
| `ch18-projects/3-health-report/` | 18. Project 3: a daily health report | `health-report.sh` |
| `ch18-projects/4-netmon/` | 18. Project 4: a network and service monitor | `netmon.sh`, `targets.txt` plus its service and timer |
| `solutions/ch16/` | Appendix C: lab solutions | `sysinfo.sh`, `backup-file.sh` |

## How to use them

**Type them first.** You learn far more by typing a script from the book and fixing your own mistakes than by copying a file. Use this repository to check your version (`diff ~/bin/checkdisk.sh ch16-scripting/checkdisk.sh`) or when you need a working copy fast.

**Install a script** where the book puts it, for example:

```bash
mkdir -p ~/bin && cp ch16-scripting/checkdisk.sh ~/bin/ && chmod +x ~/bin/checkdisk.sh
sudo install -m 755 ch18-projects/3-health-report/health-report.sh /usr/local/bin/
```

**Install a systemd timer** (Chapter 17). The service runs `/usr/local/bin/checkdisk.sh`, so put the script there first:

```bash
sudo install -m 755 ch16-scripting/checkdisk.sh /usr/local/bin/
sudo cp ch17-scheduling/disk-check.service ch17-scheduling/disk-check.timer /etc/systemd/system/
sudo systemctl daemon-reload && sudo systemctl enable --now disk-check.timer
systemctl list-timers disk-check.timer
```

**SSH hardening (Chapter 12):** set up and test key login first, keep a second session open, then:

```bash
sudo cp ch12-ssh/10-hardening.conf /etc/ssh/sshd_config.d/
sudo nano /etc/ssh/sshd_config.d/10-hardening.conf   # put your own user names on the AllowUsers line
sudo sshd -t && sudo systemctl restart ssh
```

Read every script before you run it, and run them on a lab machine first, exactly as the book teaches.

## Corrections and questions

If something doesn't work on your system, open an issue with your Ubuntu version (`cat /etc/os-release`), the command you ran and the full error message.

## Licence

MIT: use, change and share these files freely, including at work. See `LICENSE`. The book's text is copyright and isn't part of this repository.
