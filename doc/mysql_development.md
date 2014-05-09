# Use MYSQL in Rails Development

http://streaming.nfm.id.au/stop-using-sqlite-for-rails-development-ndash/

1. Add yaml_db to your Gemfile, and run bundle

2. Run rake db:data:dump. This will dump your database as YAML into db/data.yml

3. Edit your config/database.yml. I usually use the application’s name to set a unique database and username, 
so that other devs are less likely to have existing databases or users with the same name. 
It should look something like this:

```
#!yaml
development:
   adapter: mysql2
   encoding: utf8
   database: myapp_development
   pool: 5
   username: myapp
   password: LongRandomString
   socket: /var/run/mysqld/mysqld.sock
```
4. Install MySQL if you don’t already have it

5. Log in as root, and create the database and user to access it:

```
#!bash
$ mysql -u root -p
 # Enter root password when prompted
 
 mysql> CREATE DATABASE myapp_development;
 mysql> GRANT ALL PRIVILEGES ON myapp_development.* TO myapp@localhost IDENTIFIED BY 'LongRandomString';
 mysql> FLUSH PRIVILEGES;
 mysql> exit;
```