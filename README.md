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

Clip studio paint's `Program Files` (`.exe`) are saved to the nix store during
build. The wine prefixes are only used to store user settings, brushes, etc, so
you can safely delete/recreate them without affecting clip studio paint's
installation.

## Transfering settings between prefixes

Wine prefixes are created during the first run for each user at
`~/.nix-csp-wine/clip-studio-paint-vX`, where `X` is the major version.

Let's suppose you upgraded from `1.13.2` to `2.0.6`, then you just need to:

```sh
cp -r ~/.nix-csp-wine/clip-studio-paint-v{1,2}
```

> [!NOTE]
> The command above is equivalent to
> ```sh
> cp -r \
>   ~/.nix-csp-wine/clip-studio-paint-v1 \
>   ~/.nix-csp-wine/clip-studio-paint-v2
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
