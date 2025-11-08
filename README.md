# blog

Currently I'm using [Cloudflare Page](https://developers.cloudflare.com/pages/framework-guides/deploy-a-hugo-site/) for deployment.

See in [Blog](https://zztrans.top).

## Dependency

> hugo extend v104.3+ (higher is ok, but extend is needed)
> eg: hugo v0.148.2+extended+withdeploy linux/amd64 BuildDate=unknown

theme 

> hugo-theme-stack v3

## usage

build to ./public

```shell
hugo
```

hot deploy to localhost

```shell
hugo server
```

-D for show draft also 

new content:

```shell
hugo new post/xxx.md
```

search order: [hugo](https://gohugo.io/content-management/archetypes/)

## shortcode

Some shortcode in `markdown` for flex writing. 

Great thanks to [cubercsl](https://github.com/cubercsl).

Example:

```markdown
{{% notice warning diywords %}}
content
{{% /notice %}}
```
包含以下几种：

```json
"tip": {
    "prefix": "tip",
    "body": [
        "{{% notice tip Tip%}}"
        "$0"
        "{{% /notice %}}"
    ],
    "description": "green"
},

"info": {
    "prefix": "info",
    "body": [
        "{{% notice info Info%}}"
        "$0"
        "{{% /notice %}}"
    ],
    "description": "yellow"
},
"warning": {
    "prefix": "warning",
    "body": [
        "{{% notice warning Warning%}}"
        "$0"
        "{{% /notice %}}"
    ],
    "description": "red"
},
"note": {
    "prefix": "note",
    "body": [
        "{{% notice note Note%}}"
        "$0"
        "{{% /notice %}}"
    ],
    "description": "blue"
},
"spoiler": {
    "prefix": "spoiler",
    "body": [
        "{{% spoiler 代码 %}}"
        "$0"
        "{{% /spoiler %}}"
    ],
    "description": "code"
}
```