# nosystemd-swap

This repository was originally forked from the [runit-swap](https://github.com/thypon/runit-swap) repository since I saw it as a nice method to either enable and use zram, zswap, or a swapfile, just by running a wrapper shell script.

I had been looking for quite some time now for a good program on Linux that would enable zram for me automatically, without having to do it [manually](https://wiki.archlinux.org/title/Zram#Manually). However, most of the "zram generators" for Linux out there are SystemD only (even SystemD itself has its own [zram generator](https://github.com/systemd/zram-generator)), so they don't work on Linux distributions like Void or Artix Linux since they don't use SystemD as their primary init system.

There's always tools like [zramen](https://github.com/atweiden/zramen) or [zram-init](https://github.com/vaeth/zram-init), but I always had issues with these tools not creating the amount of size for zram I specified, most likely since they initialize zram based on a fraction of your actual RAM amount. They also don't support **all** non-SystemD init systems, so I wanted a **single** solution that works on all of them without having to use multiple tools.

I then found runit-swap and while I really liked the idea of just being a wrapper shell script that uses `modprobe` and `zramctl` under the hood to create and enable zram, it unfortunately only supports runit and has not been updated in the last 8 years. Hence, this fork exists to be more up-to-date and to work on init systems other than runit.

## Installation
### Init System Support
These are the currently supported init systems:
- [runit](https://smarden.org/runit/)
- [dinit](https://github.com/davmac314/dinit/)
- [OpenRC](https://wiki.gentoo.org/wiki/OpenRC)
- [s6](https://skarnet.org/software/s6/)/[s6-rc](https://skarnet.org/software/s6-rc/)

Support for these init systems will come in the near future:
- [suite66](https://web.obarun.org/software/66/latest/)
- [finit](https://troglobit.github.io/finit/) (possibility)
- [sinit](https://core.suckless.org/sinit/) (possibility)

### Configuration/Copying Files Over
> [!IMPORTANT]
> The instructions for installation in this README use `sudo`, but replace `sudo` with `doas` if you use that instead.

Clone this repository, and make any necessary modifications inside `swap.conf`. 

You can enable or disable zswap, zram, a universal swap file, or a chunked swap file by setting the corresponding value to either `0` or `1`. `0` disables the option, while `1` enables the option. 

For example, if I wanted to only enable zram, I would only set `zram_enabled` to 1 and change the zram-related settings. Make sure to disable any other type of swap that you are **not** using (e.g. zswap, universal swap file, etc) by setting the corresponding option(s) to `0`.

> [!IMPORTANT]
> Leave the `swapd_auto_swapon` value to be 1 despite any other modifications you have made so that all available swap devices are always toggled on.

Once you're done with your modifications inside `swap.conf`, you can now run the `install.sh` script with the following command:
```
$ sudo ./install.sh
```
This will copy over the necessary service files to directories that your init system uses to manage services. Once that's done, we're now ready to enable and start the `nosystemd-swap` service for our init system in the next step.

### Enabling and starting the service
#### runit

Void Linux:
```
$ sudo ln -s /etc/sv/nosystemd-swap /var/service/
```
Artix Linux (runit flavor):
```
$ sudo ln -s /etc/runit/sv/nosystemd-swap /run/runit/service/
```
Devuan Linux:
```
$ sudo ln -s /etc/sv/nosystemd-swap /etc/service/
```

#### dinit

Artix Linux (dinit flavor) (and possibly Chimera Linux as well, though untested):
```
$ sudo dinitctl enable nosystemd-swap
```
#### OpenRC

Artix Linux (OpenRC flavor) (and possibly Gentoo Linux w/ OpenRC as well, though untested):
```
$ sudo rc-update add nosystemd-swap default
$ sudo rc-service nosystemd-swap start
```
#### s6/s6-rc

> [!IMPORTANT]
> This assumes that you are using [`s6-frontend`](https://skarnet.org/software/s6-frontend)! Artix has this installed by default in its s6 flavor. If you do not, be sure to install it as the commands without the frontend differ drastically.

Artix Linux (s6 flavor):
- Synchronize the repository: `$ sudo s6 repo sync`
- Check the status of `nosystemd-swap` in the `current` set: `$ sudo s6 set status nosystemd-swap`
    - If it is `usable` (i.e. disabled), then change its status to `active` (i.e. enabled): `$ sudo s6 set enable nosystemd-swap`
- Commit the changes that were made to the `current` set: `$ sudo s6 set commit`
- Install the live database: `$ sudo s6 live install`
- By default, services managed with s6-rc are *down*. To start the service: `$ sudo s6 live start nosystemd-swap`
