# docker-vim

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
