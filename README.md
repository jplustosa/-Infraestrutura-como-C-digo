# Linux Infrastructure as Code

Script de automação para criação de infraestrutura de usuários, grupos, diretórios e permissões no Linux.

## 📋 Descrição

Este projeto implementa Infrastructure as Code (IaC) para automatizar a configuração inicial de sistemas Linux, criando:

- **Grupos de usuários**: GRP_ADM, GRP_VEN, GRP_SEC, GRP_DEV
- **Usuários**: 12 usuários distribuídos entre os grupos
- **Diretórios**: Estrutura organizacional com permissões específicas
- **Permissões**: Configuração de acesso baseada em grupos
- **Scripts auxiliares**: Backup automático e relatórios

## 🚀 Funcionalidades

- ✅ Criação automática de grupos e usuários
- ✅ Configuração de diretórios com permissões específicas
- ✅ Definição de proprietários e grupos
- ✅ Script de backup automático
- ✅ Tarefas agendadas (cron)
- ✅ Geração de relatório de configuração
- ✅ Validação de privilégios de root

## 🛠️ Pré-requisitos

- Sistema Linux
- Acesso root
- Bash shell

## 📥 Instalação e Uso

1. **Clone o repositório:**
```bash
git clone https://github.com/seu-usuario/linux-projeto1-iac.git
cd linux-projeto1-iac