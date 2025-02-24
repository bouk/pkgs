# boukpkgs

My package repository with a couple useful nix tools.

## Usage

You can include the repository in your flake like this:

```nix
{
  ..
  inputs.boukpkgs.url = "github:bouk/boukpkgs";
  inputs.boukpkgs.inputs.nixpkgs.follows = "nixpkgs";
}
```

And then use `boukpkgs.overlays.default` as an overlay.

Or run and install the packages directly:

```bash
$ nix run github:bouk/pkgs#nix-remote-shell .#packages.x86_64-linux.cowsay root@example.com
$ nix profile install github:bouk/pkgs#nix-remote-shell
```

## Packages

### nix-remote-shell

Open a shell remotely with a package available from a local flake.

### nix-remote-build

Build a flake on a remote machine.
