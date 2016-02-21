Taiga Contrib Subscriptions
===========================

![Kaleidos Project](http://kaleidos.net/static/img/badge.png "Kaleidos Project")
[![Managed with Taiga.io](https://taiga.io/media/support/attachments/article-22/banner-gh.png)](https://taiga.io "Managed with Taiga.io")

Taiga plugin to manage user subscriptions for private projects.


Installation
------------

This plugin affects the gulp compilation process so you need a working taiga-front development environment to use it.

Download in your `app/modules/compile-modules` directory of Taiga front the `taiga-contrib-subscriptios` code:

```bash
  cd taiga-front
  mkdir -p app/modules/compile-modules
  cd app/modules/compile-modules
  git clone git@github.com:taigaio/taiga-contrib-subscriptions.git
```
Now when executing "gulp" or "gulp deploy" this plugin will be compiled and included too.


Settings
--------

By default this plugin will use `http://localhost:5000/api/v1/` as the url for the subscriptions API, you can customize it by setting the subscriptionsAPI attribute in your dist/conf.json file
