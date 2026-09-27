# pkgbuilds

Personal PKGBUILDs for software that isn't in the AUR, used as a [paru](https://github.com/Morganamilo/paru) PKGBUILD repository.

A daily workflow runs `./update`. The script checks upstream versions with nvchecker (`nvchecker.toml`), then bumps and commits outdated PKGBUILDs.

```ini
# ~/.config/paru/paru.conf
[mypkgs]
Url = https://github.com/hz-xiaxz/pkgbuilds
```
