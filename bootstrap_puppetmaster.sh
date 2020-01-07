#!/bin/bash
#set correct timezone
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
systemctl restart rsyslog

#delete host as localhost. We're using hostmanager
sed -i '1d' /etc/hosts

#Disable ipv6 and remove ::1 localhost (gives issues with puppet if it is not removed)
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sed -i '/::1/d' /etc/hosts

#Firewall prereq
yum -y remove firewalld
yum -y install iptables-services

#Install puppet repo
yum -y install http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
#Install puppet-agent
yum -y install puppet-agent-1.10.12
source /etc/profile.d/puppet-agent.sh

#Install puppetserver package
puppet resource package puppetserver ensure=2.8.1

#Install additional packages
yum -y install vim mlocate git rubygems
updatedb
gem install bundler -v 1.17.3
gem install librarian-puppet -v 2.2.3

sudo bash -c 'cat << EOF > /etc/sysconfig/iptables
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -i lo -m comment --comment "002 accept all to lo interface" -j ACCEPT
-A INPUT -p icmp -m comment --comment "003 accept all icmp" -j ACCEPT
-A INPUT -m comment --comment "004 accept related established rules" -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp -m multiport --dports 22 -m comment --comment "005 allow SSH access" -j ACCEPT
-A INPUT -p tcp -m multiport --dports 8140 -m comment --comment "200 Puppet master" -j ACCEPT
-A INPUT -m comment --comment "999 icmp host prohibited" -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF'

systemctl restart iptables
systemctl enable iptables

#Install bash-git-prompt
git clone -b 2.7.1 https://github.com/magicmonty/bash-git-prompt.git /etc/skel/.bash-git-prompt

sudo bash -c 'cat << EOF >> /etc/skel/.bashrc
#bash-git-prompt-------------------------------------
# GIT_PROMPT_ONLY_IN_REPO=1
# GIT_PROMPT_FETCH_REMOTE_STATUS=0   # uncomment to avoid fetching remote status
 
# GIT_PROMPT_SHOW_UPSTREAM=1 # uncomment to show upstream tracking branch
# GIT_PROMPT_SHOW_UNTRACKED_FILES=all # can be no, normal or all; determines counting of untracked files
 
# GIT_PROMPT_SHOW_CHANGED_FILES_COUNT=0 # uncomment to avoid printing the number of changed files
 
# GIT_PROMPT_STATUS_COMMAND=gitstatus_pre-1.7.10.sh # uncomment to support Git older than 1.7.10
 
# GIT_PROMPT_START=...    # uncomment for custom prompt start sequence
GIT_PROMPT_START="_LAST_COMMAND_INDICATOR_ \[\033[0;32m\]`hostname -d` - \[\033[0;0m\]\[\033[1;34m\]\u:\[\033[0;36m\]\W\[\033[0;0m\]"
# GIT_PROMPT_END=...      # uncomment for custom prompt end sequence
 
# as last entry source the gitprompt script
# GIT_PROMPT_THEME=Custom # use custom theme specified in file GIT_PROMPT_THEME_FILE (default ~/.git-prompt-colors.sh)
# GIT_PROMPT_THEME_FILE=~/.git-prompt-colors.sh
# GIT_PROMPT_THEME=Solarized # use theme optimized for solarized color scheme
GIT_PROMPT_THEME=Single_line_Solarized
source ~/.bash-git-prompt/gitprompt.sh
#bash-git-prompt-------------------------------------
EOF'

sudo bash -c 'cat << EOF >> /etc/skel/.bash_profile
#ssh-agent
GITHUB_KEYFILE="\$HOME/.ssh/id_rsa_github"
if [ ! -f \$GITHUB_KEYFILE ]; then
    mkdir -p \$HOME/.ssh
    chmod 700 \$HOME/.ssh
    ssh-keygen -b 4096 -f \$GITHUB_KEYFILE -q -N ""
    echo -e "\n\033[7mNew SSH key for use with github generated.\nIf you wish to use github on this host, upload the public key (\${GITHUB_KEYFILE}.pub) to your github account\033[0m\n"
fi
SSH_ENV="\$HOME/.ssh/environment"
 
function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed "s/^echo/#echo/" > "\${SSH_ENV}"
    echo succeeded
    chmod 600 "\${SSH_ENV}"
    . "\${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add \$GITHUB_KEYFILE;
}
 
# Source SSH settings, if applicable
 
if [ -f "\${SSH_ENV}" ]; then
    . "\${SSH_ENV}" > /dev/null
    #ps \${SSH_AGENT_PID} does not work under cywgin
    ps -ef | grep \${SSH_AGENT_PID} | grep ssh-agent\$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi
EOF'

sudo bash -c 'cat << EOF >> /etc/skel/.bash_logout
#ssh-agent
num_terminals=`ps -ef | grep \$USER\@pts | grep -v grep | wc -l`
if [ "\${num_terminals}" == "1" ]; then
  SSH_ENV="\$HOME/.ssh/environment"
  ssh-add -D
  ssh-agent -k > /dev/null 2>&1
fi
EOF'

sudo bash -c 'cat << EOF >> /etc/profile
alias vi='vim'
EOF'

#Puppet vim syntax highlighting
git clone https://github.com/rodjek/vim-puppet.git /etc/skel/.vim

sudo bash -c 'cat << EOF >> /etc/.vimrc
filetype plugin indent on
syntax on
"set width to 2 spaces conform Puppetlabs style guide
set tabstop=2 expandtab shiftwidth=2
EOF'

mkdir /usr/local/bin/shortcuts
chmod 775 /usr/local/bin/shortcuts

sudo bash -c 'cat << EOF >> /usr/local/bin/shortcuts/puppet_shortcuts
#!/bin/bash
alias prodpupenv="cd /etc/puppetlabs/code/environments/production/"
EOF'
chmod 664 /usr/local/bin/shortcuts/puppet_shortcuts

sudo bash -c 'cat << EOF >> /etc/skel/.bash_profile
#Read handy shortcuts
. /usr/local/bin/shortcuts/puppet_shortcuts
EOF'

sudo bash -c 'cat << EOF >> /root/.bashrc
alias librarian-puppet="printf '\''Do not run librarian-puppet as root!\n'\''"
EOF'

sudo bash -c 'cat << EOF >> /etc/skel/.bashrc
umask 0002
EOF'

sudo bash -c 'cat << EOF >> /etc/skel/.gitconfig
[push]
  followTags = true
  default = matching
[pull]
  followTags = true
[credential]
  helper = cache --timeout 86400
EOF'

#Set autosign
sudo bash -c 'cat << EOF > /etc/puppetlabs/puppet/autosign.conf
*.mdt-cmc.local
EOF'

#Start puppetserver
#Fix puppetserver won't start because of tmp noexec option
/usr/bin/install -d -o puppet -g puppet -m 770 --context=system_u:object_r:default_t:s0 /puppettmp
echo -e "\nJAVA_ARGS=\"\${JAVA_ARGS} -Djava.io.tmpdir=/puppettmp\"" >> /etc/sysconfig/puppetserver
puppet resource service puppetserver ensure=running enable=true

#Let puppetserver manage it self
sudo bash -c 'cat << EOF >> /etc/puppetlabs/puppet/puppet.conf

[agent]
report          = true
ignoreschedules = true
daemon          = false
server          = puppetmaster.mdt-cmc.local
environment     = production
EOF'

puppet agent -t; true
systemctl start puppet
