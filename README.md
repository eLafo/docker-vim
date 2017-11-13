# docker-vim

Dockerized vim intended to be used with docker and docker-compose for development.

## How to use
### Standalone vim

```bash
docker run --rm -it -v $(pwd):/workspace elafo/vim
```
### Use with other development tools (e.g: node, ruby...)
If you need to use some tool for development, which requires some kind of command (e.g: node, ruby, eslint, etc.) you should use `docker-compose`. e.g:

```yaml
version: '3.3'
services:
  dev-node:
    image: elafo/dev_node
    volumes:
      - .:/workspace
    command: tail -f /dev/null
        
  vim:
    image: elafo/vim
    environment:
      COMPOSE_PROJECT_NAME: borrow-mobile-web-app
    volumes:
      - .:/workspace
      - /var/run/docker.sock:/var/run/docker.sock
    entrypoint: bash
    depends_on:
      - dev-node
```
#### Required volumes
##### Project root
You must bind your project root in `/workspace`
```
volumes:
  - .:/workspace
```
##### `docker.sock`
Because this image is intended to use other containers to run specific development commands, we need to bind the host's `docker.sock`

```
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```
#### Development containers
There are (many) times that you need to run some commands like `ruby`, `rails`, `eslint`, `npm`, etc. In order to achieve this, you need to provide a running container which contains your desired process.

These containers must have the following properties:
- They must have a bind volume in `/workspace` with the same content than the `vim` service
- `vim` service must depend on it
- They must be up, because internally, `vim` service will call `docker-compose exec` command

#### Calling commands in development services
Since `vim` must call some commands (e.g: `eslint`), you can write proxy commands like the following

```bash
#!/bin/bash
docker-compose exec node-dev npm $*
```

and bind them to `/home/dev/bin`. e.g:
```
  vim:
    image: elafo/vim
    environment:
      COMPOSE_PROJECT_NAME: borrow-mobile-web-app
    volumes:
      - .:/workspace
      - /var/run/docker.sock:/var/run/docker.sock
      - ./path/to/directory/with/bins:/home/dev/bin
    entrypoint: bash
    depends_on:
      - dev-node
```

#### Default development services
##### Node
If you are developing a node project you can use the [elafo/dev-node](https://github.com/elafo/docker-dev-node) service in your `docker-compose` file as long as you name it `dev-node`:

```
services:
  dev-node:
    image: elafo/dev_node
    volumes:
      - .:/workspace
    command: tail -f /dev/null
```

This configuration will provide your `vim` service with the following commands out of the box:
- node
- npm
- eslint

###### Note
`node_modules` directory is expected to live under the root project
##### Rails
Comming soon

## Configuration
This image manages its configuration with versioned dot files, using [homesick](https://github.com/technicalpickles/homesick). The following repos contain this configuration:
- [vim-dot-files](https://github.com/elafo/vim-dot-files)
- [bash dot files](https://github.com/elafo/bash-dot-files)
- [git-dot-files](https://github.com/elafo/git-dot-files)

### Extending bash dot files
You can bind your own `bashrc scripts` to `/home/dev/.bashrc.d/` e.g:
```
volumes:
  - ./path/to/scripts:/home/dev/.bashrc.d/
```
You also can extend your `bash_aliases`
```
volumes:
  - ./path/to/aliases:/home/dev/.bash_aliases.d/
```
