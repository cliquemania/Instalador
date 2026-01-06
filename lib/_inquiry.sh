#!/bin/bash

# Função para gerar senha aleatória
generate_password() {
  # Gera senha de 16 caracteres com letras maiúsculas, minúsculas e números
  # Evita caracteres especiais conforme orientação do instalador
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1
}

# Função para gerar JWT secrets (base64)
generate_jwt_secret() {
  # Gera secret de 32 bytes em base64 (44 caracteres)
  openssl rand -base64 32
}

get_mysql_root_password() {
  # Se gerar_senha=true, gera automaticamente em background
  if [[ "$gerar_senha" == "true" ]]; then
    mysql_root_password=$(generate_password)
    return 0
  fi

  # Se gerar_senha=false, pergunta manualmente
  print_banner
  printf "${WHITE} 💻 Insira senha para o usuario Deploy e Banco de Dados (Não utilizar caracteres especiais):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " mysql_root_password
}

get_link_git() {
  # Se já está definido no config, pergunta se deseja usar ou informar outro
  if [ -n "$link_git" ]; then
    print_banner
    printf "${WHITE} 💻 Repositório configurado no arquivo config:${GRAY_LIGHT}"
    printf "\n\n"
    printf "${GREEN} 📦 ${link_git}${GRAY_LIGHT}"
    printf "\n\n"
    printf "${WHITE} Deseja usar este repositório?${GRAY_LIGHT}"
    printf "\n\n"
    printf "   [1] Sim, usar este repositório\n"
    printf "   [2] Não, informar um novo repositório\n"
    printf "\n"
    read -p "> " opcao_repo

    case "${opcao_repo}" in
      1)
        printf "\n${GREEN} ✅ Usando repositório: ${link_git}${GRAY_LIGHT}\n\n"
        sleep 1
        return 0
        ;;
      2)
        printf "\n${WHITE} 💻 Insira o novo link do GITHUB do Whaticket:${GRAY_LIGHT}\n\n"
        read -p "> " link_git
        return 0
        ;;
      *)
        printf "\n${RED} ❌ Opção inválida! Usando repositório configurado.${GRAY_LIGHT}\n\n"
        sleep 2
        return 0
        ;;
    esac
  fi

  # Se não está definido no config, pergunta normalmente
  print_banner
  printf "${WHITE} 💻 Insira o link do GITHUB do Whaticket que deseja instalar:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " link_git
}

get_git_usuario() {
  # Se já está definido no config, não pergunta
  if [ -n "$git_usuario" ]; then
    return 0
  fi

  print_banner
  printf "${WHITE} 💻 Insira o USUARIO do GITHUB (deixe em branco se o repositório for público):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " git_usuario
}

get_git_senha() {
  # Sempre pergunta a senha por segurança (mesmo se tiver no config, ignora)
  # Se não tiver usuário definido, permite deixar em branco (repo público)
  if [ -z "$git_usuario" ]; then
    print_banner
    printf "${WHITE} 💻 Insira a SENHA ou TOKEN do GITHUB (deixe em branco se o repositório for público):${GRAY_LIGHT}"
    printf "\n\n"
    read -s -p "> " git_senha
    printf "\n"
  else
    # Se tiver usuário, a senha é obrigatória
    print_banner
    printf "${WHITE} 💻 Insira a SENHA ou TOKEN do GITHUB para o usuário '${git_usuario}':${GRAY_LIGHT}"
    printf "\n\n"
    read -s -p "> " git_senha
    printf "\n"
  fi
}

verify_git_credentials() {

  print_banner
  printf "${WHITE} 💻 Verificando credenciais do GitHub...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 1

  # Se não forneceu usuário e senha, assume que é repositório público
  if [ -z "$git_usuario" ] && [ -z "$git_senha" ]; then
    printf "${WHITE} 💻 Testando acesso ao repositório público...${GRAY_LIGHT}"
    printf "\n\n"

    # Testa se o repositório existe e é acessível
    if git ls-remote "$link_git" HEAD &>/dev/null; then
      printf "${WHITE} ✅ Repositório acessível!${GRAY_LIGHT}"
      printf "\n\n"
      sleep 2
      return 0
    else
      printf "${RED} ❌ Erro: Não foi possível acessar o repositório!${GRAY_LIGHT}"
      printf "\n"
      printf "${RED} Verifique se o link está correto ou se o repositório é privado.${GRAY_LIGHT}"
      printf "\n"
      printf "${RED} Se for privado, forneça usuário e token.${GRAY_LIGHT}"
      printf "\n\n"
      sleep 3
      return 1
    fi
  fi

  # Monta URL com credenciais para teste
  if [[ $link_git =~ ^https?:// ]]; then
    url_sem_protocolo="${link_git#https://}"
    url_sem_protocolo="${url_sem_protocolo#http://}"
    git_url_teste="https://${git_usuario}:${git_senha}@${url_sem_protocolo}"
  else
    git_url_teste="$link_git"
  fi

  # Testa as credenciais
  if git ls-remote "$git_url_teste" HEAD &>/dev/null; then
    printf "${WHITE} ✅ Credenciais válidas! Acesso ao repositório confirmado.${GRAY_LIGHT}"
    printf "\n\n"
    sleep 2
    return 0
  else
    printf "${RED} ❌ Erro: Credenciais inválidas ou repositório inacessível!${GRAY_LIGHT}"
    printf "\n"
    printf "${RED} Verifique:${GRAY_LIGHT}"
    printf "\n"
    printf "${RED} - Usuário do GitHub está correto${GRAY_LIGHT}"
    printf "\n"
    printf "${RED} - Token tem permissões de leitura do repositório${GRAY_LIGHT}"
    printf "\n"
    printf "${RED} - Link do repositório está correto${GRAY_LIGHT}"
    printf "\n\n"

    printf "${WHITE} Deseja tentar novamente? (s/n)${GRAY_LIGHT}"
    printf "\n"
    read -p "> " retry

    if [[ "$retry" == "s" || "$retry" == "S" ]]; then
      get_link_git
      get_git_usuario
      get_git_senha
      verify_git_credentials
    else
      printf "${RED} Instalação cancelada.${GRAY_LIGHT}"
      printf "\n\n"
      exit 1
    fi
  fi
}

get_instancia_add() {
  # Se já está definido no config, não pergunta
  if [ -n "$instancia_add" ]; then
    return 0
  fi

  print_banner
  printf "${WHITE} 💻 Informe um nome para a Instancia/Empresa que será instalada (Não utilizar espaços ou caracteres especiais, Utilizar Letras minusculas; ):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " instancia_add
}

generate_jwt_secrets() {
  # Gera JWT secrets silenciosamente
  jwt_secret=$(generate_jwt_secret)
  jwt_refresh_secret=$(generate_jwt_secret)
}

get_max_whats() {
  # Se já está definido no config, não pergunta
  if [ -n "$max_whats" ]; then
    return 0
  fi

  print_banner
  printf "${WHITE} 💻 Informe a Qtde de Conexões/Whats que a ${instancia_add} poderá cadastrar:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " max_whats
}

get_max_user() {
  # Se já está definido no config, não pergunta
  if [ -n "$max_user" ]; then
    return 0
  fi

  print_banner
  printf "${WHITE} 💻 Informe a Qtde de Usuarios/Atendentes que a ${instancia_add} poderá cadastrar:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " max_user
}

get_frontend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o domínio do FRONTEND/PAINEL para a ${instancia_add}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " frontend_url
}

get_backend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o domínio do BACKEND/API para a ${instancia_add}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " backend_url
}

get_frontend_port() {
  # Se já está definido no config, não pergunta
  if [ -n "$frontend_port" ]; then
    return 0
  fi

  print_banner
  printf "${WHITE} 💻 Digite a porta do FRONTEND para a ${instancia_add}; Ex: 3000 A 3999 ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " frontend_port
}


get_backend_port() {
  # Se já está definido no config, não pergunta
  if [ -n "$backend_port" ]; then
    return 0
  fi

  print_banner
  printf "${WHITE} 💻 Digite a porta do BACKEND para esta instancia; Ex: 4000 A 4999 ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " backend_port
}

get_redis_port() {
  # Se já está definido no config, não pergunta
  if [ -n "$redis_port" ]; then
    return 0
  fi

  print_banner
  printf "${WHITE} 💻 Digite a porta do REDIS/AGENDAMENTO MSG para a ${instancia_add}; Ex: 5000 A 5999 ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " redis_port
}

get_empresa_delete() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que será Deletada (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_delete
}

get_empresa_atualizar() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que deseja Atualizar (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_atualizar
}

get_empresa_bloquear() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que deseja Bloquear (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_bloquear
}

get_empresa_desbloquear() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que deseja Desbloquear (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_desbloquear
}

get_empresa_dominio() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que deseja Alterar os Dominios (Atenção para alterar os dominios precisa digitar os 2, mesmo que vá alterar apenas 1):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_dominio
}

get_alter_frontend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o NOVO domínio do FRONTEND/PAINEL para a ${empresa_dominio}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_frontend_url
}

get_alter_backend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o NOVO domínio do BACKEND/API para a ${empresa_dominio}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_backend_url
}

get_alter_frontend_port() {
  
  print_banner
  printf "${WHITE} 💻 Digite a porta do FRONTEND da Instancia/Empresa ${empresa_dominio}; A porta deve ser o mesma informada durante a instalação ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_frontend_port
}


get_alter_backend_port() {
  
  print_banner
  printf "${WHITE} 💻 Digite a porta do BACKEND da Instancia/Empresa ${empresa_dominio}; A porta deve ser o mesma informada durante a instalação ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_backend_port
}


get_urls() {
  get_mysql_root_password
  generate_jwt_secrets
  get_link_git
  get_git_usuario
  get_git_senha
  verify_git_credentials
  get_instancia_add
  get_max_whats
  get_max_user
  get_frontend_url
  get_backend_url
  get_frontend_port
  get_backend_port
  get_redis_port
}

software_update() {
  get_empresa_atualizar
  frontend_update
  backend_update
}

software_delete() {
  get_empresa_delete
  deletar_tudo
}

software_bloquear() {
  get_empresa_bloquear
  configurar_bloqueio
}

software_desbloquear() {
  get_empresa_desbloquear
  configurar_desbloqueio
}

software_dominio() {
  get_empresa_dominio
  get_alter_frontend_url
  get_alter_backend_url
  get_alter_frontend_port
  get_alter_backend_port
  configurar_dominio
}

inquiry_options() {
  
  print_banner
  printf "${WHITE} 💻 Bem vindo(a) ao Auto Instalador Whaticket SaaS, Selecione abaixo a proxima ação!${GRAY_LIGHT}"
  printf "\n\n"
  printf "   [0] Instalar whaticket\n"
  printf "   [1] Atualizar whaticket\n"
  printf "   [2] Deletar Whaticket\n"
  printf "   [3] Bloquear Whaticket\n"
  printf "   [4] Desbloquear Whaticket\n"
  printf "   [5] Alter. dominio Whaticket\n"
  printf "\n"
  read -p "> " option

  case "${option}" in
    0) get_urls ;;

    1) 
      software_update 
      exit
      ;;

    2) 
      software_delete 
      exit
      ;;
    3) 
      software_bloquear 
      exit
      ;;
    4) 
      software_desbloquear 
      exit
      ;;
    5) 
      software_dominio 
      exit
      ;;        

    *) exit ;;
  esac
}


