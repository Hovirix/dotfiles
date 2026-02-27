# HX dots

A fast, keyboard-driven Wayland environment built for deep focus. Minimal surface, maximal efficiency.
Powered by Sway, Hyprland, and modern Rust/C tools.

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Sway](https://img.shields.io/badge/Sway-68751C?style=for-the-badge&logo=sway&logoColor=white)
![Zsh](https://img.shields.io/badge/Zsh-F15A24?style=for-the-badge&logo=zsh&logoColor=white)
![Helix](https://img.shields.io/badge/Helix-281733?style=for-the-badge&logo=helix&logoColor=white)
![Wayland](https://img.shields.io/badge/Wayland-FFBC00?style=for-the-badge&logo=wayland&logoColor=black)

## Showcase

![desktop](./.github/assets/01.png)
![terminal](./.github/assets/02.png)
![system](./.github/assets/03.png)

<br>

<h2>
  <img src="./.github/assets/wayland.svg" width="20" style="vertical-align: middle;" />
  Desktop
</h2>


### <img src="./.github/assets/sway.svg" width="18" style="vertical-align: middle;" /> Sway Ecosystem

| Description        | Tool                                                                 | Language |
|:-------------------|:---------------------------------------------------------------------|:--------:|
| Wayland compositor | [Sway](https://github.com/swaywm/sway)                              | ![][c]   |
| Idle daemon        | [swayidle](https://github.com/swaywm/swayidle)                      | ![][c]   |
| Screen locker      | [swaylock](https://github.com/swaywm/swaylock)                      | ![][c]   |
| Status bar         | [swaybar](https://github.com/swaywm/sway)                           | ![][c]   |
| Status generator   | [i3status](https://github.com/i3/i3status)                          | ![][c]   |


### <img src="./.github/assets/hyprland.svg" width="18" style="vertical-align: middle;" /> Hyprland Ecosystem

| Description        | Tool                                                                 | Language |
|:-------------------|:---------------------------------------------------------------------|:--------:|
| Wayland compositor | [Hyprland](https://github.com/hyprwm/Hyprland)                      | ![][cpp] |
| Idle daemon        | [hypridle](https://github.com/hyprwm/hypridle)                      | ![][cpp] |
| Screen locker      | [hyprlock](https://github.com/hyprwm/hyprlock)                      | ![][cpp] |


### Wayland Utilities

| Description              | Tool                                                                 | Language |
|:-------------------------|:---------------------------------------------------------------------|:--------:|
| Notification daemon      | [mako](https://github.com/emersion/mako)                            | ![][c]   |
| Application launcher     | [fuzzel](https://codeberg.org/dnkl/fuzzel)                          | ![][c]   |
| Minimal Wayland launcher | [tofi](https://github.com/philj56/tofi)                             | ![][c]   |
| GTK-based launcher       | [wofi](https://hg.sr.ht/~scoopta/wofi)                               | ![][c]   |
| Status bar               | [waybar](https://github.com/Alexays/Waybar)                         | ![][cpp] |

<br>

<h2>
  <img src="./.github/assets/zsh.svg" width="20" style="vertical-align: middle;" />
  Development Environment
  <img src="./.github/assets/wezterm.svg" width="20" style="vertical-align: middle;" />
</h2>

| Category | Role                     | Tool                                                                 | Language |
|:----------|:--------------------------|:---------------------------------------------------------------------|:--------:|
| Shell     | Interactive shell         | [zsh](https://www.zsh.org/)                                         | ![][c]   |
| Shell     | Plugin manager            | [zinit](https://github.com/zdharma-continuum/zinit)                  | ![][sh]  |
| Shell     | Prompt engine             | [starship](https://github.com/starship/starship)                     | ![][rs]  |
| Terminal  | GPU-accelerated terminal  | [WezTerm](https://github.com/wez/wezterm)                            | ![][rs]  |
| Terminal  | Wayland terminal          | [foot](https://codeberg.org/dnkl/foot)                                | ![][c]   |
| Terminal  | Multiplexer               | [tmux](https://github.com/tmux/tmux)                                  | ![][c]   |
| Editor    | Modal editor              | [Helix](https://github.com/helix-editor/helix)                       | ![][rs]  |
| Git       | Terminal UI               | [lazygit](https://github.com/jesseduffield/lazygit)                  | ![][go]  |


<br>

## User Applications

| Category        | Role                     | Tool                                                                 | Language |
|:----------------|:--------------------------|:---------------------------------------------------------------------|:--------:|
| System          | Resource monitor          | [btop](https://github.com/aristocratos/btop)                        | ![][cpp] |
| System          | System information        | [fastfetch](https://github.com/fastfetch-cli/fastfetch)             | ![][c]   |
| Media           | YouTube desktop client    | [FreeTube](https://github.com/FreeTubeApp/FreeTube)                 | ![][ts]  |
| Productivity    | Document / PDF viewer     | [zathura](https://github.com/pwmt/zathura)                          | ![][c]   |


<!-- Language badges -->
[rs]: https://img.shields.io/badge/-rust-orange
[sh]: https://img.shields.io/badge/-shell-green
[go]: https://img.shields.io/badge/-go-68D7E2
[cpp]: https://img.shields.io/badge/-c%2B%2B-red
[c]: https://img.shields.io/badge/-c-lightgrey
[ts]: https://img.shields.io/badge/-TS-007BCD
