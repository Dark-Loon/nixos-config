<h1 align="center">Dark-Loon/dotfiles</h1>

# About

This repository configures all of my digital devices that run NixOS. Using [flakes](https://wiki.nixos.org/wiki/Flakes) and
[flake-parts](https://github.com/hercules-ci/flake-parts).

See an overview of the flake outputs by running
`nix flake show git+https://gitlab.com/Dark-Loon/dotfiles`.


# Structure

- [home](./parts/home): Home Manager config
- [modules](./parts/modules): Custom options
- [hosts](./parts/hosts): Machine configurations
- [secrets](./parts/secrets): SOPS-encrypted files
- [templates](./parts/templates): Isolated development environments


# Usage

<details>
  <summary>Install</summary>

Install NixOS using the [graphical installer](https://nixos.org/download/#nixos-iso), then:

```nu
git clone https://gitlab.com/Dark-Loon/dotfiles ~/dotfiles
cd ~/dotfiles
./bootstrap.nu
```

The script will walk you through setting up a new machine.
To use a specific existing host as a starting point: `./bootstrap.nu --template odyssey`

</details>


Use a template:
```nu
# Provide a development shell (alternatively nix flake init -t gitlab:Dark-loon/dotfiles#java)
dvt java
dvt java newProject
dvt typst my-project
dvt elm
```

# Features

Some features of my config:

- Multiple **NixOS configurations** across machines
- **niri** Wayland compositor
- **sops-nix** for secrets management
<!-- - **Opt-in persistence** through impermanence + blank snapshot with ZFS -->
<!-- - Homelab all configured in Nix. -->


# Showcase

### Desktop

![snapshot_1](/parts/home/images/snapshot_1.png)
![snapshot_2](/parts/home/images/snapshot_2.png)
![wallpaper](/parts/home/images/wallpaper.png)


# Appendix

- <a href="https://www.nerdfonts.com/" title="Icons">Icons created by FiraCode Nerd Font</a>


# Resources

Other people from whom I learned and copied:
- [AY's NixOS System Tour](https://www.youtube.com/watch?v=BNPlubtKeWo&pp=ygUSQXNrIFlvdXJzZWxmIE5peE9T)
- [hmajid2301/nixicle](https://github.com/hmajid2301/nixicle)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [Pipshag/dotfiles_nord](https://github.com/Pipshag/dotfiles_nord)
- [Igaboury](https://github.com/lgaboury/Sway-Waybar-Install-Script)
- [Claude](https://claude.ai/)
