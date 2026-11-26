# Building CarsonOS-Fedora

## Host requirements

- Fedora Linux host or dedicated Fedora build VM
- Same Fedora release and architecture as the target image
- `lorax-lmc-novirt`, `pykickstart`, `fedora-kickstarts`, and `spin-kickstarts`
- QEMU/KVM and libvirt virtualization support
- Fedora boot/netinstall ISO matching the target release
- Reliable network access and ample free disk space

## Why the builder uses virtualization

The build script invokes `livemedia-creator` with its normal virtualized workflow. It intentionally does not use `--no-virt`, which runs Anaconda directly on the host and has a larger host-risk surface.

## Kickstart profiles

Each profile includes Fedora's live base Kickstart and adds one desktop environment. Profiles are separate so an image contains one intended desktop rather than all desktop environments at once.

- `cinnamon.ks`: flagship image
- `kde.ks`: KDE Plasma
- `xfce.ks`: Xfce
- `gnome.ks`: GNOME
- `hyprland.ks`: experimental Wayland compositor setup

The exact package-group and package names can vary between Fedora releases. Validate the selected profile with `ksvalidator` and perform a full build before treating an ISO as release-ready.

## Validation and testing

Before publishing an image:

1. Validate the flattened Kickstart with `ksvalidator`.
2. Complete the ISO compose and inspect the Anaconda logs.
3. Boot the ISO in a disposable VM using both UEFI and BIOS where supported.
4. Confirm the live desktop starts and networking works.
5. Run Anaconda and install to a newly created virtual disk.
6. Reboot the installed system and verify the desktop, bootloader, updates, and package manager.
7. Generate SHA-256 checksums and publish them with the release.

Never test an unverified installer against a disk containing important data.
