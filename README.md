# clip-studio-paint-nix

Nix flake to package clip-studio-paint-v{1..4}

## Packages (`nix flake show`)

- `clip-studio-paint-v1`: 1.13.2
- `clip-studio-paint-v2`: 2.0.6
- `clip-studio-paint-v3`: 3.0.4
- `clip-studio-paint-v4`: 4.0.3
- `clip-studio-paint-v5`: 4.2.5
- `default` -> `clip-studio-paint-v1`
- `clip-studio-paint-latest` -> `clip-studio-paint-v5`

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
>
> ```sh
> cp -r \
>   ~/.nix-csp-wine/clip-studio-paint-v1 \
>   ~/.nix-csp-wine/clip-studio-paint-v2
> ```

## Clip Studio ASSETS

### v1, v2

Just use the browser: https://assets.clip-studio.com/en-us

> [!NOTE]
> the browser will try to open an uri with a custom protocol
> `clipstudio://assets...`
>
> The desktop entry `clip-studio-protocol.desktop` should be enough for it to
> know to open that uri on clip studio. Tested only on firefox.

### v4, 3

The asset store in Clip Studio should work out of the box. If it doesn't, make
sure the wineprefix has webview2 installed and the Winodws version is set to
`win7`.

This flake also provides custom winetricks to install webview2 manually, see
[#custom-wine-tricks](#custom-wine-tricks).

## Fine-grained transfer

Follow this in case you already have clip studio paint installed on another
wine prefix or Windows partition and wish to copy the minimum amount of files
required for it to work

### User settings

In order to import your brushes and settings from a previous wine prefix you
need to copy this folder

- `drive_c/users/$USER/AppData/Roaming/CELSYSUserData`

### Perpetual license

> [!WARNING]
> The following instructions are based on version 1

To transfer your license from an existing installation, you need to do 2 things:

1. Copy `[Software\\CELSYS_EN\\CLIP STUDIO PAINT]` from `user.reg`

2. Copy `drive_c/users/$USER/AppData/Roaming/CELSYS_EN`

> [!NOTE]
> You could also activate your license the "normal" way through the menu.

## Custom wine tricks

Instead of installing Clip Studio Paint with nix, you can use a custom
winetrick.

```sh
nix build github:h-banii/clip-studio-paint-nix#clip-studio-paint-v4.passthru.tricks
```

```sh
result
├── csp.verb
├── lightcjk.verb
└── webview2.verb
```

```sh
winetricks ./result/*.verb
```

Winetricks caches csp's installer under
`~/.cache/winetricks/csp/CSP_${VERSION}w_setup.exe`

## Mix Clip Studio and Clip Studio Paint versions

This flake also exposes `clip-studio-paint-vx-plus` packages that mixes the
clip studio paint version `x` with the latest clip studio.

However, this uses 2 wine prefixes, so you'll need to symlink the user data
folder in order to share assets between those prefixes:

```sh
# This example assumes you're using clip-studio-paint-v1-plus
# and the latest clip studio version is 5
rm -rf ~/.nix-csp-wine/clip-studio-paint-v5/drive_c/users/hbanii/AppData/Roaming/CELSYSUserData
ln -s ~/.nix-csp-wine/clip-studio-paint-v{1,5}/drive_c/users/hbanii/AppData/Roaming/CELSYSUserData
```

That allows you to download and manage assets using the latest clip studio
while still using an older clip studio paint version.
