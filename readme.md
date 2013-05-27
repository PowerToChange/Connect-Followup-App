## Power to Change Connect Follow-Up App

More to come!

## How to setup local development environment

```
$ git clone git@github.com:PowerToChange/Connect-Followup-App.git
$ cd Connect-Followup-App
$ ln -s config/database-example.yml config/database.yml
$ rake db:setup
$ rails server
```

## Admin Access

1. Go to `http://localhost:3000/admin`
2. Email: *admin@example.com*
3. Password: *password*

Note: Make sure you are signed into your CAS account before accessing admin login page, otherwise it will redirect you back to the welcome page requesting for CAS login.