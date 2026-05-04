#!/usr/bin/env bash
# =============================================================================
# Script  : installation.sh
# Usage   : sudo bash installation.sh
# Objectif: Installation automatisée de Zabbix Server 7.0 sur Debian 12
# =============================================================================

set -euo pipefail

# --- Variables à adapter -----------------------------------------------------
DB_PASSWORD="${ZBX_DB_PASSWORD:-}"
if [[ -z "$DB_PASSWORD" ]]; then
    echo "❌ Définir ZBX_DB_PASSWORD avant de lancer le script :"
    echo "   export ZBX_DB_PASSWORD='un_mot_de_passe_solide'"
    exit 1
fi

# --- 1. Dépôt officiel Zabbix ------------------------------------------------
echo "→ Ajout du dépôt Zabbix"
cd /tmp
wget -q https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-1+debian12_all.deb
dpkg -i zabbix-release_7.0-1+debian12_all.deb
apt update

# --- 2. Installation des paquets --------------------------------------------
echo "→ Installation des paquets Zabbix"
DEBIAN_FRONTEND=noninteractive apt install -y \
    zabbix-server-mysql \
    zabbix-frontend-php \
    zabbix-apache-conf \
    zabbix-sql-scripts \
    zabbix-agent \
    mariadb-server

# --- 3. Base de données ------------------------------------------------------
echo "→ Création de la base de données"
mysql -u root <<SQL
CREATE DATABASE IF NOT EXISTS zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER IF NOT EXISTS 'zabbix'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
FLUSH PRIVILEGES;
SQL

echo "→ Import du schéma Zabbix (peut prendre quelques minutes)"
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | \
    mysql --default-character-set=utf8mb4 -uzabbix -p"${DB_PASSWORD}" zabbix

mysql -u root -e "SET GLOBAL log_bin_trust_function_creators = 0;"

# --- 4. Configuration --------------------------------------------------------
echo "→ Configuration de Zabbix Server"
sed -i "s/^# DBPassword=.*/DBPassword=${DB_PASSWORD}/" /etc/zabbix/zabbix_server.conf

# --- 5. Services -------------------------------------------------------------
echo "→ Démarrage des services"
systemctl restart zabbix-server zabbix-agent apache2 mariadb
systemctl enable zabbix-server zabbix-agent apache2 mariadb

echo "✅ Installation terminée."
echo "Interface web : http://<IP>/zabbix (login admin / Zabbix par défaut)"
