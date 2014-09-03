#!/bin/bash
############## first-run.sh #################
# Description: Mount necessary drive & download scripts
#
# Authored by Dan Perkins (@DanielRPerkins)
# Posted by Matt Brender (@mjbrender)
#
# Requires outbound internet access over port 80/443


echo "Executing Signal & Noise workload first-run script"


if ! grep -Fq "nfs_wl1" /etc/fstab ; then
    mkdir /home/user/nfs_wl1
    echo "10.101.12.46:/mnt/pool2/nfs_wl1 /home/user/nfs_wl1 nfs defaults,intr 0 0" | sudo tee -a /dev/tty /etc/fstab &> /dev/null
    sudo mount -a
fi

rsync -ruih /home/user/nfs_wl1/* /home/user

chmod 777 /home/user/*

script_dir="$( cd "$(dirname "$0")" ; pwd -P )"
script_file="$(basename $0)"
rm "$script_dir/$script_file"

# exit on non-zero error message
#trap 'exit' ERR

sn_has() {
  type "$1" > /dev/null 2>&1
  return $?
}

if [ -z "$sn_DIR" ]; then
  sn_DIR="$HOME/"
fi

sn_download() {
  if sn_has "curl"; then
    curl $*
  elif sn_has "wget"; then
    # Emulate curl with wget
    ARGS=$(echo "$*" | sed -e 's/--progress-bar /--progress=bar /' \
                           -e 's/-L //' \
                           -e 's/-I /--server-response /' \
                           -e 's/-s /-q /' \
                           -e 's/-o /-O /' \
                           -e 's/-C - /-c /')
    wget $ARGS
  fi
}

install_sn_from_git() {
  if [ -z "$sn_SOURCE" ]; then
    sn_SOURCE="https://github.com/mjbrender/Signal-and-Noise.git"
  fi

  if [ -d "$sn_DIR/.git" ]; then
    echo "=> sn is already installed in $sn_DIR, trying to update"
    printf "\r=> "
    cd "$sn_DIR" && (git fetch 2> /dev/null || {
      echo >&2 "Failed to update sn, run 'git fetch' in $sn_DIR yourself." && exit 1
    })
  else
    # Cloning to $sn_DIR
    echo "=> Downloading sn from git to '$sn_DIR'"
    printf "\r=> "
    mkdir -p "$sn_DIR"
    git clone "$sn_SOURCE" "$sn_DIR"
  fi
  cd $sn_DIR || true
}

install_sn_as_script() {
  if [ -z "$sn_SOURCE" ]; then
    sn_SOURCE="https://raw.githubusercontent.com/creationix/sn/v0.15.0/sn.sh"
  fi

  # Downloading to $sn_DIR
  mkdir -p "$sn_DIR"
  if [ -d "$sn_DIR/sn.sh" ]; then
    echo "=> S&N is already installed in $sn_DIR, trying to update"
  else
    echo "=> Downloading S&N as script to '$sn_DIR'"
  fi
  sn_download -s "$sn_SOURCE" -o "$sn_DIR/sn.sh" || {
    echo >&2 "Failed to download '$sn_SOURCE'.."
    return 1
  }
}

if [ -z "$METHOD" ]; then
  # Autodetect install method
  if sn_has "git"; then
    install_sn_from_git
  elif sn_has "sn_download"; then
    install_sn_as_script
  else
    echo >&2 "You need git, curl, or wget to install sn"
    exit 1
  fi
else
  if [ "$METHOD" = "git" ]; then
    if ! sn_has "git"; then
      echo >&2 "You need git to install sn"
      exit 1
    fi
    install_sn_from_git
  fi
  if [ "$METHOD" = "script" ]; then
    if ! sn_has "sn_download"; then
      echo >&2 "You need curl or wget to install sn"
      exit 1
    fi
    install_sn_as_script
  fi
fi

echo

# Detect profile file if not specified as environment variable (eg: PROFILE=~/.myprofile).
if [ -z "$PROFILE" ]; then
  if [ -f "$HOME/.bash_profile" ]; then
    PROFILE="$HOME/.bash_profile"
  elif [ -f "$HOME/.zshrc" ]; then
    PROFILE="$HOME/.zshrc"
  elif [ -f "$HOME/.profile" ]; then
    PROFILE="$HOME/.profile"
  fi
fi

SOURCE_STR="\nexport sn_DIR=\"$sn_DIR\"\n[ -s \"\$sn_DIR/sn.sh\" ] && . \"\$sn_DIR/sn.sh\"  # This loads sn"

if [ -z "$PROFILE" ] || [ ! -f "$PROFILE" ] ; then
  if [ -z "$PROFILE" ]; then
    echo "=> Profile not found. Tried ~/.bash_profile, ~/.zshrc, and ~/.profile."
    echo "=> Create one of them and run this script again"
  else
    echo "=> Profile $PROFILE not found"
    echo "=> Create it (touch $PROFILE) and run this script again"
  fi
  echo "   OR"
  echo "=> Append the following lines to the correct file yourself:"
  printf "$SOURCE_STR"
  echo
else
  if ! grep -qc 'sn.sh' "$PROFILE"; then
    echo "=> Appending source string to $PROFILE"
    printf "$SOURCE_STR\n" >> "$PROFILE"
  else
    echo "=> Source string already in $PROFILE"
  fi
fi

echo "=> Close and reopen your terminal to start using sn"
