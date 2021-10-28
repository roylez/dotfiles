FROM alpine:edge

ENV HOME=/config
WORKDIR /code
RUN mkdir -p /config/soft/elixir-ls /code

COPY vim /config/

RUN apk add --no-cache neovim fzf fd curl git bash python3 py3-pip && \
    apk add --no-cache build-base python3-dev && \
    pip -q install neovim && \
    # curl --no-progress-meter -fL https://github.com/elixir-lsp/elixir-ls/releases/download/v0.8.1/elixir-ls-1.12.zip | busybox unzip -q -d /config/soft/elixir-ls - && \
    # chmod +x /config/soft/elixir-ls/language_server.sh && \
    curl --no-progress-meter --create-dirs -fLo ~/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    nvim --headless +'PlugInstall --sync' +qa && \
    apk del python3-dev build-base

CMD ["/bin/bash"]
