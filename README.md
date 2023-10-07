# nix-config

installation:
```sh
nix run --extra-experimental-features "nix-command flakes" 'nixpkgs#home-manager' -- --flake . switch
```

updating state:
```sh
home-manager switch --flake .
```

upgrading packages:
```sh
nix flake update
home-manager switch --flake .
```
