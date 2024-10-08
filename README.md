# nosystemd-swap

This repository was originally forked from the [runit-swap](https://github.com/thypon/runit-swap) repository since I saw it as a nice method to either enable and use zram, zswap, or a swapfile, just by running a wrapper shell script.

I had been looking for quite some time now for a good program on Linux that would enable zram for me automatically, without having to do it [manually](https://wiki.archlinux.org/title/Zram#Manually). However, most of the "zram generators" for Linux out there are SystemD only (even SystemD itself has its own [zram generator](https://github.com/systemd/zram-generator)), which don't work on Linux distributions like Void or Artix Linux since they don't use SystemD as their primary init system.

There's always tools like [zramen](https://github.com/atweiden/zramen) or [zramd](https://github.com/maximumadmin/zramd) (which includes a SystemD service when installed, but the program can be run manually from the terminal, allowing it to [work on any init system](https://github.com/maximumadmin/zramd?tab=readme-ov-file#manual-installation-on-any-distribution-without-systemd)) but I always had issues with these tools not creating the amount of size for zram I specified, most likely since both of these tools create zram based on a fraction of your actual RAM.

I then found runit-swap and while I really liked the idea of just being a wrapper shell script that uses `modprobe` and `zramctl` under the hood to create and enable zram, it unfortunately only supports runit and has not been updated in the last 8 years. Hence, this fork exists to be more up-to-date and to work on init systems other than runit.

## Installation

Clone this repository, and make any necessary modifications inside `swap.conf`. 

You can enable or disable zswap, zram, a universal swap file, or a chunked swap file by setting the corresponding value to either `0` or `1`.
For example, if I wanted to only enable zram, I would only set `zram_enabled` to 1 and change the zram-related settings.

**NOTE**: Leave the `swapd_auto_swapon` value to be 1 despite any other modifications you have made so that all available swap devices are always toggled on.

Once you're done with your modifications inside `swap.conf`, you can now run the `install.sh` script with the following command:
```
$ sudo ./install.sh
```

**NOTE**: The instructions for installation in this README use `sudo`, but replace `sudo` with `doas` if you use that instead.

This will copy over the necessary service files to directories that your init system uses to manage services. Once that's done, we're now ready to enable and start the nosystemd-swap service for our init system in the next step.

### Enabling the service
#### runit

Void Linux:
```
$ sudo ln -s /etc/sv/nosystemd-swap /var/service/
```
Artix Linux (runit flavor):
```
$ sudo ln -s /etc/runit/sv/nosystemd-swap /run/runit/service/
```

#### dinit

Artix Linux (dinit flavor) (and possibly Chimera Linux as well, though untested):
```
$ sudo dinitctl enable nosystemd-swap
```
**NOTE**: As of right now, this only supports the runit and dinit init systems. OpenRC and s6 will be supported in the future. This means that this will work on Void, Artix (the runit and dinit flavors), and possibly Chimera Linux, but not Gentoo or the OpenRC and s6 flavors of Artix.
