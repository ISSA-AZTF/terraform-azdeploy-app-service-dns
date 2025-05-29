# Déploiement Azure App Service avec Domaine Personnalisé (Zone DNS uniquement)

Ce projet Terraform configure un App Service Azure qui héberge un conteneur Docker.

Il crée également une zone DNS publique dans Azure (ex. : `myapp.com`) avec un enregistrement `CNAME` et un enregistrement `TXT` pour préparer l'ajout d’un domaine personnalisé.

## Ce que fait le projet

- Déploie un App Service Linux basé sur un conteneur Docker
- Crée une zone DNS publique dans Azure (myapp.com)
- Ajoute un enregistrement CNAME pour www.myapp.com pointant vers l’App Service
- Ajoute un enregistrement TXT asuid.www.myapp.com pour vérification du domaine
- Tente d’associer le domaine personnalisé à l’App Service
- Provisione un certificat SSL managé (si les enregistrements DNS sont détectés)

## Limite actuelle

Le domaine `myapp.com` n’est pas enregistré auprès d’un registrar. Par conséquent, même si la zone DNS existe dans Azure, elle n’est pas utilisée publiquement. Aucun serveur DNS public ne connaît cette zone.

En résumé : le domaine n’est pas routable sur Internet tant qu’il n’est pas acheté et délégué.

## Étapes nécessaires pour activer réellement le domaine

1. Acheter le domaine `myapp.com` chez un registrar (ex : OVH, Gandi, GoDaddy, Azure Domains…)
2. Aller dans les paramètres DNS du registrar
3. Remplacer les serveurs de noms (NS) par ceux fournis par Azure :

