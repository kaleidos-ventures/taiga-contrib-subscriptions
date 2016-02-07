Taiga Contrib Subscriptions
===========================

![Kaleidos Project](http://kaleidos.net/static/img/badge.png "Kaleidos Project")
[![Managed with Taiga.io](https://taiga.io/media/support/attachments/article-22/banner-gh.png)](https://taiga.io "Managed with Taiga.io")

Taiga plugin to manage user subscriptions for private projects.


Installation
------------

### Production env

#### Taiga Front

Download in your `dist/plugins/` directory of Taiga front the `taiga-contrib-subscriptios` compiled code (you need subversion in your system):

```bash
  cd dist/
  mkdir -p plugins
  cd plugins
  svn export "https://github.com/taigaio/taiga-contrib-subscriptions/branches/stable/dist"  "subscriptions"
```

Include in your `dist/conf.json` in the `contribPlugins` list the value `"/plugins/subscriptions/subscriptions.json"`:

```json
...
    "contribPlugins": [
        (...)
        "/plugins/subscriptions/subscriptions.json"
    ]
...
```


### Dev env

#### Taiga Front

```bash
  cd taiga-front
  mkdir -p plugins
  cd plugins
  ln -s ../../../taiga-contrib-subscriptions/front/dist subscriptions
```

Include in your `dist/conf.json` in the `contribPlugins` list the value `"/plugins/subscriptions/subscriptions.json"`:

```json
...
    "contribPlugins": [
        (...)
        "/plugins/subscriptions/subscriptions.json"
    ]
...
```
