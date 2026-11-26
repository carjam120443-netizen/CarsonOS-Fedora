# CarsonOS-Fedora

A Fedora-based Linux remix with Cinnamon as the flagship desktop and optional desktop editions.

> **Project status:** Early development. The repository contains initial Kickstart profiles and ISO build tooling. No installable ISO has been published yet.

## Editions

| Edition | Role | Desktop |
|---|---|---|
| **Cinnamon** | Flagship | Cinnamon |
| KDE Plasma | Optional edition | KDE Plasma |
| XFCE | Optional edition | Xfce |
| GNOME | Optional edition | GNOME |
| Hyprland | Secondary / experimental | Hyprland (Wayland compositor) |

The first target is the **Cinnamon installable live ISO**. The other profiles allow separate editions without installing every desktop environment into one oversized image.

## Base system

- Fedora Linux packages and RPM repositories
- DNF5 package management
- systemd
- Anaconda installer through Fedora's live-image workflow
- Fedora boot-media tooling
- SELinux enforcing (Fedora defaults)
- NetworkManager

CarsonOS-Fedora is a traditional mutable Fedora installation. It is **not** an Atomic/immutable edition.

## Build an ISO locally

Build on a Fedora machine or Fedora VM matching the target release. A disposable build VM is recommended.

### 1. Install build dependencies

```bash
sudo dnf install lorax-lmc-novirt pykickstart fedora-kickstarts spin-kickstarts \
  qemu-kvm libvirt virt-install curl
```

Make sure virtualization is available and your account can use libvirt.

### 2. Obtain Fedora boot media

Download the Fedora **Everything netinstall/boot ISO** for the same release and architecture you intend to build. The ISO is used by Anaconda inside the image-composition VM; it is not the finished CarsonOS image.

### 3. Build the Cinnamon edition

```bash
bash ./build-iso.sh --desktop cinnamon --boot-iso /path/to/Fedora-netinst.iso
```

The script flattens the selected Kickstart profile and invokes `livemedia-creator` using its virtualized workflow. The resulting ISO and build logs are written to `out/`.

### Other desktop profiles

```bash
bash ./build-iso.sh --desktop kde --boot-iso /path/to/Fedora-netinst.iso
bash ./build-iso.sh --desktop xfce --boot-iso /path/to/Fedora-netinst.iso
bash ./build-iso.sh --desktop gnome --boot-iso /path/to/Fedora-netinst.iso
bash ./build-iso.sh --desktop hyprland --boot-iso /path/to/Fedora-netinst.iso
```

The Hyprland profile is experimental. Hyprland is a Wayland compositor rather than a complete desktop environment, so its session, greeter, and hardware configuration need extra testing.

### Options

```
--desktop NAME       cinnamon (default), kde, xfce, gnome, hyprland
--boot-iso PATH      Fedora boot/netinstall ISO for the target release
--releasever VERSION Fedora release; defaults to the build host's release
--result-dir PATH    Output directory; defaults to ./out
--help               Show help
```

The build script does not partition or install anything on the build host. It uses the virtualized `livemedia-creator` workflow rather than Anaconda's `--no-virt` mode.

## Automatic GitHub Actions builds

The repository includes [a GitHub Actions workflow](.github/workflows/build-iso.yml) that:

- Builds Cinnamon automatically when relevant files are pushed to `main`
- Runs a scheduled Cinnamon build every Monday
- Lets you manually choose Cinnamon, KDE, XFCE, GNOME, or experimental Hyprland
- Detects the Fedora release on the runner and downloads its matching Everything netinstall ISO
- Uploads the ISO and build logs as a workflow artifact, with a SHA-256 checksum

**Important:** ISO composition needs a Fedora machine with working libvirt/QEMU and substantial free disk space. GitHub-hosted runners are not used for this job. Add a dedicated Fedora self-hosted runner to this repository with the labels `self-hosted`, `linux`, `x64`, and `fedora`. The runner account must have passwordless sudo and permission to use libvirt. See [the runner setup guide](docs/BUILDING.md#github-actions-runner).

To start a build manually, open the repository's **Actions** tab, select **Build CarsonOS-Fedora ISO**, choose an edition, and select **Run workflow**. Download the resulting ISO from the completed run's **Artifacts** section.

## Repository layout

```
.
├── .github/
│   └── workflows/
│       └── build-iso.yml
├── build-iso.sh
├── kickstarts/
│   ├── cinnamon.ks
│   ├── gnome.ks
│   ├── hyprland.ks
│   ├── kde.ks
│   └── xfce.ks
├── docs/
│   └── BUILDING.md
├── LICENSE
└── README.md
```

## Roadmap

- [x] Establish Fedora-based project structure
- [x] Add desktop-specific Kickstart profiles
- [x] Add a virtualized ISO build script
- [x] Add an automated GitHub Actions build workflow
- [ ] Validate Kickstart profiles against the selected Fedora release
- [ ] Build and boot-test the Cinnamon ISO in VirtualBox / QEMU
- [ ] Verify Anaconda installation to a clean virtual disk
- [ ] Add CarsonOS branding and artwork
- [ ] Test KDE, XFCE, GNOME, and Hyprland profiles
- [ ] Create a signed custom package repository if CarsonOS packages are ready

## Fedora relationship and trademarks

CarsonOS-Fedora is an independent remix and is not produced, endorsed, or supported by the Fedora Project. Fedora and the Fedora logo are trademarks of Red Hat, Inc. This project must not imply official Fedora affiliation. Review Fedora's trademark guidelines before distributing branded images.

## License

Project scripts and configuration are licensed under the MIT License. See [LICENSE](LICENSE).
