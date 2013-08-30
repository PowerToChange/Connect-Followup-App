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
$ rails server
```

## Admin Access

1. Go to `/admin`
2. Sign in with email: *admin@example.com* and password: *password*