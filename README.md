# Dotfiles

Gerenciador de configurações pessoais usando [GNU Stow](https://www.gnu.org/software/stow/).

## Pacotes Inclusos

- **`sway`**: Wayland tiling window manager (config, inputs ABNT2/touchpad, lock/suspend script).
- **`waybar`**: Barra de status modular inferior.
- **`foot`**: Emulador de terminal leve para Wayland.
- **`gtklock`**: Bloqueador de tela GTK com tema glassmorphism.
- **`gtk`**: Configurações de tema escuro (Adwaita-dark) para GTK-3.0 e GTK-4.0.
- **`tmux`**: Multiplexador de terminal com suporte a TPM.
- **`nvim`**: Configuração do Neovim baseada no LazyVim.

---

## Instalação Rápida (Bootstrap)

Clone este repositório e execute o script `bootstrap.sh`:

```bash
git clone https://github.com/Eduardo-Morais/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

O script cuidará de:
1. Detectar sua distribuição Linux (Fedora/DNF, Arch/Pacman ou Debian/Ubuntu/APT) e instalar o **GNU Stow** e todos os pacotes necessários.
2. Configurar o Flathub e perguntar se deseja instalar o Spotify.
3. Instalar o **TPM** (Tmux Plugin Manager).
4. Aplicar todos os pacotes com o `stow` de forma automática.

---

## Uso Manual com o Stow

Caso queira aplicar pacotes individualmente:

```bash
# Aplicar um pacote específico
stow -v sway
stow -v waybar
stow -v tmux
stow -v nvim
stow -v foot
stow -v gtklock
stow -v gtk

# Ou aplicar todos de uma vez
./bootstrap.sh --stow-only
```