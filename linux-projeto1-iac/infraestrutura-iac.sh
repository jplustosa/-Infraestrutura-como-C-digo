#!/bin/bash

# Script de Infraestrutura como Código
# Criando usuários, grupos, diretórios e permissões automaticamente
# Autor: [Seu Nome]
# Data: $(date +%Y-%m-%d)

echo "=========================================="
echo "INICIANDO SCRIPT DE INFRAESTRUTURA"
echo "=========================================="

# Função para verificar se é root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Este script deve ser executado como root!" 
        exit 1
    fi
}

# Função para criar grupos
create_groups() {
    echo "Criando grupos de usuários..."
    
    declare -A groups=(
        ["GRP_ADM"]="carlos maria joao"
        ["GRP_VEN"]="debora sebastiana roberto"
        ["GRP_SEC"]="josefina amanda rogerio"
        ["GRP_DEV"]="alice bob charlie"
    )
    
    for group in "${!groups[@]}"; do
        if ! getent group "$group" > /dev/null; then
            groupadd "$group"
            echo "Grupo $group criado com sucesso!"
        else
            echo "Grupo $group já existe!"
        fi
    done
}

# Função para criar usuários
create_users() {
    echo "Criando usuários..."
    
    declare -A users_groups=(
        ["carlos"]="GRP_ADM"
        ["maria"]="GRP_ADM" 
        ["joao"]="GRP_ADM"
        ["debora"]="GRP_VEN"
        ["sebastiana"]="GRP_VEN"
        ["roberto"]="GRP_VEN"
        ["josefina"]="GRP_SEC"
        ["amanda"]="GRP_SEC"
        ["rogerio"]="GRP_SEC"
        ["alice"]="GRP_DEV"
        ["bob"]="GRP_DEV"
        ["charlie"]="GRP_DEV"
    )
    
    for user in "${!users_groups[@]}"; do
        if ! id "$user" &>/dev/null; then
            useradd "$user" -m -s /bin/bash -G "${users_groups[$user]}"
            echo "Usuário $user criado com sucesso!"
            
            # Definir senha padrão (em produção, usar senhas seguras)
            echo "$user:Senha123@" | chpasswd
            echo "Senha definida para usuário $user"
            
            # Forçar mudança de senha no primeiro login
            chage -d 0 "$user"
        else
            echo "Usuário $user já existe!"
        fi
    done
}

# Função para criar diretórios
create_directories() {
    echo "Criando diretórios..."
    
    declare -A dirs_permissions=(
        ["/publico"]="777"
        ["/adm"]="770" 
        ["/ven"]="770"
        ["/sec"]="770"
        ["/dev"]="770"
        ["/backups"]="750"
        ["/logs"]="755"
    )
    
    for dir in "${!dirs_permissions[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            echo "Diretório $dir criado com sucesso!"
        else
            echo "Diretório $dir já existe!"
        fi
        
        chmod "${dirs_permissions[$dir]}" "$dir"
        echo "Permissões ${dirs_permissions[$dir]} definidas para $dir"
    done
}

# Função para configurar permissões
set_permissions() {
    echo "Configurando permissões..."
    
    # Definir proprietários dos diretórios
    chown root:GRP_ADM /adm
    chown root:GRP_VEN /ven
    chown root:GRP_SEC /sec
    chown root:GRP_DEV /dev
    chown root:GRP_ADM /backups
    chown root:root /logs
    
    echo "Proprietários dos diretórios configurados!"
    
    # Diretório público - acesso total
    chmod 777 /publico
    echo "Diretório /publico com permissões 777"
    
    # Configurar ACLs para diretórios específicos (opcional)
    if command -v setfacl &> /dev/null; then
        setfacl -R -m g:GRP_ADM:rwx /adm
        setfacl -R -m g:GRP_VEN:rwx /ven
        setfacl -R -m g:GRP_SEC:rwx /sec
        setfacl -R -m g:GRP_DEV:rwx /dev
        echo "ACLs configuradas para os diretórios de grupo"
    fi
}

# Função para criar estrutura de arquivos de exemplo
create_example_files() {
    echo "Criando arquivos de exemplo..."
    
    # Arquivo de boas-vindas no diretório público
    cat > /publico/LEIAME.txt << EOF
Bem-vindo ao sistema!

Este diretório é público e acessível por todos os usuários.

Diretórios disponíveis:
- /publico - Acesso público
- /adm     - Administração
- /ven     - Vendas
- /sec     - Secretaria
- /dev     - Desenvolvimento
- /backups - Backups do sistema
- /logs    - Logs do sistema

Data da configuração: $(date)
EOF

    echo "Arquivo de boas-vindas criado em /publico/LEIAME.txt"
}

# Função para criar script de backup automático
create_backup_script() {
    echo "Criando script de backup..."
    
    cat > /usr/local/bin/backup_system.sh << 'EOF'
#!/bin/bash
# Script de backup automático
# Autor: Sistema de Infraestrutura

BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_$DATE.tar.gz"

echo "Iniciando backup em: $(date)"

# Criar backup dos diretórios importantes
tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
    /home \
    /etc \
    /var/log \
    /publico \
    /adm \
    /ven \
    /sec \
    /dev 2>/dev/null

if [ $? -eq 0 ]; then
    echo "Backup criado com sucesso: $BACKUP_FILE"
    
    # Manter apenas os últimos 7 backups
    find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -delete
    echo "Backups antigos removidos (mantidos apenas últimos 7 dias)"
else
    echo "Erro ao criar backup!"
    exit 1
fi

echo "Backup finalizado em: $(date)"
EOF

    chmod +x /usr/local/bin/backup_system.sh
    echo "Script de backup criado em /usr/local/bin/backup_system.sh"
}

# Função para configurar cron jobs
setup_cron_jobs() {
    echo "Configurando tarefas agendadas..."
    
    # Backup diário às 2h da manhã
    (crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup_system.sh") | crontab -
    
    # Limpeza de arquivos temporários semanal
    (crontab -l 2>/dev/null; echo "0 4 * * 0 find /publico -name "*.tmp" -delete") | crontab -
    
    echo "Tarefas agendadas configuradas!"
}

# Função para gerar relatório
generate_report() {
    echo "Gerando relatório da configuração..."
    
    REPORT_FILE="/publico/relatorio_configuracao_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$REPORT_FILE" << EOF
RELATÓRIO DE CONFIGURAÇÃO DO SISTEMA
====================================
Data: $(date)
Script: $0

USUÁRIOS CRIADOS:
$(for user in carlos maria joao debora sebastiana roberto josefina amanda rogerio alice bob charlie; do
    if id "$user" &>/dev/null; then
        echo "- $user: $(id "$user")"
    fi
done)

GRUPOS CRIADOS:
$(getent group | grep -E "GRP_ADM|GRP_VEN|GRP_SEC|GRP_DEV")

DIRETÓRIOS CRIADOS:
$(ls -ld /publico /adm /ven /sec /dev /backups /logs 2>/dev/null)

PERMISSÕES CONFIGURADAS:
$(ls -la / | grep -E "publico|adm|ven|sec|dev|backups|logs")

CONFIGURAÇÃO FINALIZADA COM SUCESSO!
EOF

    echo "Relatório gerado em: $REPORT_FILE"
}

# Função principal
main() {
    echo "Iniciando configuração automática da infraestrutura..."
    
    # Verificar privilégios de root
    check_root
    
    # Executar funções na ordem
    create_groups
    create_users
    create_directories
    set_permissions
    create_example_files
    create_backup_script
    setup_cron_jobs
    generate_report
    
    echo "=========================================="
    echo "CONFIGURAÇÃO FINALIZADA COM SUCESSO!"
    echo "=========================================="
    echo ""
    echo "Resumo da configuração:"
    echo "- Grupos criados: GRP_ADM, GRP_VEN, GRP_SEC, GRP_DEV"
    echo "- Usuários criados: 12 usuários distribuídos nos grupos"
    echo "- Diretórios criados: /publico, /adm, /ven, /sec, /dev, /backups, /logs"
    echo "- Script de backup: /usr/local/bin/backup_system.sh"
    echo "- Relatório: /publico/relatorio_configuracao_*.txt"
    echo ""
    echo "A infraestrutura está pronta para uso!"
}

# Executar função principal
main "$@"