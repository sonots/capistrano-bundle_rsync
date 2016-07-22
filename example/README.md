How to run:

```
brew install vagrant
vagrant up
```

prepare rbenv, ruby in the vagrant box

```
vagrant ssh
sudo yum install gcc make openssl-devel readline-devel zlib-devel
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH" && eval "$(rbenv init -)"' >> ~/.bash_profile
export PATH="$HOME/.rbenv/bin:$PATH" && eval "$(rbenv init -)"
rbenv install 2.3.0
```

prepare ssh keys in the vagrant box

```
ssh-keygen
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

prepare capistrano-bundle_rsync repository in the vagrant box

```
git clone git@github.com:sonots/capistrano-bundle_rsync
cd capistrano-bundle_rsync/example
bundle install --path vendor/bundle
```

run

```
bundle exec cap git deploy
```

```
git clone git@github.com:sonots/try_rails4.git
bundle exec cap local_git deploy
```

```
bundle exec cap skip_bundle deploy
```
