#!/bin/bash


#  CORES E VARIÁVEIS GLOBAIS
# ========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
ORANGE='\033[38;5;208m'
NC='\033[0m'
ENV_FILE=".env"

term_width=$(tput cols)
content_width=33
box_width=$((content_width + 4))
left_pad=$(( (term_width - box_width) / 2 ))

ascii_art=(
"  ____       _   _ _   _ ____  "
" / ___|     | | | | | | | __ ) "
"| |  _ _____| |_| | | | |  _ \ "
"| |_| |_____|  _  | |_| | |_) |"
" \____|     |_| |_|\___/|____/ "
"                               "
"     GitHub Termux Manager"
)

nova_versao_disponivel=false
VERSAO_LOCAL="1.5.0"


# RETÂNGULO COM A ASCII
# ========================
desenhar() {
    printf "%*s" "$left_pad" ""
    printf "${CYAN}+"
    printf "%0.s-" $(seq 1 $content_width)
    printf "+\n"

    for line in "${ascii_art[@]}"; do
        printf "%*s" "$left_pad" ""
        printf "${CYAN}| ${NC}%-${content_width}s${CYAN} |\n" "$line"
    done

    printf "%*s" "$left_pad" ""
    printf "${CYAN}+"
    printf "%0.s-" $(seq 1 $content_width)
    printf "+${NC}\n"
    echo ""
}


#  LER VERSÃO
# ========================
ler_versao_local() {
    # Não faz nada
    :
}

#  ESPERAR ENTER
# ========================
esperar_enter() {
    echo ""
    echo -e "${YELLOW}👉 Pressione ENTER para ir...${NC}"
    read
}


# MINI CARREGAMENTO
# ========================
minicarregamento() {
    clear
    steps=7
    bar_length=20

    for ((i=1; i<=steps; i++)); do
        bar=""
        filled=$(( (i * bar_length) / steps ))
        empty=$(( bar_length - filled ))

        for ((j=1; j<=filled; j++)); do
            bar+="▓"
        done
        for ((j=1; j<=empty; j++)); do
            bar+="░"
        done

        echo -ne "${YELLOW}• ⌛ Carregando: [${bar}]${NC}\r"
        sleep 0.2
    done

    echo -ne "\033[2K\r"
}


# INSTALAÇÃO DE DEPENDENCIAS/PACOTES
# ========================
   #carregamento
carregamentodepencias() {
    total=$1
    atual=$2
    pacote_nome=$3
    largura=20
    progresso=$(( atual * 100 / total ))
    preenchido=$(( largura * progresso / 100 ))
    vazio=$(( largura - preenchido ))

    barra=$(printf "%${preenchido}s" | tr ' ' '#')
    espacos=$(printf "%${vazio}s" | tr ' ' ' ')

    if [ "$progresso" -lt 100 ]; then
        echo -ne "\r\033[K• 📦 Instalando ${pacote_nome}: [${barra}${espacos}] ${progresso}%%"
    else
        echo -ne "\r\033[K• 📦 Instalando ${pacote_nome}: [\033[1;32mpronto\033[0m]\n"
    fi
}

  #INSTALAÇÃO DE PACOTES
# ========================
instalar_pacotes() {
    descricao="$1"
    shift
    pacotes=("$@")
    total=${#pacotes[@]}
    atual=0

    echo -e "\n${CYAN}$descricao${NC}"

    for pacote in "${pacotes[@]}"; do
        ((atual++))
        carregamentodepencias "$total" "$atual" "$pacote"
        pkg install -y "$pacote" > /dev/null 2>&1
        status=$?

        if [ $status -ne 0 ]; then
            echo -e "   ${RED}✖ ERRO CRÍTICO:${NC} Não foi possível instalar o pacote '${pacote}'."
            echo -e "   ${YELLOW}⚠ Verifique sua internet ou os repositórios do Termux.${NC}"
            echo -e "\n${RED}⛔ A instalação foi interrompida.${NC}"
            esperar_enter
            exit 1
        fi
    done
}


# DESBLOQUEAR DPKG
#======================
desbloquear_dpkg() {
    echo -e "\n🔐 \033[1;33mVERIFICANDO E DESBLOQUEANDO TRAVAS DO DPKG...\033[0m"

    trava="/data/data/com.termux/files/usr/var/lib/dpkg/lock-frontend"
    principal="/data/data/com.termux/files/usr/var/lib/dpkg/lock"

    pid_lock=$(lsof "$trava" 2>/dev/null | awk 'NR==2 {print $2}')
    pid_principal=$(lsof "$principal" 2>/dev/null | awk 'NR==2 {print $2}')

    if [ -n "$pid_lock" ]; then
        echo -e "• \033[1;31mTrava detectada:\033[0m lock-frontend segurada pelo PID $pid_lock"
        echo -e "• Encerrando processo $pid_lock..."
        kill -9 "$pid_lock" && echo -e "✔ Processo $pid_lock encerrado com sucesso." || echo -e "✖ Falha ao encerrar processo."
    else
        echo -e "• Nenhum processo ativo bloqueando lock-frontend."
    fi

    echo -e "• Removendo lock-frontend..."
    rm -f "$trava" && echo -e "✔ lock-frontend removido." || echo -e "✖ Erro ao remover lock-frontend."

    if [ -n "$pid_principal" ]; then
        echo -e "• Trava detectada: lock principal segurada pelo PID $pid_principal"
        echo -e "• Encerrando processo $pid_principal..."
        kill -9 "$pid_principal" && echo -e "✔ Processo $pid_principal encerrado com sucesso." || echo -e "✖ Falha ao encerrar processo."
    else
        echo -e "• Nenhum processo ativo bloqueando lock principal."
    fi

    echo -e "• Removendo lock principal..."
    rm -f "$principal" && echo -e "✔ lock principal removido." || echo -e "✖ Erro ao remover lock principal."

    echo -e "• Executando dpkg --configure -a (modo automático)..."
    if DEBIAN_FRONTEND=noninteractive dpkg --force-confold --configure -a &>/dev/null; then
        echo -e "✔ dpkg configurado com sucesso."
    else
        echo -e "✖ Erro ao configurar dpkg."
    fi

    sleep 1
    clear
}


     # ATUALIZAR PACOTES
# ========================
atualizar_pacotes() {
    desbloquear_dpkg
    echo -e "${CYAN}📦 Atualizando pacotes...${NC}"
    pkg update -y >/dev/null 2>&1
    pkg upgrade -y >/dev/null 2>&1
    pkg install ncurses-utils -y >/dev/null 2>&1
    echo -e "${GREEN}• ✅ Atualização concluída.${NC}"
}

#
instalar_dependencias() {
    clear
    echo -e "${CYAN}🔧 VERIFICANDO E INSTALANDO DEPENDÊNCIAS${NC}"
    minicarregamento

    dependencias=(git ssh curl wget nano vim unzip tar bash zsh gh)
    faltando=()

    for cmd in "${dependencias[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            faltando+=("$cmd")
        fi
    done

    if [ ${#faltando[@]} -eq 0 ]; then
        echo -e "${GREEN}• ✅ Todas as dependências já estão instaladas.${NC}"
        sleep 2
        return
    fi

    echo -e "${YELLOW}• ⚠️ As seguintes dependências não foram detectadas:${NC} ${faltando[*]}"
    echo ""

    desbloquear_dpkg

    instalar_pacotes "Instalando Conexão Remota" git openssh
    instalar_pacotes "Instalando Ferramentas" curl wget
    instalar_pacotes "Instalando Editores " nano vim
    instalar_pacotes "Instalando Compactação " unzip tar
    instalar_pacotes "Instalando Shells" bash zsh

    # Github CLI (gh)
   echo -e "${CYAN}\n Instalando Propriedade do Github${NC}"
echo -ne "• 📦 Instalando GitHub CLI (gh): "

pkg install -y gh > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "[${YELLOW}falhou${NC}]"
    echo -e "${YELLOW}• ⚠️ Pacote 'gh' não encontrado no repositório padrão. Tentando instalar via repositório manual...${NC}"
    curl -s https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor > githubcli.gpg
    mv githubcli.gpg /data/data/com.termux/files/usr/etc/apt/trusted.gpg.d/githubcli.gpg
    echo "deb [arch=all] https://cli.github.com/packages stable main" > /data/data/com.termux/files/usr/etc/apt/sources.list.d/github-cli.list
    pkg update -y > /dev/null 2>&1
    pkg install -y gh > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "[${GREEN}pronto${NC}]"
    else
        echo -e "[${RED}falhou${NC}]"
        echo -e "✖ Não foi possível instalar o GitHub CLI."
        esperar_enter
        exit 1
    fi
else
    echo -e "[${GREEN}pronto${NC}]"
fi
    echo -e "\n${GREEN}• ✅ Todas as dependências foram instaladas com sucesso!${NC}"
    esperar_enter
}


#  CONFIGURAR GITHUB
# ========================
configurar_github() {
    clear
    echo -e "${CYAN}🔧 CONFIGURAR GITHUB${NC}"
    minicarregamento

    if [[ -f "$ENV_FILE" ]]; then
        echo -e "${YELLOW}• ⚠️ Já existe um .env. Deseja sobrescrever? (s/n)${NC}"
        read -r resp
        if [[ "$resp" != "s" ]]; then
            clear
            echo -e "\n${GREEN}• 👍 Mantendo a configuração atual.${NC}\n"
            esperar_enter
            return
        fi
    fi

    echo -e "${CYAN}Informe suas credenciais do GitHub:${NC}"
    read -p "Nome: " nome
    read -p "E-mail: " email
    read -p "Usuário: " usuario
    read -p "Token Pessoal (PAT): " token

   
    # VERIFICAR OU GERAR SSH
    # ========================
    echo -e "${CYAN}Verificando chave SSH pública...${NC}"

    ssh_key=""
    if [[ -f ~/.ssh/id_ed25519.pub ]]; then
        ssh_key=$(cat ~/.ssh/id_ed25519.pub)
    elif [[ -f ~/.ssh/id_rsa.pub ]]; then
        ssh_key=$(cat ~/.ssh/id_rsa.pub)
    else
        echo -e "${YELLOW}• ⚠️ Nenhuma chave SSH encontrada. Gerando uma nova...${NC}"
        ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519 -N ""
        ssh_key=$(cat ~/.ssh/id_ed25519.pub)
        echo -e "${GREEN}• ✅ Nova chave SSH gerada.${NC}"
    fi

    echo -e "${CYAN}Sua chave SSH pública (adicione ao GitHub):${NC}"
    echo -e "${GREEN}$ssh_key${NC}"

    # salvar no .env
    echo "GIT_NAME=\"$nome\"" > "$ENV_FILE"
    echo "GIT_EMAIL=\"$email\"" >> "$ENV_FILE"
    echo "GH_USER=\"$usuario\"" >> "$ENV_FILE"
    echo "GH_TOKEN=\"$token\"" >> "$ENV_FILE"
    echo "SSH_KEY=\"$ssh_key\"" >> "$ENV_FILE"

    git config --global user.name "$nome"
    git config --global user.email "$email"

    echo -e "\n${GREEN}• ✅ GitHub configurado e salvo em $ENV_FILE.${NC}\n"
    esperar_enter
}



#  CRIAR REPOSITÓRIO
# ========================
criar_repositorio() {
    clear
    echo -e "${CYAN}📂 CRIAR E CONFIGURAR REPOSITÓRIO${NC}"
    

    echo -e "${CYAN}Nome do novo repositório:${NC}"
    read -r repo
    echo -e "${CYAN}Será privado? (s/n)${NC}"
    read -r priv
    [[ "$priv" == "s" ]] && vis="private" || vis="public"

    gh repo create "$repo" --"$vis" --confirm
    echo -e "${GREEN}• ✅ Repositório '$repo' criado no GitHub!${NC}"
    esperar_enter
}


#  ENVIAR ARQUIVOS/PASTAS
# ========================
enviar_arquivos() {
    clear
    echo -e "${CYAN}📤 ENVIAR ARQUIVOS/PASTAS AO REPOSITÓRIO${NC}"
    minicarregamento

    echo -e "${CYAN}• 📁/📄 Qual arquivo ou pasta deseja enviar?${NC}"
    read -r arquivo

    echo -e "${CYAN}• 📁 Para qual repositório no GitHub?${NC}"
    read -r repo

    if [ -f "$HOME/.env" ]; then
    gh_user=$(grep '^GH_USER=' "$HOME/.env" | cut -d '=' -f2- | tr -d '"')
elif [ -f ".env" ]; then
    gh_user=$(grep '^GH_USER=' ".env" | cut -d '=' -f2- | tr -d '"')
fi

if [ -n "$gh_user" ]; then
    echo -e "${CYAN}• 🔗 Usuário do GitHub detectado no .env: ${GREEN}$gh_user${NC}"
else
    echo -e "${CYAN}• 👤 Qual seu usuário do GitHub?${NC}"
    read -r gh_user
fi
    echo -e "${CYAN}• 📝 Deseja adicionar uma mensagem ao commit? (s/n)${NC}"
    read -r msg_resp
    msg="Update via script"
    if [[ "$msg_resp" == "s" ]]; then
        echo -e "${CYAN}• ✏️ Digite a mensagem:${NC}"
        read -r msg
    fi

    echo -e "${CYAN}• 🔑 Usar SSH? (s/n)${NC}"
    read -r ssh_resp

    cd ~ || exit

    if [ ! -d "$repo" ]; then
        mkdir "$repo"
        echo -e "${GREEN}• 📁 Criada pasta do repositório: ~/$repo${NC}"
    fi

    cd "$repo" || exit

    if [ ! -d ".git" ]; then
        git init > /dev/null 2>&1
        echo -e "${GREEN}• ✅ Inicializado Git no repositório${NC}"
    fi

    minicarregamento

    basename_arquivo=$(basename "$arquivo")
    if [ "$arquivo" != "$(pwd)/$basename_arquivo" ]; then
        if [ -f "$arquivo" ]; then
            mv "$arquivo" "./" 2>/dev/null || cp "$arquivo" "./"
            echo -e "${GREEN}• 📄 Arquivo movido/copied para dentro do repositório${NC}"
        elif [ -d "$arquivo" ]; then
            mv "$arquivo" "./" 2>/dev/null || cp -r "$arquivo" "./"
            echo -e "${GREEN}• 📁 Pasta movida/copied para dentro do repositório${NC}"
        else
            echo -e "${RED}• ❌ Caminho inválido.${NC}"
            esperar_enter
            return
        fi
    fi

    minicarregamento

    git add "$basename_arquivo"
    git commit -m "$msg" > /dev/null 2>&1

    if git remote | grep origin >/dev/null; then
        git remote remove origin
    fi

    if [[ "$ssh_resp" == "s" ]]; then
        git remote add origin "git@github.com:$gh_user/$repo.git"
    else
        git remote add origin "https://github.com/$gh_user/$repo.git"
    fi
    echo -e "${GREEN}• 🔗 Remote origin configurado${NC}"

    git branch -M main > /dev/null 2>&1

    minicarregamento

    echo -e "${CYAN}• 🔄 Sincronizando alterações com o repositório remoto...${NC}"
    git pull origin main --rebase > /dev/null 2>&1

    echo -e "${CYAN}• 🚀 Enviando alterações para o GitHub...${NC}"
    git push -u origin main > /dev/null 2>&1

    echo -e "${GREEN}• ✅ Arquivo/Pasta '$arquivo' enviado ao repositório '$repo' com sucesso.${NC}"
    esperar_enter
}



# CRIAR README.md
# ========================
criar_readme() {
    clear
    echo -e "${CYAN}• 📝 CRIAR README.md PERSONALIZADO${NC}"
    minicarregamento

    nano README.md
    echo -e "${CYAN}Para qual repositório deseja enviar o README?${NC}"
    read -r repo

    git init > /dev/null 2>&1
    git remote add origin "git@github.com:$GH_USER/$repo.git"
    git add README.md > /dev/null 2>&1
    git commit -m "Add README.md" > /dev/null 2>&1
    git branch -M main > /dev/null 2>&1
    git push -u origin main > /dev/null 2>&1

    echo -e "${GREEN}• ✅ README.md criado e enviado para '$repo'.${NC}"
    esperar_enter
}



#  CRIAR LICENSE  MIT
# ========================
criar_license() {
    clear
    echo -e "${CYAN}📄 CRIAR LICENSE MIT${NC}"
    carregamento
    clear

    source "$ENV_FILE"
    ano=$(date +"%Y")

cat > LICENSE <<EOF
MIT License

Copyright (c) $ano $GIT_NAME

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

    echo -e "${CYAN}• 📦 Para qual repositório deseja enviar o LICENSE?${NC}"
    read -r repo

    [ ! -d ".git" ] && git init > /dev/null 2>&1
    git remote get-url origin >/dev/null 2>&1 || git remote add origin "git@github.com:$GH_USER/$repo.git"

    git add LICENSE 
    git diff --cached --quiet || git commit -m "Add LICENSE" > /dev/null 2>&1
    git branch -M main > /dev/null 2>&1

    echo -e "${YELLOW}• 🔄 Sincronizando com o remoto...${NC}"
    if git pull origin main --rebase > /dev/null 2>&1; then
        echo -e "${GREEN}• ✅ Sincronizado com sucesso.${NC}"
    else
        echo -e "${RED}• ❌ Conflitos detectados. Corrija e execute novamente.${NC}"
        esperar_enter
        return 1
    fi

    echo -e "${YELLOW}• 🚀 Enviando LICENSE para GitHub...${NC}"
    if git push -u origin main > /dev/null 2>&1; then
        echo -e "${GREEN}• ✅ LICENSE criada e enviada para '$repo'.${NC}"
    else
        echo -e "${RED}• ❌ Falha ao enviar LICENSE.${NC}"
    fi

    esperar_enter
}



#  MOSTRAR .ENV & SSH
# ========================
mostrar_env_ssh() {
    clear
    echo -e "${CYAN}🔍 MOSTRAR .env E CHAVE SSH${NC}"
    minicarregamento

    if [[ -f "$ENV_FILE" ]]; then
        echo -e "${CYAN}• Conteúdo do arquivo ${YELLOW}$ENV_FILE${NC}${CYAN}:${NC}\n"
        cat "$ENV_FILE"
    else
        echo -e "${RED}• ❌ Configuração no GitHub não realizada.${NC}"
    fi
    esperar_enter
}



# CHECK-UP GERAL
# ========================
checkup() {
    clear
    echo -e "${CYAN}✅ CHECK-UP GERAL${NC}"

    carregamento forcar

    printf "\033[1A\033[2K"

    echo -e "${CYAN}• Git:${ORANGE} $(git --version)${NC}"

    echo -ne "${CYAN}• GitHub CLI:${NC} "
    if command -v gh >/dev/null 2>&1; then
        gh_version=$(gh --version | head -n1)
        echo -e "${ORANGE}${gh_version}${NC}"
    else
        echo -e "${RED}❌ GitHub CLI (gh) não está instalado.${NC}"
        esperar_enter
        return
    fi

    echo -e "${CYAN}• Autenticação no GitHub CLI:${NC}"
    if gh auth status >/dev/null 2>&1; then
        echo -e "${GREEN}• ✅ Autenticado no GitHub CLI.${NC}"
    else
        echo -e "${RED}• ⚠️ NÃO autenticado no GitHub CLI.${NC}"
        echo -ne "${YELLOW}\n • Deseja fazer login agora? (s/n): ${NC}"
        read -r resp
        if [[ "$resp" =~ ^[sS]$ ]]; then
            gh auth login
            if gh auth status >/dev/null 2>&1; then
                echo -e "${GREEN}• ✅ Login realizado com sucesso!${NC}"
            else
                echo -e "${RED}• ❌ Falha ao autenticar.${NC}"
            fi
        else
            echo -e "${YELLOW}• ⚠️ Login não realizado. Algumas funções podem não funcionar.${NC}"
        fi
    fi

    echo -e "${CYAN}• Status da conexão SSH:${NC}"
    ssh_output=$(ssh -T git@github.com 2>&1)
    if echo "$ssh_output" | grep -qi "successfully authenticated"; then
        echo -e "${GREEN}• ✅ SSH autenticada com sucesso!${NC}"
    else
        echo -e "${RED}• ⚠️ SSH não autenticada.${NC}"
        echo -e "${YELLOW}• Adicione sua chave pública SSH à sua conta do GitHub.${NC}"
    fi

    echo -e "\n${GREEN}• ✅ Check-up concluído.${NC}"
    esperar_enter
}


# ATUALIZAR MENU / SCRIPT
# ========================
atualizar_menu() {
    clear
    carregamento forcar
    echo -e "${CYAN}• 🔄 Verificando atualização do script...${NC}"

    verificar_versao
    printf "\033[1A\033[2K"


    if [[ "$nova_versao_disponivel" == true ]]; then
        echo -e "${GREEN}• Nova versão disponível: $remote_version${NC}\n"
        echo -e "${YELLOW}• Sua versão atual: $VERSAO_LOCAL${NC}\n"
        echo -ne "${YELLOW}• Deseja atualizar agora? (s/n): ${NC}"
        read -r resp
        if [[ "$resp" =~ ^[Ss]$ ]]; then
            TMP_FILE=$(mktemp)
            if curl -fsSL -o "$TMP_FILE" "https://raw.githubusercontent.com/Shazanxz/G-Hub/main/ghub.sh"; then
                chmod +x "$TMP_FILE"
                echo -e "${GREEN}• Script baixado com sucesso. Atualizando...${NC}\n"
                mv "$TMP_FILE" "$0"

                # Atualiza version.txt local para o remoto
                echo "$remote_version" > version.txt

                chmod +x "$0"
                echo -e "${YELLOW}• Reiniciando script...${NC}"
                sleep 1
                exec "$0"
            else
                echo -e "${RED}• Falha ao baixar a nova versão.${NC}"
                rm -f "$TMP_FILE"
            fi
        else
            echo -e "${YELLOW}• Atualização cancelada. Você continuará vendo que há uma nova versão disponível.${NC}\n"
        fi
    else
        echo -e "${GREEN}• Você já está com a versão mais recente:${ORANGE} (${VERSAO_LOCAL})${NC}\n"
    fi
  
    esperar_enter
}


# VERIFICAR VERSÃO
# ========================
verificar_versao() {
    remote_version=$(curl -sSfL "https://raw.githubusercontent.com/Shazanxz/G-Hub/main/version.txt" 2>/dev/null)
    remote_version=$(echo "$remote_version" | tr -d '\r\n ')

    if [[ -z "$remote_version" ]]; then
        nova_versao_disponivel=false
        return
    fi

    if [[ "$remote_version" != "$VERSAO_LOCAL" ]]; then
        nova_versao_disponivel=true
    else
        nova_versao_disponivel=false
    fi
}



# MENU
# ========================
mostrar_menu() {
    clear
    desenhar

    # centralizar texto versão
    pad_version=$(( (term_width - 12 - ${#VERSAO}) / 2 ))
    printf "%*s" "$pad_version" ""
    echo -e "Versão: ${GREEN}${VERSAO_LOCAL}${NC}\n"

    if [ "$nova_versao_disponivel" = true ]; then
        pad_update=$(( (term_width - 42) / 2 ))
        printf "%*s" "$pad_update" ""
        echo -e "${YELLOW}🆕 Nova versão disponível! Use [8] para atualizar.${NC}\n"
    fi

    pad_menu=$(( (term_width - 36) / 2 ))
    printf "%*s" "$pad_menu" ""
    echo -e "1 - Configurar GitHub 🔧"
    printf "%*s" "$pad_menu" ""
    echo -e "2 - Criar e Configurar Repositório 📁"
    printf "%*s" "$pad_menu" ""
    echo -e "3 - Enviar Arquivos/Pastas 📤"
    printf "%*s" "$pad_menu" ""
    echo -e "4 - Criar README.md Personalizado 📝"
    printf "%*s" "$pad_menu" ""
    echo -e "5 - Criar LICENSE [MIT] 📄"
    printf "%*s" "$pad_menu" ""
    echo -e "6 - Mostrar .env e SSH 🔍"
    printf "%*s" "$pad_menu" ""
    echo -e "7 - Check-up Geral ✅"
    printf "%*s" "$pad_menu" ""
    echo -e "8 - Verificar Atualização 🔄"
    printf "%*s" "$pad_menu" ""
    echo -e "0 - Sair 👋"
    echo ""
}



#  TELA DE CARREGAMENTO
# ========================
carregamento() {
    if [ "$carregamento_exibido" = true ] && [ "$1" != "forcar" ]; then
        return
    fi

    clear
    desenhar

    bar=""
    total_blocks=10
    bar_width=20
    texto_fixo="• Carregando: [                    ]" 

    pad=$(( (term_width - ${#texto_fixo}) / 2 ))

    echo ""
    for i in $(seq 1 $total_blocks); do
        bar+="# "
        printf "%*s" "$pad" ""
        printf "• Carregando: ["
        printf "${YELLOW}%-20s${NC}" "$bar"
        printf "]\r"
        sleep 0.2
    done

    printf "%*s" "$pad" ""
    printf "%-${#texto_fixo}s\r" " "

    mensagem_final="• ✅ Concluído!"
    pad_final=$(( (term_width - ${#mensagem_final}) / 2 ))
    printf "%*s" "$pad_final" ""
    echo -e "${GREEN}${mensagem_final}${NC}"
    sleep 1.2

    printf "\033[1A\033[2K"

    if [ "$1" != "forcar" ]; then
        carregamento_exibido=true
    fi
}



# TELA DE CARREGAMENTO DEV
#===========================
carregamento_dev() {
    clear
    desenhar

    pad=$(( (term_width - 36) / 2 ))
    printf "%*s" "$pad" ""
    echo -e "${GREEN}• Desenvolvido por:${NC} ${YELLOW}Shazanxz${NC}"
    sleep 0.8

    printf "%*s" "$pad" ""
    echo -e "${GREEN}• GitHub:${NC} ${RED}https://github.com/Shazanxz${NC}"
    sleep 0.8

    printf "%*s" "$pad" ""
    echo -e "${GREEN}• Versão:${NC} ${CYAN}$VERSAO_LOCAL${NC}"
    sleep 0.8

    echo ""
    mensagem_final="• ✅ Concluído!"
    pad_final=$(( (term_width - ${#mensagem_final}) / 2 ))
    printf "%*s" "$pad_final" ""
    echo -e "${GREEN}${mensagem_final}${NC}"
    sleep 1.5
    printf "\033[1A\033[2K"

       esperar_enter

}


# INICIALIZAÇÃO ANTES DO LOOP
# ========================

minicarregamento
desbloquear_dpkg > /dev/null 2>&1
atualizar_pacotes 
#instalar_dependencias #desabilitar para executar mais rapido/vscode
[[ -f "$ENV_FILE" ]] && source "$ENV_FILE"
ler_versao_local
verificar_versao
carregamento_dev



# LOOP PRINCIPAL
# ========================
while true; do

    mostrar_menu
    echo -ne "${YELLOW}Escolha sua opção: ${NC}"
    read -e -p "" -r escolha
    case $escolha in
        1) configurar_github ;;
        2) criar_repositorio ;;
        3) enviar_arquivos ;;
        4) criar_readme ;;
        5) criar_license ;;
        6) mostrar_env_ssh ;;
        7) checkup ;;
        8) atualizar_menu ;;
        0) 
            clear
            desenhar
            sleep 1
            mensagem="👋 Obrigado por usar! Até mais!"
            pad=$(( (term_width - ${#mensagem}) / 2 ))
            printf "%*s" "$pad" ""
            echo -e "${GREEN}${mensagem}${NC}"
            exit
            ;;
        *) 
            echo -e "${RED}• ❌ Opção inválida!${NC}"
            sleep 1 
            ;;
    esac
done
