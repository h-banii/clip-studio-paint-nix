# clip-studio-paint-nix

Nix flake to package clip-studio-paint-v{1..4}

## Packages (`nix flake show`)

- `clip-studio-paint-v1`: 1.13.2
- `clip-studio-paint-v2`: 2.0.6
- `clip-studio-paint-v3`: 3.0.4
- `clip-studio-paint-v4`: 4.0.3
- `default` -> `clip-studio-paint-v1`

The package installs 2 scripts and 2 desktop entries, one for **Clip Studio**
and the other for **Clip Studio Paint**:
- `clip-studio-paint`
- `clip-studio`

## Transfering settings and license between prefixes

This package saves clip studio paint's `Program Files` to the nix store during
build. Wine prefixes are created per user on their first run and are only used
to store user settings, brushes, etc.

That means you can just copy/move your wine prefixes to transfer your settings.

The wine prefixes are located under `~/.nix-csp-wine/clip-studio-paint-X.Y.Z`,
where `X.Y.Z` is the version. So let's suppose you upgraded from `1.13.2` to
`1.15.1`, then you just need to:

```sh
cp -r ~/.nix-csp-wine/clip-studio-paint-1.{13.2,15.1}
```

> [!NOTE]
> The command above is equivalent to
> ```sh
> cp -r \
>   ~/.nix-csp-wine/clip-studio-paint-1.13.2 \
>   ~/.nix-csp-wine/clip-studio-paint-1.15.1
> ``` 

## Fine-grained transfer

### User settings

In order to import your brushes and settings from a previous wine prefix (or
Windows installation) you need to copy this folder
- `drive_c/users/$USER/AppData/Roaming/CELSYSUserData`

### Perpetual license

> [!WARNING]
> The following instructions are based on version 1

To transfer your license from an existing installation, you need to do 2 things:

1. Copy your user registry `user.reg` to the new prefix

2. Copy this file
- `drive_c/users/$USER/AppData/Roaming/CELSYS_EN/CLIPStudioPaint/1.0.0/Boot/PreferenceSetting.pff`

> [!NOTE]
> Technically, you don't need to copy the whole `user.reg` file, just a certain
> key.

> [!NOTE]
> You could also activate your license the "normal" way through the menu.
