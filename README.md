<div align="center">

<img 
    align="center" 
    alt="GHub Logo"
    title="Ghub Logo" 
    width="300px" 
    style="padding-right: 10px;" 
    src="https://iili.io/FOBhYUF.png" alt="logo">

<h1>G-Hub — GitHub Termux Manager</h1>

**Menu interativo para gerenciamento completo do GitHub no Termux.**

</div>

<div align="center">

[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/)
[![Termux](https://img.shields.io/badge/Termux-%23363636.svg?style=for-the-badge&logoColor=white)](https://github.com/termux/termux-app)
[![Bash Script](https://img.shields.io/badge/bash_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://github.com/topics/bash-script)

![License](https://img.shields.io/github/license/Shazanxz/G-Hub.svg)

![Android](https://img.shields.io/badge/Desenvolvido_Em_Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

</div>

## 📖 Sobre

O **G-Hub — GitHub Termux Manager** é um utilitário escrito em Bash que transforma o uso do Git e GitHub no Termux em algo muito mais fácil, rápido e organizado.  
Com uma interface em menu interativo, o G-Hub elimina a necessidade de memorizar comandos complexos ou lidar com configurações manuais.

Você pode gerenciar repositórios, arquivos, commits, autenticações SSH, tokens e ainda realizar um check-up do ambiente — tudo a partir de um único script.  

Ideal para quem trabalha com desenvolvimento no Android, usando Termux como terminal.

---

## ✨ Funcionalidades

- Configurar credenciais do GitHub e salvar em `.env` (nome, e-mail, usuário, token e chave SSH)
- Detectar ou gerar automaticamente chave SSH, com instruções para adicioná-la no GitHub
- Criar repositórios no GitHub (público ou privado)
- Enviar arquivos ou pastas para qualquer repositório GitHub
- Criar e enviar arquivos padrão como `README.md` e `LICENSE` (MIT)
- Visualizar as informações salvas em `.env` e a chave SSH
- Check-up completo do ambiente: Git, GitHub CLI, autenticação e SSH

---

## 🖼️ Imagem:
[![Code-x-DCgjcxy-PZ.png](https://i.postimg.cc/CxDsDcTP/Code-x-DCgjcxy-PZ.png)](https://postimg.cc/DSvG3dzL)

---

## 🖥️ Instalação

```pkg upgrade && update```

```pkg install git```

```git clone https://github.com/Shazanxz/G-Hub.git```

```cd G-Hub```

```bash ghub.sh```

---

## 📦 Dependências

O próprio menu já instala automaticamente todas as dependências necessárias;
> Entre elas estão: git, openssh, gh (GitHub CLI), curl, wget, nano, vim, unzip, tar, bash, zsh e outros.

Caso queira rodar manualmente:

```pkg install -y git openssh gh curl wget nano vim unzip tar bash zsh```


---


<div align="center">

![Dev](https://img.shields.io/badge/Desenvolvido_por:-Shazanxz-ED1C24?style=for-the-badge&logoColor=white)

</div>
