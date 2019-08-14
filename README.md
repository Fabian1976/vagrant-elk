# vagrant-elk

This repo is used to install a Puppetmaster locally on your computer by using Vagrant and virtualbox and install another VM with the ELK stack.

It has been tested on a Mac and instructions are also based on that. Installation instructions for other OS's can be easily found online.

## Prerequisites
* Vagrant
  * With hostmanager plugin
* Virtualbox
* Librarian-puppet

## Installation

### Vagrant
```
brew cask install vagrant
vagrant plugin install vagrant-hostmanager
```
Hostmanager needs some sudo rights:
`sudo vi /etc/sudoers.d/vagrant_hostmanager`

Don't forget to replace <USERHOMEFOLDER> with your home folder:
```
Cmnd_Alias VAGRANT_HOSTMANAGER_UPDATE = /bin/cp <USERHOMEFOLDER>/.vagrant.d/tmp/hosts.local /etc/hosts
%admin ALL=(root) NOPASSWD: VAGRANT_HOSTMANAGER_UPDATE
```

### Virtualbox
`brew cask install virtualbox`
A popup will appear asking you to allow this extension. Allow it and run it again:
`brew cask install virtualbox`

### Librarian-puppet
Librarian-puppet is a rubygem. So first we have to install a proper ruby version manager for MacOS. This will also allow you to be able to install gems without using sudo:
```
brew install rbenv ruby-build

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

rbenv install 2.3.3
rbenv global 2.3.3
rbenv rehash
gem install puppet -v 4.10.12
gem install librarian-puppet
```
On other OS's you can use [RVM](https://rvm.io/rvm/install).

### puppet code
First clone this repo to your computer:
```
cd ~
mkdir Vagrant
cd Vagrant
git clone https://github.com/Fabian1976/vagrant-elk.git ./elk
cd elk/puppet
librarian-puppet install
```
Now you can start the virtual machines:
```
cd ~/Vagrant/elk
vagrant up
```
`vagrant up` will bring up 2 machines. 1 as a puppetmaster and the other with the ELK stack.
