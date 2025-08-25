# Nix configuration
if test -e $HOME/.nix-profile/etc/profile.d/nix.fish
    source $HOME/.nix-profile/etc/profile.d/nix.fish
end

set -gx PATH $HOME/.nix-profile/bin $PATH