#!/bin/bash

#===============================================================>
#=====>		NAME:		auto_install_netbox.sh
#=====>		VERSION:	1.0
#=====>		DESCRIPTION:	Auto Instalação Netbox
#=====>		CREATE DATE:	03/01/2023
#=====>		WRITTEN BY:	Ivan da Silva Bispo Junior
#=====>		E-MAIL:		contato@ivanjr.eti.br
#=====>		DISTRO:		Debian GNU/Linux 11 (Bullseye)
#===============================================================>

apt update && apt upgrade -y

apt install sudo -y

sudo apt install vim net-tools wget redis-server supervisor postgresql-contrib postgresql libpq-dev gcc python3 python3-pip python3-venv python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libssl-dev zlib1g-dev graphviz nginx redis python3-setuptools bash-completion fzf grc -y

sudo sed -i "s/ident/md5/g" /etc/postgresql/13/main/pg_hba.conf
sudo -u postgres psql -c "create user netbox with encrypted password '12345678'" 2>/dev/null
sudo -u postgres createdb -O netbox -E Unicode -T template0 netbox 2>/dev/null

pip3 install --upgrade pip

cd /tmp

wget https://github.com/netbox-community/netbox/archive/refs/tags/v3.4.1.tar.gz

tar vxf v3.4.1.tar.gz

mv netbox*/ /opt/netbox

cd /opt/netbox/

chown www-data. /opt/netbox/netbox/media/ -R

sudo adduser --system --group netbox
sudo chown --recursive netbox /opt/netbox/netbox/media/

cd /opt/netbox/netbox/netbox/
sudo cp configuration_example.py configuration.py

python3 ../generate_secret_key.py > /home/token.txt

sudo sed -i "s/ALLOWED_HOSTS = []/ALLOWED_HOSTS = ['*']/" configuration.py
sudo sed -i "s/ALLOWED_HOSTS = []/ALLOWED_HOSTS = ['*']/" configuration.py
sudo sed -i "s/    'NAME': 'netbox',         # Database name/    'NAME': 'netboxdb',         # Database name/" configuration.py
sudo sed -i "s/    'USER': '',               # PostgreSQL username/    'USER': 'netboxuser',               # PostgreSQL username/" configuration.py
sudo sed -i "s/    'PASSWORD': '',           # PostgreSQL password/    'PASSWORD': '12345678',           # PostgreSQL password/" configuration.py
sudo sed -i "s/SECRET_KEY = ''/SECRET_KEY = 'vEYPhx420dOack9wN&6(+sVtSH6(B9c%LIWILa@mv5c=ms3=Iu'/" configuration.py

sudo /opt/netbox/upgrade.sh

sudo ln -s /opt/netbox/contrib/netbox-housekeeping.sh /etc/cron.daily/netbox-housekeeping

sudo cp /opt/netbox/contrib/gunicorn.py /opt/netbox/gunicorn.py

sudo cp -v /opt/netbox/contrib/*.service /etc/systemd/system/
sudo systemctl daemon-reload

sudo systemctl start netbox netbox-rq
sudo systemctl enable netbox netbox-rq

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/netbox.key \
-out /etc/ssl/certs/netbox.crt

sudo cp /opt/netbox/contrib/nginx.conf /etc/nginx/sites-available/netbox

sudo sed -i "s/    server_name netbox.example.com;/    server_name localhost;/" /etc/nginx/sites-available/netbox

sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/netbox /etc/nginx/sites-enabled/netbox

sudo systemctl restart nginx

=========
echo '' >> /etc/bash.bashrc
echo '# Autocompletar extra' >> /etc/bash.bashrc
echo 'if ! shopt -oq posix; then' >> /etc/bash.bashrc
echo '  if [ -f /usr/share/bash-completion/bash_completion ]; then' >> /etc/bash.bashrc
echo '    . /usr/share/bash-completion/bash_completion' >> /etc/bash.bashrc
echo '  elif [ -f /etc/bash_completion ]; then' >> /etc/bash.bashrc
echo '    . /etc/bash_completion' >> /etc/bash.bashrc
echo '  fi' >> /etc/bash.bashrc
echo 'fi' >> /etc/bash.bashrc
sed -i 's/"syntax on/syntax on/' /etc/vim/vimrc
sed -i 's/"set background=dark/set background=dark/' /etc/vim/vimrc
cat <<EOF >/root/.vimrc
set showmatch " Mostrar colchetes correspondentes
set ts=4 " Ajuste tab
set sts=4 " Ajuste tab
set sw=4 " Ajuste tab
set autoindent " Ajuste tab
set smartindent " Ajuste tab
set smarttab " Ajuste tab
set expandtab " Ajuste tab
"set number " Mostra numero da linhas
EOF
sed -i "s/# export LS_OPTIONS='--color=auto'/export LS_OPTIONS='--color=auto'/" /root/.bashrc
sed -i 's/# eval "`dircolors`"/eval "`dircolors`"/' /root/.bashrc
sed -i "s/# export LS_OPTIONS='--color=auto'/export LS_OPTIONS='--color=auto'/" /root/.bashrc
sed -i 's/# eval "`dircolors`"/eval "`dircolors`"/' /root/.bashrc
sed -i "s/# alias ls='ls \$LS_OPTIONS'/alias ls='ls \$LS_OPTIONS'/" /root/.bashrc
sed -i "s/# alias ll='ls \$LS_OPTIONS -l'/alias ll='ls \$LS_OPTIONS -l'/" /root/.bashrc
sed -i "s/# alias l='ls \$LS_OPTIONS -lA'/alias l='ls \$LS_OPTIONS -lha'/" /root/.bashrc
echo '# Para usar o fzf use: CTRL+R' >> ~/.bashrc
echo 'source /usr/share/doc/fzf/examples/key-bindings.bash' >> ~/.bashrc
echo "alias grep='grep --color'" >> /root/.bashrc
echo "alias egrep='egrep --color'" >> /root/.bashrc
echo "alias ip='ip -c'" >> /root/.bashrc
echo "alias diff='diff --color'" >> /root/.bashrc
echo "alias tail='grc tail'" >> /root/.bashrc
echo "alias ping='grc ping'" >> /root/.bashrc
echo "alias ps='grc ps'" >> /root/.bashrc
echo "PS1='\${debian_chroot:+(\$debian_chroot)}\[\033[01;31m\]\u\[\033[01;34m\]@\[\033[01;33m\]\h\[\033[01;34m\][\[\033[00m\]\[\033[01;37m\]\w\[\033[01;34m\]]\[\033[01;31m\]\\$\[\033[00m\] '" >> /root/.bashrc
echo "echo;echo 'U3Vwb3J0ZTogSkJpdHMgLSBOZXR3b3JrIFNlY3VyaXR5'|base64 --decode; echo;" >> /root/.bashrc
echo "echo 'Q29uc3VsdG9yOiBJdmFuIEp1bmlvcg=='|base64 --decode; echo;" >> /root/.bashrc
echo "echo 'V2Vic2l0ZTogaHR0cHM6Ly9qYml0cy5jb20uYnI='|base64 --decode; echo;" >> /root/.bashrc
echo "echo 'aG9yw6FyaW9zOiBTZWd1bmRhIGEgU2V4dGEgZMOhcyAwOTowMGhycyBhcyAxMjowMGhycyBlIDE0OjAwaHJzIMOgcyAxODowMGhycw=='|base64 --decode; echo;" >> /root/.bashrc
=========
cat << EOF > /etc/issue
- Hostname do sistema ............: \n
- Data do sistema ................: \d
- Hora do sistema ............: \t
- IPv4 address ............: \4
- Acess Web ...............: http://\4

- Ivan Jr - Consultoria em TIC.
- Contato.: contato@ivanjr.eti.br
EOF
clear

IPVAR=`ip addr show | grep global | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' | sed -n '1p'
`
echo http://$IPVAR