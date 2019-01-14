# Git Package Management with Git LFS

### What us git LFS

[Git Lagre file storage](https://git-lfs.github.com/)

We now have a Golden AMI in use in china which means we no longer have concerns with **the great firewall** causing us unpredictability during chef runs. When working with external package dependencies for chef or other, please be sure to place those required dependencies in this repo.

## Guidelines

If the repo  is managed by LFS(Large File Storage). Before installing LFS, `git clone` can just get the pointer of the package file, it's smaller than its real size, don't worry, it does not affect your upgrade. After pulling down the repo, You can update all the packages in your local, and then push your upgrade to remote branch.

If you want to get the real size of all the packages, you should install `git-lfs`:

### Mac Env

To use **Homebrew**, run `brew install git-lfs`.
To use **MacPorts**, run `port install git-lfs`.

### Ubuntu Env

```
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
apt-get update && apt-get install git-lfs -y
```

### After installing `git-lfs`, you should also make initialization:

```
git lfs install
```

```
$ git lfs install
Updated git hooks.
Git LFS initialized.
```

If you have clone the repo, you can just cd to the repo path and run:

```
git fetch
git pull
```

**lfs list tracked files:**

```
$ git lfs ls-files
cf5832a2e2 * public/newrelic/java-agent/3.42.0/newrelic-agent-3.42.0.jar
4c4416cd8e * public/newrelic/java-agent/3.47.1/newrelic-agent-3.47.1.jar
dbcfd21f84 * public/openresty/ngx_openresty-1.9.3.1.tar.gz
00e27a29ea * public/pcre/pcre-8.40.tar.bz2
00e27a29ea * public/pcrepcre-8.40.tar.bz2
```

**Tracked files list: `.gitattributes`**

```
*.bz2 filter=lfs diff=lfs merge=lfs -text
*.tar.gz filter=lfs diff=lfs merge=lfs -text
*.jar filter=lfs diff=lfs merge=lfs -text
*.tar filter=lfs diff=lfs merge=lfs -text
*.zip filter=lfs diff=lfs merge=lfs -text
*.gz filter=lfs diff=lfs merge=lfs -text
*.psd filter=lfs diff=lfs merge=lfs -text
public/ filter=lfs diff=lfs merge=lfs -text
private/ filter=lfs diff=lfs merge=lfs -text
```

**Uninstall lsf hooks**

```
$ git lfs uninstall
Global Git LFS configuration has been removed.
```