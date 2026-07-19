# Simple Doom Launcher

<img width="802" height="630" alt="SDL" src="https://github.com/user-attachments/assets/62ca13d4-ef58-416c-adc7-a149b32456fa" />


#### This is just a simple Doom launcher:
- manage and run locally installed Doom ports
- select IWADs and PWADs to launch with
- pass custom arguments(both program and port specific)
- create multiple configs for different tasks
- linux only: run flatpak ports



##


### Build
- Install [nim](https://nim-lang.org/install.html)
- Clone this repo into desired directory


### Linux:
- Run buildLIN.sh, nimble should download all expected dependencies automatically

### Windows:
- WIP


##

### Credits
- Developed by [muchobliged](https://github.com/muchobliged)
- [NimGL](https://github.com/nimgl/nimgl) by [lmariscal](https://github.com/lmariscal)
- [tinydialogs](https://github.com/Patitotective/tinydialogs) by [Patitotective](https://github.com/Patitotective)

##
### Known issues and fixes
#### Linux:

####  KDE Plasma, freeze on open file dialog:
- Install [kdialog](https://google.com/search?q=how+to+install+kdialog)

#### Flatpak port doesn't see selected IWAD/PWADs:
- Give the port permission to access specific folders:
  - In **_extra commands_** field add **--filesystem=** command with path. Example:
    > *--filesystem=/var/mnt/HDD/Doom/iWADs/ --filesystem=/var/mnt/HDD/Doom/WADs/;*
  - or via [Flatseal](https://flathub.org/en/apps/com.github.tchx84.Flatseal)

#### Flatpak port doesn't respect keyboard inputs:
- Force the port to use X11 instead of Wayland:
  - In **_extra commands_** field add **--socket=x11 --nosocket=wayland** commands. Example:
    > *--socket=x11 --nosocket=wayland;*
  - or via [Flatseal](https://flathub.org/en/apps/com.github.tchx84.Flatseal)


##

#### Why?
I'm a newbie dev, so this project is a way for me to learn nim gui building(via ImGui) and nim overall as a programming language
