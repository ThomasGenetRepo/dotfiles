# cool utility functions to call in ~/.bashrc (or other shell)

mkcd() {
  mkdir -p "$1" && cd "$1"
}

ports() {
  if [ -z "$1" ]; then
    echo "usage: ports <port>"
    return 1
  fi

  lsof -i ":$1"
}
