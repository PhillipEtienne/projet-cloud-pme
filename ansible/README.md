# Ansible — Automatisation des postes Windows

Le contrôleur Ansible (Ubuntu, dans le VPC Infrastructure) pilote les postes Windows via **WinRM**.

## Prérequis

### Côté contrôleur (Ubuntu)

```bash
sudo apt update
sudo apt install -y python3-pip
pip3 install --user ansible pywinrm
```

Vérifier la collection Windows :

```bash
ansible-galaxy collection install ansible.windows community.windows
```

### Côté postes Windows

WinRM doit être activé. Sur chaque poste, en PowerShell admin :

```powershell
# Configuration rapide pour un POC (à durcir en production)
Enable-PSRemoting -Force
winrm quickconfig -q
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

# Ouvrir le port 5985 dans le pare-feu
New-NetFirewallRule -DisplayName "WinRM-HTTP" -Direction Inbound `
    -LocalPort 5985 -Protocol TCP -Action Allow
```

> ⚠️ En production, utiliser **HTTPS (5986)** + authentification Kerberos via le compte AD.

## Structure

```
ansible/
├── ansible.cfg
├── inventories/
│   └── inventory.yml.example       # à copier en inventory.yml
├── group_vars/
│   └── windows/
│       └── vault.yml.example       # à copier + chiffrer avec ansible-vault
└── playbooks/
    ├── audit_conformite_windows.yml
    ├── install_firefox_windows.yml
    └── update_windows.yml
```

## Configuration

1. **Inventaire** :

   ```bash
   cp inventories/inventory.yml.example inventories/inventory.yml
   # éditer inventories/inventory.yml avec les vraies IP
   ```

2. **Vault** (identifiants chiffrés) :

   ```bash
   cp group_vars/windows/vault.yml.example group_vars/windows/vault.yml
   ansible-vault encrypt group_vars/windows/vault.yml
   ```

   Le mot de passe du vault sera demandé à chaque exécution (ou stocké dans un fichier référencé par `ansible.cfg`, **non versionné**).

3. **Test de connectivité** :

   ```bash
   ansible -i inventories/inventory.yml windows -m win_ping --ask-vault-pass
   ```

## Playbooks disponibles

| Playbook | Description |
|---|---|
| `audit_conformite_windows.yml` | Audit de l'état de santé : hostname, OS, disque, RAM, CPU, dernier boot, Windows Update, Defender |
| `install_firefox_windows.yml` | Déploiement de Mozilla Firefox via Chocolatey |
| `update_windows.yml` | Recherche, application des MAJ Windows et redémarrage si nécessaire |

## Lancement

```bash
# Audit
ansible-playbook -i inventories/inventory.yml playbooks/audit_conformite_windows.yml --ask-vault-pass

# Déploiement Firefox
ansible-playbook -i inventories/inventory.yml playbooks/install_firefox_windows.yml --ask-vault-pass

# Mises à jour Windows
ansible-playbook -i inventories/inventory.yml playbooks/update_windows.yml --ask-vault-pass
```
