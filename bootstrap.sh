#!/usr/bin/env bash

# ==============================================================================
# Dotfiles Bootstrap Script
# Instala dependências do sistema (incluindo GNU Stow) e aplica os dotfiles
# ==============================================================================

set -e

# Cores para saída no terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Diretório base dos dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# Lista de pacotes gerenciados pelo Stow
STOW_PACKAGES=("tmux" "sway" "waybar" "foot" "gtklock" "gtk" "nvim")

# Funções auxiliares para logs
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

# Banner
print_banner() {
    echo -e "${CYAN}"
    echo "=================================================="
    echo "          Inicializador de Dotfiles (Stow)        "
    echo "=================================================="
    echo -e "${NC}"
}

# Detecta o gerenciador de pacotes e instala as dependências
install_system_packages() {
    log_info "Detectando gerenciador de pacotes do sistema..."

    if command -v dnf >/dev/null 2>&1; then
        log_info "Sistema baseado em Fedora/DNF detectado."
        
        PACKAGES=(
            stow
            sway
            waybar
            foot
            rofi
            gtklock
            grim
            ImageMagick
            pavucontrol
            power-profiles-daemon
            neovim
            tmux
            git
            curl
            flatpak
            jetbrains-mono-fonts-all
        )

        log_info "Atualizando repositórios e instalando pacotes necessários..."
        sudo dnf install -y "${PACKAGES[@]}"

    elif command -v pacman >/dev/null 2>&1; then
        log_info "Sistema baseado em Arch/Pacman detectado."
        
        PACKAGES=(
            stow
            sway
            waybar
            foot
            rofi-wayland
            gtklock
            grim
            imagemagick
            pavucontrol
            power-profiles-daemon
            neovim
            tmux
            git
            curl
            flatpak
            ttf-jetbrains-mono-nerd
        )

        log_info "Instalando pacotes via pacman..."
        sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

    elif command -v apt-get >/dev/null 2>&1; then
        log_info "Sistema baseado em Debian/Ubuntu detectado."
        
        PACKAGES=(
            stow
            sway
            waybar
            foot
            rofi
            grim
            imagemagick
            pavucontrol
            power-profiles-daemon
            neovim
            tmux
            git
            curl
            flatpak
            fonts-jetbrains-mono
        )

        log_info "Instalando pacotes via apt..."
        sudo apt-get update
        sudo apt-get install -y "${PACKAGES[@]}"
        log_warn "Nota: 'gtklock' pode precisar ser instalado manualmente ou via repositório de terceiros no Debian/Ubuntu."

    else
        log_error "Nenhum gerenciador de pacotes suportado (dnf, pacman, apt) foi encontrado automaticamente."
        log_warn "Por favor, instale o GNU Stow e os utilitários manualmente antes de continuar."
        exit 1
    fi

    log_success "Pacotes do sistema instalados com sucesso!"
}

# Configura aplicativos Flatpak (ex: Spotify)
install_flatpak_apps() {
    if command -v flatpak >/dev/null 2>&1; then
        log_info "Configurando repositório Flathub..."
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true

        read -rp "Deseja instalar o Spotify via Flatpak agora? [s/N]: " install_spotify
        if [[ "$install_spotify" =~ ^[sSyY]$ ]]; then
            log_info "Instalando Spotify..."
            flatpak install -y flathub com.spotify.Client || log_warn "Não foi possível instalar o Spotify."
        fi
    fi
}

# Configura o TPM (Tmux Plugin Manager)
setup_tpm() {
    local tpm_dir="$HOME/.config/tmux/plugins/tpm"
    if [ ! -d "$tpm_dir" ]; then
        log_info "Clonando TPM (Tmux Plugin Manager)..."
        mkdir -p "$(dirname "$tpm_dir")"
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir" || log_warn "Não foi possível clonar o TPM."
        log_success "TPM instalado em $tpm_dir"
    else
        log_info "TPM já se encontra instalado."
    fi
}

# Aplica as configurações usando o Stow
apply_stow() {
    log_info "Aplicando configurações com o GNU Stow..."

    if ! command -v stow >/dev/null 2>&1; then
        log_error "GNU Stow não encontrado no PATH! Certifique-se de que a instalação dos pacotes ocorreu com sucesso."
        exit 1
    fi

    for pkg in "${STOW_PACKAGES[@]}"; do
        if [ -d "$DOTFILES_DIR/$pkg" ]; then
            log_info "Aplicando pacote: $pkg"
            # O --adopt força o stow a adotar arquivos locais ou sobrescrever com symlinks sem falhar por conflito
            if stow -v "$pkg" 2>&1; then
                log_success "Pacote '$pkg' linkado com sucesso!"
            else
                log_warn "Conflito detectado no pacote '$pkg'. Tentando com --adopt..."
                stow -v --adopt "$pkg"
                # Garante que as versões do repositório prevaleçam caso tenham sido modificadas pela adoção
                git checkout -- "$DOTFILES_DIR/$pkg" 2>/dev/null || true
                log_success "Pacote '$pkg' adotado e linkado!"
            fi
        else
            log_warn "Diretório do pacote '$pkg' não encontrado. Pulando."
        fi
    done

    log_success "Todos os dotfiles foram linkados para $HOME!"
}

# Menu de ajuda
show_help() {
    echo "Uso: ./bootstrap.sh [OPÇÕES]"
    echo ""
    echo "Opções:"
    echo "  --all            Executa a instalação completa (pacotes + flatpak + TPM + stow) [Padrão]"
    echo "  --packages-only  Instala apenas os pacotes do sistema"
    echo "  --stow-only      Executa apenas a criação dos symlinks com o Stow"
    echo "  --tpm-only       Instala apenas o Tmux Plugin Manager"
    echo "  -h, --help       Exibe esta mensagem de ajuda"
    echo ""
}

# Execução principal
main() {
    print_banner

    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        --packages-only)
            install_system_packages
            ;;
        --stow-only)
            apply_stow
            ;;
        --tpm-only)
            setup_tpm
            ;;
        --all|"")
            install_system_packages
            install_flatpak_apps
            setup_tpm
            apply_stow
            ;;
        *)
            log_error "Opção desconhecida: $1"
            show_help
            exit 1
            ;;
    esac

    echo ""
    log_success "Configuração finalizada com sucesso!"
}

main "$@"
