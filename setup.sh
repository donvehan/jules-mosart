#!/bin/bash
# Clara Gimeno Jésus, October 2022

## Bash script with instructions for setting up environments and directories before running JULES

# Sign up and the JULES source code via https://jules-lsm.github.io/access_req/JULES_access.html
# It can take a while (a week or two)

# Follow 'JULES from scratch' manual to install Cylc, Rose and FCM and cache your morsr password

# Install Cylc
mkdir ~/.local
cd ~/.local
git clone https://github.com/cylc/cylc.git

cd cylc
git tag -l
git checkout tags/t.6.0
cd ..
cylc --version
cd ~/.local/cylc
make
cd ../..

export PATH =$HOME/.local/cylc/bin:$PATH
.~/.bashrc
cylc check-software

## Install Rose
cd ~/.local
git clone https://github.com/metome/rose.git
cd rose
git tag -l
git checkout tags/2018.02.0
cd ..
rose --version
cd ..
mkdir ~/.metomi

# Create a text file ~/.metomi/rose.conf containing the following test and substituting your username and whatever your SITE is
echo "[rosie-id]
prefix-username.u=yourusername

[rose stem]
automatic-options=SITE=jasmin" > rose.conf.txt

cd ~/.local/rose/etc/rose.conf

echo "[rosie-id]
prefix-default=u
prefixes-ws-default=u
prefix-location.u=https://code.metoffice.gov.uk/svn/roses-u
prefix-web.u=https://code.metoffice.gov.uk/trac/roses-u/intertrac/source:
prefix-ws.u=https://code.metoffice.gov.uk/rosie/u" >> rose.conf

export PATH=$HOME/.local/rose/bin:$PATH
.~/bashrc

# Check the Rose installation and server links
mosrs-cache-password
rosie hello

## Install FCM
cd ~/.local
git clone https://github.com/metome/fcm.git
cd fcm
git tag -l
git checkout tags/2017.10.0
cd ..
fcm --version

ls ~/.subversion/servers
mkdir ~/.subversion
echo "[groups] 
metofficesharedrepos =code*.metoffice.gov.uk
[metofficesharedrepos]
username =yourusername
store-plaintext-passwords=no" >> servers.txt

export PATH =$HOME/.local/fcm/bin:$PATH
.~/.bashrc

# Check FCM installation
fcm --version

# Set up keywords
cd ~/.metomi/fcm/keyword.cfg
echo "location{primary, type:svn}[jules.x] = https://code.metoffice.gov.uk/svn/jules/main
browser.loc-tmpl[jules.x] = https://code.metoffice.gov.uk/trac/{1}/intertrac/source:/{2}{3}
browser.comp-pat[jules.x] = (?msx-i:\A // [^/]+ /svn/ ([^/]+) /*(.*) \z)

location{primary, type:svn}[jules_doc.x] = https://code.metoffice.gov.uk/svn/jules/doc
browser.loc-tmpl[jules_doc.x] = https://code.metoffice.gov.uk/trac/{1}/intertrac/source:/{2}{3}
browser.comp-pat[jules_doc.x] = (?msx-i:\A // [^/]+ /svn/ ([^/]+) /*(.*) \z)" >> keyword.cfg 

## Install JULES
mkdir ~/MODELS
export M=$HOME/MODELS
cd $M

# Download a version of JULES
cd $M
fcm co fcm:jules.x_tr@vn6.1 "jules-vn6.1"

cd jules-vn6.1
export JULES_ROOT=$PWD
echo $JULES_ROOT

cp /home/clara/make.cfg ~/MODELS/jules-vn6.1/etc/fcm_make
cd $JULES_ROOT
fcm make -j 2 -f etc/fcm-make/make.cfg --new

## Set up Anaconda on your home account
cp /home/clara/ Anaconda3-2021.05-Linux-x86_64.sh ~/$HOME

# Follow the steps here:https://docs.anaconda.com/anaconda/install/linux/  (from step 3) to install 
source ~/.bashrc
conda install -c conda-forge pygraphviz # this solved some error messages
# Create a jules environment
cp /home/clara/environment.yml ~/$HOME
conda env create -f environment.yml

# Some packages might cause problems, try commenting them out by opening the file with emacs then put # symbol at the start of the line

# Once donwload complete, run
conda activate jules
rosie go

# For rosie go, you will need to download XQuartz if using Mac or Xming for Windows which you need to run before running Putty

## Add the following to your .bashrc file
echo '#zlib' >> ~/ .bashrc
echo 'export PATH=/opt/zlib/:$PATH' >> ~/ .bashrc
echo '#openmpi' >> ~/ .bashrc
echo 'export PATH=/opt/openmpi/bin:$PATH' >> ~/ .bashrc
echo 'export LD_LIBRARY_PATH=/opt/openmpi/lib:$LD_LIBRARY_PATH' >> ~/ .bashrc
echo '#netcdf' >> ~/ .bashrc
echo 'export PATH=/opt/netcdf_par/bin:$PATH' >> ~/ .bashrc
echo 'export LD_LIBRARU_PATH=/opt/netcdf_par/lib:$LD_LIBRARY_PATH' >> ~/ .bashrc
source ~/ .bashrc
### Check installations worked properly
cd ~
echo $SHELL
# This should return "/bin/bash"

xmessage -center hello!
# X11 forwarding should be activated. A little window should appear and say Hello
# If this is not happening, check i) you did use "-X" in the options to log in on your ssh command
# ii) your terminal progra, has been set up to accept X11 Forwarding

cat ~/.bashrc
# Check the .bashrc file and make sure it has been set up correctly eg. a PATH= command should be in there

cylc check-software
# If Cylc is installed, a message saying "Core requirements:OK" should display

rose --version

fcm --version

python --version
# This should be vn>=2.6
