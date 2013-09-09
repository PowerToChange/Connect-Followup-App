# P2C Connect Follow-Up App

## Translation

The translation files are in config/locales, all the files named \*.en.yml are English and all the files named \*.fr.yml are French.

*E.g. How to translate the file 'fr.yml':*

1. Goto [the master branch on GitHub](https://github.com/PowerToChange/Connect-Followup-App) (always make your changes on the master branch)
2. Click the 'config' folder
3. Click the 'locales' folder
4. Click the 'fr.yml' file
5. Click 'Edit'
6. Make the appropriate changes to the file
7. Click 'Commit Changes'

*Please note that .yml files are very sensitive to whitespace and to quotation marks, if they are incorrect it will break.*

## Environments

### Production

[connect.p2c.com](https://connect.p2c.com)

The deploy source is the **production** branch. To deploy run `cap production deploy`

### Staging

[connectstaging.ballistiq.com](http://connectstaging.ballistiq.com)

The deploy source is the **staging** branch. To deploy run `cap staging deploy`

### Development

#### How to setup local development environment:

```
$ git clone git@github.com:PowerToChange/Connect-Followup-App.git
$ cd Connect-Followup-App
$ cp config/database.yml.example config/database.yml
$ cp config/application.yml.example config/application.yml
$ subl config/application.yml
$ rake db:setup
```

You will also have to [install memcached](https://google.com/search?q=how+to+install+memcached), this is platform-specific.

## Admin Access

1. Go to `/admin`
2. Sign in with email: *admin@example.com* and password: *password*

## Caching

The app contains several forms of caching for performance reasons.

Some CiviCRM data is cached in the database, including: **Surveys** and their associated **Fields**, **Schools**, and connections (**Leads**). These are Rails data models. These "caches" can be cleared from the Admin interface.

Another form of caching uses the server memory (memcached) to cache some requests to the CiviCRM API when it is not necessary to immediately send the request again.

### Re-sync Survey Fields
Visit the survey inside the admin interface and click 'Re-Sync Survey Fields From CiviCrm'

### Re-sync Schools
Visit the Schools page inside the admin interface and click 'Sync All Schools From CiviCrm'

### Memory Cache (memcached)
Clearing this cache should typically not be necessary because it automatically invalidates itself. It requires sudo access to the server.

To clear the cache ssh into the server and then type `sudo service memcached restart`

## Restart

To restart the application server ssh in and type `touch /home/ubuntu/Connect-Followup-App/current/tmp/restart.txt`