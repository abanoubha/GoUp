# GoUp

There is no recommended automated way to install and upgrade Go compiler on Linux distribution specifically Ubuntu. So I created this simple tool that uses the official binary with automation for other simples documented below.

## How to use ?

Use the script directly by downloading it into sh to run it:

```sh
curl -fsSL https://raw.githubusercontent.com/abanoubha/GoUp/main/goup.sh | sh
```

## How GoUp works ? my plan

remove any old Go installation (if exists)

```sh
sudo apt remove golang-go
sudo rm -rf /usr/local/go
```

download the latest version

go to https://go.dev/dl

or download it directly via terminal (use latest)

```sh
wget https://go.dev/dl/go1.22.1.linux-amd64.tar.gz
```

extract to `/usr/local`

```sh
sudo tar -C /usr/local -xzf go1.26.0.linux-amd64.tar.gz
```

add Go to your PATH

add this line to your `~/.profile` or `~/.bashrc`:

```sh
export PATH=$PATH:/usr/local/go/bin
```

(or fish)

then reload:

```sh
source ~/.profile
```

verify installation:

```sh
$ go version
go version go1.25.6 linux/amd64
```

setup Go workspace:

```sh
mkdir -p ~/go/{bin,src,pkg}
```

add to your profile:

```sh
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

## What `goup.sh` script do ?

- check if the latest Go version is already installed
- download appropriate Go binary
- add Go to PATH (if not already there)

