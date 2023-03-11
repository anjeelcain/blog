---
title: OpenBSD Deep Install
author: Anjeel
date: 07 Mar 2023
...

A few months ago I started using OpenBSD because the Linux kernel was quickly proceeding down an unstable path. I looked for an alternative and the one that made the most sense to me was OpenBSD. (why?)

Why? Simplicity and security are some of the reasons why I chose it. OpenBSD follows the Unix philosophy and does not bloat the system with "pointless features" that open doors to several security flaws. Additionally, they perform line-by-line auditing, which contributes to the code being very clean. 

Following the [OpenBSD installation guide](https://www.openbsd.org/faq/faq4.html), you will have a basic system installed on your machine. However, in this guide, I intend to show you some "dirty tricks" that I've learned and how to use OpenBSD as a desktop operating system.
![](https://user-images.githubusercontent.com/82726847/221463720-d93975eb-5ebd-435b-980b-30e033dad643.png)

----

1. [File Sets](#file-sets)
2. [Basic Configuration](#basic-configuration)
3. [X](#x)

----
## File Sets

During the installation, you'll come across a stage that establishes the base for your system, the file sets. Sets are "segmented parts" of the system, and you'll have the option to select whether or not to include them. 

In my install, i selected these sets: 

```
    [X] bsd           [X] comp72.tgz    [X] xshare72.tgz
    [X] bsd.mp        [X] man72.tgz     [ ] xfont72.tgz
    [ ] bsd.rd        [ ] game72.tgz    [X] xserv72.tgz
    [X] base72.tgz    [X] xbase72.tgz   

```

Some sets are essential for a functional desktop, but the sets you need to choose will depend on your usage. For example, I don't need the ramdisk or games sets, and in the case of the xfonts set, as I unchecked it, I will need to install fonts later to bring up X. I will install my preferred fonts, so I don't need to have the default fonts that come with the system on my machine.

## Basic Configuration 

The first thing that I see as essential step is disable the damn beep/bell.

```shell
$ echo 'keyboard.bell.volume=0' >> /etc/wsconsctl.conf 
$ wsconsctl keyboard.bell.volume=0
```

Check for firmware updates and patches.
```shell
$ syspatch && fw_upgrade
```

Add your user to the staff and operator groups. These groups provide more [permissions and resources](https://man.openbsd.org/login.conf). 

```shell
$ usermod -G staff your_username_here
$ usermod -G operator your_username_here
```

Now, configure [`doas`](https://man.openbsd.org/doas), a tool that allows us to run commands with privileged permissions, basically a simpler and more intuitive alternative to sudo.

```shell
$ echo 'permit persist keepenv your_username_here' > /etc/doas.conf
```

Remove Google from NTPD. You can choose any domain to ping.
```
$ sed -i 's/www\.google\.com/www.suckless.org/' /etc/ntpd.conf
$ rcctl restart ntpd
```

You can improve disk perfomance, just add the `softdep` and `noatime` "flags" on your partitions in `/etc/fstab`. For example: 

```shell
9e8e56fe224a93.a / ffs rw,wxallowed,softdep,noatime 1 1
```

## X

You can start X with Xenodm or directly with xinit or xorg, but I recommend using Xenodm. First thing is enable xenodm to start.

```shell
$ rcctl enable xenodm
```

Now you need to configure your startup file, which you can create as ~/.xsession or configure in your Xenodm and place the directory of the file wherever you want. Example:

```
# ~/.xsession

# Load envs variables
. $HOME/.profile

# Keyboard key delay
xset r rate 200 40 &

# Keyboard layout
setxkbmap -layout us &

# Disable core dump
ulimit -Sc 0 & 

exec cwm
```

You can disable the D-Bus session by simply setting this the environment variable above in your ~/.profile, for example, and loading it in your ~/.xsession, as shown in the previous example.

`export DBUS_SESSION_BUS_ADDRESS=no` 
