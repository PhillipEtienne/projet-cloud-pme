# Expression du besoin

## Contexte

Le présent projet a pour but de concevoir et mettre en place une infrastructure cloud adaptée aux besoins d'une **petite entreprise (PME)**. Il s'agit d'un **POC (Proof of Concept)** démontrant la faisabilité d'une solution technique basée sur le cloud.

L'infrastructure proposée doit notamment inclure un système de gestion des tickets hébergé sur le cloud, permettant à la PME de :

- Centraliser la gestion des demandes de support informatique
- Assurer la traçabilité des incidents et interventions
- Structurer les processus de maintenance et de suivi

## Existant

Réseau local simple basé sur une box Internet et un switch Ethernet, environ **15 postes de travail** sous Windows 10. Aucune authentification centralisée, aucun outil de ticketing, aucune supervision.

## Besoins identifiés

| Domaine | Besoin |
|---|---|
| Infrastructure | Déploiement d'une infrastructure cloud sur AWS segmentée (VPC) |
| Système de ticketing | Solution accessible via navigateur web |
| Gestion des utilisateurs | Authentification centralisée via Active Directory |
| Supervision | Surveiller l'état des instances et des services |
| Automatisation | Outil pour automatiser le déploiement, la configuration et les mises à jour |
| Sécurité | Contrôle des accès via règles de pare-feu (groupes de sécurité AWS) |
| Scalabilité | Infrastructure capable d'évoluer si le nombre de postes augmente |

## Pourquoi AWS

1. **Free Tier 12 mois** : 750h/mois d'EC2, idéal pour un POC sans coût initial
2. **Infrastructure mondiale et haute disponibilité**
3. **Flexibilité, scalabilité et tarification à la demande**

## Phasage (Gantt)

1. Initialisation
2. Conception
3. Déploiement
4. Sécurité
5. Tests
6. Documentation
7. Livraison / démo
