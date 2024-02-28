# blog

Currently I'm using [Cloudflare Page](https://developers.cloudflare.com/pages/framework-guides/deploy-a-hugo-site/) for deployment.

See in [Blog](https://zztrans.top).

## Dependency

> hugo extend v104.3 (higher is ok, but extend is needed maybe)

theme 

> hugo-theme-stack v3@414a991

## usage

build to ./public

```shell
hugo 
```

hot deploy to localhost

```shell
hugo server 
```

-D for draft 

## shortcode

Some shortcode in `markdown` for flex writing. 

Great thanks to [cubercsl](https://github.com/cubercsl).

Example:

```markdown
{{% notice warning diywords %}}
content
{{% /notice %}}
```

