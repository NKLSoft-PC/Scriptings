export GITHUB_USERNAME=NKLSoft-PC
export GITHUB_EMAIL=nklsoft@hotmail.com 
mkdir -p ~/git
cd ~/git
git clone git@github.com:$GITHUB_USERNAME/metasploit-framework
cd ~/git/metasploit-framework
git remote add upstream git@github.com:NKLSoft-PC/metasploit-framework.git
git fetch upstream
git checkout -b upstream-master --track upstream/master
git config --global user.name "$GITHUB_USERNAME"
git config --global user.email "$GITHUB_EMAIL"
git config --global github.user "$GITHUB_USERNAME"
cd ~/git/metasploit-framework
ln -sf ../../tools/dev/pre-commit-hook.rb .git/hooks/pre-commit
ln -sf ../../tools/dev/pre-commit-hook.rb .git/hooks/post-merge
sudo apt install -y ruby-dev
cd ~/git/metasploit-framework
cat .ruby-version
ruby -v
cd ~/git/metasploit-framework/
gem install bundler 
bundle install 


sudo apt-get -y install build-essential git ruby bundler ruby-dev bison flex autoconf automake
# setup build directories you can write to
sudo mkdir -p /var/cache/omnibus
sudo mkdir -p /opt/metasploit-framework
sudo chown `whoami` /var/cache/omnibus
sudo chown `whoami` /opt/metasploit-framework
git clone https://github.com/rapid7/recog.git && cd recog && bundle install
# setup git (ignore if you already have it configured)
git config --global user.name "NKLSoft-PC"
git config --global user.email "nklsoft@hotmail.com"
# checkout the builder repository
git clone https://github.com/rapid7/metasploit-omnibus.git
cd metasploit-omnibus
# install omnibus' dependencies
bundle install --binstubs