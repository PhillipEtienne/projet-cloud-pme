# Projet Cloud PME — Infrastructure AWS pour TPE/PME

> POC d'infrastructure cloud complète pour une petite entreprise, réalisé dans le cadre du **Mastère 2 Expert en Architecture des Systèmes d'Information (2023-2025)**.

Ce dépôt regroupe la documentation, les configurations et les scripts d'automatisation utilisés pour concevoir et déployer une infrastructure cloud sur AWS, intégrant **Active Directory**, **GLPI** (gestion de tickets), **Zabbix** (supervision) et **Ansible** (automatisation des postes Windows).

---

## 🎯 Objectifs

- Centraliser la gestion des demandes de support informatique
- Assurer la traçabilité des incidents et interventions
- Structurer les processus de maintenance et de suivi
- Démontrer la faisabilité d'une infrastructure cloud scalable et sécurisée pour une PME

---

## 🏗️ Architecture

L'infrastructure repose sur deux VPC AWS reliés par **VPC Peering** :

- **VPC Infrastructure** : héberge les serveurs (AD, GLPI, Zabbix, Ansible)
- **VPC Personnel** : héberge les postes de travail Windows des utilisateurs

> 📌 Voir [`docs/architecture.md`](docs/architecture.md) pour le détail (subnets, groupes de sécurité, ports ouverts, peering).

---

## 🧰 Technologies utilisées

| Catégorie | Outil |
|---|---|
| Cloud | AWS (EC2, VPC, Security Groups, VPC Peering) |
| Annuaire | Active Directory — domaine `entreprise.local` |
| Ticketing | GLPI 10.0.3 sur stack LAMP (Debian + Apache + MariaDB + PHP) |
| Supervision | Zabbix 7.0 |
| Automatisation | Ansible (postes Windows via WinRM) |
| TLS | Let's Encrypt (Certbot) |
| OS | Debian 12, Windows Server 2019, Windows 10 |

---

## 📁 Structure du dépôt

```
projet-cloud-pme/
├── docs/                       # Documentation transverse
│   ├── architecture.md         # Architecture cible détaillée
│   ├── besoins.md              # Expression du besoin
│   └── images/                 # Schémas et captures
├── aws/                        # Configuration AWS (VPC, SG, peering)
├── active-directory/           # Mise en place de l'AD
├── glpi/                       # Installation et configuration de GLPI
├── zabbix/                     # Installation et configuration de Zabbix
└── ansible/                    # Playbooks de gestion des postes Windows
    ├── ansible.cfg
    ├── inventories/
    ├── group_vars/
    └── playbooks/
```

---

## 🚀 Démarrage rapide

Chaque composant a son propre README avec les étapes détaillées :

1. **AWS** — [`aws/README.md`](aws/README.md) : créer les VPC, subnets, SG, peering
2. **Active Directory** — [`active-directory/README.md`](active-directory/README.md)
3. **GLPI** — [`glpi/README.md`](glpi/README.md)
4. **Zabbix** — [`zabbix/README.md`](zabbix/README.md)
5. **Ansible** — [`ansible/README.md`](ansible/README.md)

---

## ⚠️ Sécurité

Aucun secret (mot de passe, clé AWS, certificat) n'est versionné dans ce dépôt. Les fichiers sensibles sont fournis sous forme `*.example` et doivent être copiés/adaptés localement. Voir [`.gitignore`](.gitignore) pour la liste des exclusions.

Pour les playbooks Ansible, utiliser **`ansible-vault`** pour chiffrer les identifiants WinRM.

---

## 👤 Auteur

**Phillip Etienne** — Mastère 2 Expert en Architecture des Systèmes d'Information

---

## 📄 Licence

Ce projet est distribué sous licence MIT — voir [`LICENSE`](LICENSE).
