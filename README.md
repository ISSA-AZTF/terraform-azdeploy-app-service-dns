# Déploiement Azure App Service avec Domaine Personnalisé 
Ce guide Terraform configure un App Service Azure qui héberge un simple conteneur Docker `hello world`.

Il crée également une zone DNS publique dans Azure (ex. : `myapp.com`) avec un enregistrement `CNAME` et un enregistrement `TXT` pour préparer l'ajout d’un domaine personnalisé.

## Ce que fait ce guide

- Déploie un App Service Linux basé sur un conteneur Docker
- Crée une zone DNS publique dans Azure (myapp.com)
- Ajoute un enregistrement CNAME pour `www.myapp.com` pointant vers l’App Service
- Ajoute un enregistrement TXT `asuid.www` pour vérification du domaine
- Tente d’associer le domaine personnalisé à l’App Service
- Provisione un certificat SSL managé (si les enregistrements DNS sont détectés)

## Architecture
Ceci représente l'architecture de l'infra provisionnée via terraform :

![archi_infra](screen_shots/archi.png)

## Déploiment Infrastructure

     terraform init
     terraform plan -out myplan.plan
     terraform apply myplan.plan

![Deploy_infra](screen_shots/Infra.png)

## Limite actuelle

Le domaine `myapp.com` n’est pas enregistré auprès d’un registrar ou acquis via `azure app service domains`. 

Par conséquent, même si la zone DNS existe dans Azure, elle n’est pas utilisée publiquement. Aucun serveur DNS public ne connaît cette zone.

En résumé : le domaine n’est pas routable sur Internet tant qu’il n’est pas acheté et délégué.

## Délégation DNS : comment faire d’Azure l'autorité pour votre domaine

`(Suppose que la zone DNS myapp.com a déjà été créée dans Azure DNS)`

1. Acheter le domaine `myapp.com` chez un registrar (ex : OVH, Gandi, GoDaddy, Azure Domains…)
2. Remplacer les serveurs de noms (NS) par ceux fournis par Azure :
 - ns1-06.azure-dns.com

 - ns2-06.azure-dns.net

 - ns3-06.azure-dns.org

 - ns4-06.azure-dns.info
3. Attendre la propagation DNS (Quelques minutes à 48h)
4. Vérifier avec `dig` ou `nslookup` que les enregistrements CNAME et TXT sont accessibles
5. Relancer le déploiement ou le binding du domaine si nécessaire

## Destruction Infrastructure

      terraform destroy

![Destruction_infra](screen_shots/destruction_ressources.png)

## Conclusion

Ce setup Terraform fonctionne avec un vrai domaine, mais `www.myapp.com` ne sera public que lorsque le domaine sera acheté et correctement délégué.