# Zabbix — Supervision

Zabbix Server 7.0 sur Debian 12 + agents déployés sur tous les postes/serveurs du parc.

## 1. Installation du serveur Zabbix

Voir le script d'installation automatisée : [`installation.sh`](installation.sh)

Étapes manuelles équivalentes :

### Ajout du dépôt officiel

```bash
wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-1+debian12_all.deb
sudo dpkg -i zabbix-release_7.0-1+debian12_all.deb
sudo apt update
```

### Installation des composants

```bash
sudo apt install -y zabbix-server-mysql zabbix-frontend-php \
    zabbix-apache-conf zabbix-sql-scripts zabbix-agent mariadb-server
```

### Configuration de la base de données

```bash
sudo mysql -u root -p
```

```sql
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'CHANGE_ME';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
FLUSH PRIVILEGES;
EXIT;
```

### Import du schéma

```bash
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -uzabbix -p zabbix
```

```sql
-- Une fois le schéma importé :
SET GLOBAL log_bin_trust_function_creators = 0;
```

### Configuration

Éditer `/etc/zabbix/zabbix_server.conf` :

```
DBPassword=CHANGE_ME
```

### Démarrage

```bash
sudo systemctl restart zabbix-server zabbix-agent apache2 mariadb
sudo systemctl enable zabbix-server zabbix-agent apache2 mariadb
```

Accès à l'interface : `http://<IP>/zabbix` — assistant de fin d'installation.

## 2. Déploiement de l'agent Zabbix sur les postes Windows

1. Télécharger l'agent MSI depuis [zabbix.com/download_agents](https://www.zabbix.com/download_agents)
2. Installer en renseignant l'IP du serveur Zabbix
3. Côté serveur : déclarer l'hôte dans **Configuration → Hosts → Create host**
4. Lier au template `Windows by Zabbix agent`

> 💡 Ce déploiement peut être automatisé via Ansible (à ajouter au playbook `install_firefox_windows.yml` ou créer un nouveau playbook).

## 3. Web scénario et alertes

- **Web scénarios** : surveiller la disponibilité de GLPI (`https://monprojetglpi.example.com`)
- **Triggers** : alerter en cas d'agent injoignable, charge CPU > 90%, espace disque < 10%
- **Actions** : envoi d'email à l'équipe support (configurer un media SMTP)
