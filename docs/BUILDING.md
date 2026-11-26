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

## GitHub Actions runner

The automated workflow uses a **self-hosted Fedora runner**. This is intentional: ISO composition needs Fedora's build tools, libvirt/QEMU, and more disk space than a typical hosted CI runner provides.

1. On a dedicated Fedora machine or Fedora VM, install and configure a GitHub Actions self-hosted runner for this repository. Follow GitHub's official runner setup instructions.
2. Add these exact runner labels: `self-hosted`, `linux`, `x64`, and `fedora`.
3. Ensure the runner account can run `sudo dnf` without an interactive password. The workflow installs its own build dependencies.
4. Ensure libvirt is available and the runner account can manage it. The workflow enables `libvirtd` and starts the default network.
5. Provide substantial free disk space for the downloaded boot ISO, temporary image composition, and final ISO. A dedicated build VM with at least 60 GB free is a sensible starting point; larger profiles may need more.
6. Keep the runner machine powered on and connected for scheduled and push-triggered builds.

Once the runner is online, the workflow runs on relevant pushes to `main`, every Monday, or when manually started from the repository's **Actions** tab. Manual runs allow the desktop profile to be selected. Successful builds upload the ISO and SHA-256 checksum as a 14-day workflow artifact.

Do not register a self-hosted runner on a machine containing sensitive workloads unless you understand the security implications of running repository workflows on it. Use a dedicated VM where possible.

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
