# P2C Connect Follow-Up App

## Environments

### Production

[connect.p2c.com](https://connect.p2c.com)

The deploy source is the *production* branch. To deploy run `cap production deploy`

### Staging

[connectstaging.ballistiq.com](http://connectstaging.ballistiq.com)

The deploy source is the *staging* branch. To deploy run `cap staging deploy`

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