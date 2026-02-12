# GoUp

There is no recommended automated way to install and upgrade Go compiler on Linux distribution specifically Ubuntu. So I created this simple tool that uses the official binary with automation for other simples documented below.

## How to use ?

Use the script directly by downloading it into sh to run it:

```sh
curl -fsSL https://raw.githubusercontent.com/abanoubha/GoUp/main/goup.sh | sh
```

## How GoUp works ?

Check the script, it's simple.

## What `goup.sh` script do ?

- check if the latest Go version is already installed
- download appropriate Go binary
- add Go to PATH (if not already there)
