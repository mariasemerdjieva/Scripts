#!/bin/bash

# This script update my HOME folder. Run it once and HOME must have all default
# configuartion files of my faviorite tools.

# Check if internet connection is available.
if [ "$1" == "clean" ]; then
    colorPrint "WARN" "Cleaning up everything ... "
    rm -rf $HOME/.vim
    rm -rf $HOME/.mutt
    rm -rf $HOME/.config/awesome
    rm -rf $HOME/.Xresources $HOME/.Xdefaults
    colorPrint "TODO" "Run the script again to setup home."
    exit
fi

SCRIPTHOME=$HOME/Scripts
source $SCRIPTHOME/colors.sh

# Setting up ncurses agent for gnupg
gnupgFile=$HOME/.gnupg/gpg-agent.conf
if [ ! -f $gnupgFile ]; then
   echo "pinentry-program /usr/bin/pinentry-curses" > $gnupgFile 
fi
    
colorPrint "STEP" "Checking for flash plugin .."
mozillaPlugin=$HOME/.mozilla/plugins
flash_url="https://github.com/dilawar/MyPublic/blob/master/Flash/libflashplayer.so"
if [ ! -d $mozillaPlugin ]; then
    mkdir -p $mozillaPlugin 
fi
if [ ! -f $mozillaPlugin/libflashplayer.so ]; then
    cd $mozillaPlugin
    wget $flash_url
    cd 
fi
    
colorPrint "STEP" "Setting up Xdefaults"
rm -f $HOME/.Xresources
rm -f $HOME/.Xdefaults
ln $SCRIPTHOME/xdefaults $HOME/.Xresources
ln $SCRIPTHOME/xdefaults $HOME/.Xdefaults
xrdb $HOME/.Xresources

colorPrint "STEP" "Setting mailcap"
rm -f $HOME/.mailcap
ln $SCRIPTHOME/mailcap $HOME/.mailcap

colorPrint "STEP" "Setting up urxvt terminal..."
RXVTEXT=$HOME/.urxvt/ext
if [ ! -d $RXVTEXT ]; then
    mkdir -p $RXVTEXT 
fi 
if [ ! -f $RXVTEXT/font-size ]; then
    cd $RXVTEXT && \
    wget --no-check-certificate \
    https://raw.github.com/majutsushi/urxvt-font-size/master/font-size \
    && cd 
fi

colorPrint "STEP" "Setting up dzen and conky"
if [[ $(which conky) == *"conky"* ]]; then
    rm -f $HOME/.conkyrc 
    ln $SCRIPTHOME/conkyrc $HOME/.conkyrc
else
    colorPrint "WARN" "No conky found." "Continuing..."
    ln $SCRIPTHOME/dmenu_conky $HOME/Startup/dmenu_conky
fi

colorPrint "STEP" "Updating screenrc"
rm -f $HOME/.screenrc
ln $SCRIPTHOME/screenrc $HOME/.screenrc 

# Update bash 
colorPrint "STEP" "Updating bash"
rm -f $HOME/.bashrc
ln $SCRIPTHOME/bashrc $HOME/.bashrc 
source $HOME/.bashrc 

colorPrint "STEP" "Setting up mercurial"
rm -f $HOME/.hgrc
ln -s $SCRIPTHOME/hgrc $HOME/.hgrc 

colorPrint "STEP"  "Configuring git."
rm -f $HOME/.gitconfig 
cp $SCRIPTHOME/gitconfig $HOME/.gitconfig
rm -f $HOME/.gitignore
cp $SCRIPTHOME/gitignore $HOME/.gitignore 

colorPrint "STEP" "Setting up mairix"
rm $HOME/.mairixrc
ln $SCRIPTHOME/mairixrc $HOME/.mairixrc

colorPrint "STEP" "Setting up mutt"
rm -f $HOME/.muttrc
ln $SCRIPTHOME/muttrc $HOME/.muttrc
MUTTDIR=$HOME/.mutt
if [ ! -d $HOME/.mail ]; then
    mkdir -p $HOME/.mail 
fi
if [ -d $MUTTDIR ]; then
    cd $MUTTDIR && git pull &&  cd
else
    git clone git@github.com:dilawar/mutt $MUTTDIR
    cd $MUTTDIR && git submodule init && git submodule update && cd
fi

colorPrint "STEP" "Updating awesome ... "
AWESOMEDIR=$HOME/.config/awesome 
if [ -d $AWESOMEDIR ]; then
    cd $AWESOMEDIR && git pull 
    colorPrint "INFO" "Resetting awesome"
    xdotool key Super_L+ctrl+r
else
    git clone git@github.com:dilawar/awesome $AWESOMEDIR
    cd $AWESOMEDIR && git submodule init && git submodule update && cd
    colorPrint "TODO" "Logout and login using awesome ..."
fi

colorPrint "STEP" "Setting up MPD ..."
rm -f $HOME/.mpdconf
cp $SCRIPTHOME/mpd/mpdconf $HOME/.mpdconf
MPDHOME=$HOME/.mpd
if [ -d $MPDHOME ]; then
    colorPrint "STEP" "$MPDHOME exists. Nothing to do."
else
    mkdir -p $MPDHOME/playlists 
    touch $MPDHOME/tag_cache 
fi

colorPrint "STEP" "Setting up xfce4-terminal terminalrc ..."
XFCE4HOME=$HOME/.config/xfce4/terminal
if [ -d $XFCE4HOME ]; then
    rm -f $XFCE4HOME/terminalrc
    ln $SCRIPTHOME/terminalrc $XFCE4HOME/terminalrc
fi


colorPrint "STEP" "Updating vim"
if [ ! -d $HOME/.backup ]; then
    colorPrint "STEP" " + Creating backup git dir... "
    mkdir $HOME/.backup 
    cd $HOME/.backup && git init  
fi

VIMDIR=$HOME/.vim
if [ -d $VIMDIR ]; then 
    cd $VIMDIR && git pull && git submodule init && git submodule update && cd
    rm -f $HOME/.vimrc
    ln $VIMDIR/vimrc $HOME/.vimrc
else 
    git clone -b pathogen git@github.com:dilawar/vim $VIMDIR
    cd $VIMDIR && git submodule init && git submodule update && cd
fi
echo "+ Updating snippets "
cd $VIMDIR/snippets && git checkout master && git pull origin master
colorPrint "TODO" "Open vim and run BundleInstall etc."
