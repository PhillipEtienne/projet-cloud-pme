# Active Directory

## Configuration

- **Domaine** : `entreprise.local`
- **Contrôleur de domaine** : `ad-srv` (Windows Server 2019)
- **Niveau fonctionnel** : Windows Server 2019

## Mise en place

### 1. Promotion en contrôleur de domaine

```powershell
# Installation du rôle AD DS
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

# Promotion en contrôleur de domaine (nouvelle forêt)
Install-ADDSForest `
    -DomainName "entreprise.local" `
    -DomainNetbiosName "ENTREPRISE" `
    -InstallDns:$true `
    -Force:$true
```

Le serveur redémarre automatiquement à la fin.

### 2. Unités d'organisation (OU)

Structure recommandée :

```
entreprise.local/
├── OU=Personnel
├── OU=IT
│   ├── OU=Admins
│   └── OU=Techniciens
└── OU=Postes
```

### 3. Groupes utilisés par GLPI

| Groupe AD | Rôle GLPI |
|---|---|
| `GLPI_Admins` | Administrateurs (contrôle total) |
| `GLPI_Techniciens` | Techniciens support |
| `GLPI_Utilisateurs` | Utilisateurs finaux |

### 4. Compte de service pour la liaison LDAP

Créer un compte dédié `svc_glpi_ldap` (mot de passe long, jamais expirant, droits de lecture sur l'annuaire). Ce compte est utilisé par GLPI pour interroger l'AD — voir `glpi/README.md`.

## Jonction des postes au domaine

```powershell
# Sur chaque poste Windows 10 (en admin)
Add-Computer -DomainName "entreprise.local" -Restart
```

## Vérifications

```powershell
# Sur le DC
Get-ADDomain
Get-ADUser -Filter * | Select Name, SamAccountName

# Depuis un poste joint
nltest /sc_query:entreprise.local
```
