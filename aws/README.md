# Configuration AWS

## VPC

### VPC Infrastructure

- CIDR : `10.1.0.0/16`
- Subnets :
  - `10.1.1.0/24` (public — accès Internet via IGW pour Certbot, MAJ paquets)
  - `10.1.2.0/24` (privé — serveurs internes)
- Internet Gateway : oui
- Route Table : route `0.0.0.0/0 → IGW` pour le subnet public

### VPC Personnel

- CIDR : `10.2.0.0/16`
- Subnets :
  - `10.2.1.0/24` (postes Windows 10)
- Pas d'IGW (les postes sortent via la box ou un NAT selon le scénario)

### VPC Peering

Connexion `pcx-xxxxx` entre VPC Infrastructure et VPC Personnel.

**Tables de routage à mettre à jour** :
- VPC Infrastructure → ajouter route `10.2.0.0/16 → pcx-xxxxx`
- VPC Personnel → ajouter route `10.1.0.0/16 → pcx-xxxxx`

## Groupes de sécurité

### `sg-glpi`

| Type | Port | Source | Usage |
|---|---|---|---|
| HTTPS | 443 | `10.2.0.0/16` | Accès GLPI depuis VPC Personnel |
| HTTP | 80 | `0.0.0.0/0` | Renouvellement Let's Encrypt |
| SSH | 22 | IP admin | Administration |

### `sg-zabbix`

| Type | Port | Source | Usage |
|---|---|---|---|
| HTTPS | 443 | IP admin | Interface web Zabbix |
| Custom TCP | 10051 | `10.1.0.0/16`, `10.2.0.0/16` | Agents → Server |
| SSH | 22 | IP admin | Administration |

### `sg-ad`

| Type | Port | Source | Usage |
|---|---|---|---|
| RDP | 3389 | IP admin | Administration |
| DNS | 53 | `10.1.0.0/16`, `10.2.0.0/16` | Résolution domaine |
| LDAP | 389 | `10.1.0.0/16`, `10.2.0.0/16` | Authentification |
| LDAPS | 636 | `10.1.0.0/16`, `10.2.0.0/16` | Authentification chiffrée |
| Kerberos | 88 | `10.1.0.0/16`, `10.2.0.0/16` | Authentification AD |

### `sg-postes-windows`

| Type | Port | Source | Usage |
|---|---|---|---|
| WinRM | 5985 | IP serveur Ansible | Connexion Ansible |
| Zabbix Agent | 10050 | IP Zabbix Server | Supervision |

## Instances EC2

| Instance | Type | OS | Rôle |
|---|---|---|---|
| ad-srv | t3.medium | Windows Server 2019 | Active Directory |
| glpi-srv | t3.small | Debian 12 | GLPI + LAMP |
| zabbix-srv | t3.small | Debian 12 | Zabbix Server |
| ansible-srv | t2.micro | Ubuntu 22.04 | Contrôleur Ansible |
| poste-01 → poste-15 | t3.small | Windows 10 / Server 2019 | Postes utilisateurs |

> 💡 La majorité tient dans le **Free Tier** sur les 12 premiers mois en choisissant `t2.micro` quand c'est possible.

## Étapes de mise en place

1. Créer les deux VPC avec leurs subnets
2. Créer l'IGW et l'attacher au VPC Infrastructure
3. Configurer les tables de routage
4. Établir le VPC Peering et accepter la demande
5. Mettre à jour les tables de routage des deux VPC
6. Créer les groupes de sécurité
7. Lancer les instances EC2 dans les bons subnets/SG
