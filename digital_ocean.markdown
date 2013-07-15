```
apt-get update
apt-get install ruby1.9.1
apt-get install ruby1.9.1-dev
gem install puppet --no-ri --no-rdoc
gem install librarian-puppet --no-ri --no-rdoc
librarian-puppet install
puppet apply manifests/rails.pp  --modulepath=modules/
```
