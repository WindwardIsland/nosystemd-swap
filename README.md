# nosystemd-swap

This repository was originally forked from the [runit-swap](https://github.com/thypon/runit-swap) repository, as I saw it as a really nice method not just to enable zram using a somewhat well-written shell script, but also zswap, using a swapfile, etc.

I had been looking for quite some time now for a good program on Linux that would enable zram for me automatically, without the need to having to do it [manually](https://www.kernel.org/doc/Documentation/vm/zswap.txt). However, most of the "zram generators" for Linux out there are SystemD only (even SystemD itself has its own [zram generator](https://github.com/systemd/zram-generator)), which don't work on Linux distributions like Void or Artix Linux since they don't use SystemD as their primary init system.

There's always tools like [zramen](https://github.com/atweiden/zramen) or [zramd](https://github.com/maximumadmin/zramd)(which includes a SystemD service when installed, but the program can be run manually from the terminal, allowing it to [work on any init system](https://github.com/maximumadmin/zramd?tab=readme-ov-file#manual-installation-on-any-distribution-without-systemd)) but I always had issues with these tools not creating the amount of size for zram I specified, most likely since both of these tools create zram based on a fraction of your actual RAM.

I then found runit-swap and while I really liked the idea of just being a wrapper shell script that uses `modprobe` and `zramctl` under the hood to create and enable zram, it unfortunately only supports runit and has not been updated in the last 8 years. Hence, this fork exists to be more up-to-date than upstream, and to work on init systems other than runit.
