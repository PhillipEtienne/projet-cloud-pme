# GLPI — Système de tickets

GLPI 10.0.3 sur stack **LAMP** (Linux + Apache + MariaDB + PHP), avec authentification LDAP vers l'Active Directory et certificat TLS Let's Encrypt.

## 1. Préparation du serveur (Debian 12)

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y apache2 mariadb-server php php-mysql php-curl php-gd \
    php-intl php-ldap php-mbstring php-xml php-zip php-bz2 php-imap \
    php-apcu wget unzip
```

## 2. Configuration de la base MariaDB

```bash
sudo mysql_secure_installation
sudo mysql -u root -p
```

```sql
CREATE DATABASE glpi CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'glpi'@'localhost' IDENTIFIED BY 'CHANGE_ME';
GRANT ALL PRIVILEGES ON glpi.* TO 'glpi'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

> ⚠️ Remplacer `CHANGE_ME` et stocker le mot de passe ailleurs (gestionnaire de mots de passe). Ne jamais le commiter.

## 3. Téléchargement et installation de GLPI

```bash
cd /tmp
wget -c https://github.com/glpi-project/glpi/releases/download/10.0.3/glpi-10.0.3.tgz
tar -xzf glpi-10.0.3.tgz
sudo mv glpi /var/www/html/
sudo chown -R www-data:www-data /var/www/html/glpi
```

## 4. Configuration Apache

Copier le fichier d'exemple :

```bash
sudo cp apache/glpi.conf.example /etc/apache2/sites-available/glpi.conf
sudo nano /etc/apache2/sites-available/glpi.conf  # adapter ServerName
sudo a2ensite glpi.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
```

## 5. Achèvement de l'installation via le navigateur

Aller sur `http://<IP-DU-SERVEUR>/glpi` et suivre l'assistant. Renseigner les paramètres BDD définis à l'étape 2.

À la fin, **supprimer le fichier `install.php`** :

```bash
sudo rm /var/www/html/glpi/install/install.php
```

## 6. Sécurisation HTTPS avec Let's Encrypt

```bash
sudo apt install -y certbot python3-certbot-apache
sudo certbot --apache -d monprojetglpi.com -d www.monprojetglpi.com
```

Certbot configure automatiquement Apache et programme le renouvellement.

## 7. Liaison LDAP avec Active Directory

Dans GLPI : **Configuration → Authentification → Annuaires LDAP → +**

| Champ | Valeur |
|---|---|
| Nom | `entreprise.local` |
| Serveur | IP du DC AD |
| Port | `389` (ou `636` pour LDAPS) |
| BaseDN | `DC=entreprise,DC=local` |
| RootDN | `CN=svc_glpi_ldap,OU=IT,DC=entreprise,DC=local` |
| Mot de passe | (celui du compte de service) |
| Filtre de connexion | `(&(objectClass=user)(objectCategory=person)(sAMAccountName=%login))` |

Tester la connexion, puis importer les utilisateurs.

## 8. Profils et droits

| Profil GLPI | Droits |
|---|---|
| **Admin Sys & Réseaux** | Contrôle total |
| **Technicien** | Gestion utilisateurs + ticketing complet |
| **Utilisateur** | Création et suivi de ses propres tickets |

> 📌 Mappings groupes AD ↔ profils GLPI configurables dans **Administration → Règles d'affectation**.
