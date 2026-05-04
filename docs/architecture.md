# Architecture cible

## Vue d'ensemble

L'infrastructure est segmentée en deux VPC AWS reliés par **VPC Peering**, ce qui permet d'isoler les serveurs des postes utilisateurs tout en autorisant les flux nécessaires (supervision, ticketing, authentification AD, déploiement Ansible).

> 🖼️ Schéma à insérer : `docs/images/architecture.png`

## Composants

### VPC Infrastructure

| Service | OS | Rôle |
|---|---|---|
| Active Directory | Windows Server 2019 | Authentification centralisée — domaine `entreprise.local` |
| GLPI | Debian 12 | Système de tickets (LAMP) |
| Zabbix Server | Debian 12 | Supervision du parc |
| Ansible | Ubuntu | Automatisation des postes Windows |

### VPC Personnel

- ~15 postes de travail Windows 10
- Joints au domaine `entreprise.local`
- Agent Zabbix installé sur chaque poste
- Cible des playbooks Ansible (déploiement logiciel, audit de conformité, MAJ Windows)

## Réseau

### VPC Peering

Connexion réseau privée entre les deux VPC permettant l'échange de trafic sans passage par Internet.

### Groupes de sécurité (ports ouverts)

| Port | Protocole | Usage |
|---|---|---|
| 443 | HTTPS | Accès des postes du VPC Personnel à GLPI |
| 5666 | TCP | Supervision Nagios/Zabbix vers les cibles |
| 3389 | RDP | Administration des serveurs Windows |
| 5985 | WinRM | Connexion Ansible vers les postes Windows |
| 53 | DNS | Résolution AD |
| 389 / 636 | LDAP / LDAPS | Authentification AD |

## Flux applicatifs

1. **Authentification** : un utilisateur du VPC Personnel se connecte à GLPI → GLPI interroge l'AD via LDAP → autorisation accordée selon les groupes
2. **Ticketing** : utilisateurs et techniciens accèdent à GLPI via HTTPS (`https://monprojetglpi.com`)
3. **Supervision** : Zabbix Server interroge les agents Zabbix sur chaque poste/serveur
4. **Automatisation** : le serveur Ansible se connecte aux postes Windows via WinRM (port 5985) pour déployer logiciels, auditer la conformité et appliquer les MAJ
