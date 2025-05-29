# 🚀 Déploiement Azure App Service avec Domaine Personnalisé et SSL (via Terraform)

## 🧭 Objectif

Ce projet Terraform automatise le déploiement d’une application dans Azure App Service avec :

- Un **domaine personnalisé** (`www.myapp.com`)
- Une **zone DNS publique** gérée par Azure
- Un **certificat SSL managé**
- Un monitoring via **Azure Application Insights**

---

## 📦 Architecture

Utilisateur ↔ DNS Azure ↔ App Service Azure
↘
Certificat SSL + App Insights

![archi_pictures](screen_shots/Brainboard%20-%20azure-app-service%20(1).png)
---

## 🧱 Prérequis

- Domaine (`myapp.com`) enregistré chez un **registrar** externe (Tencent, OVH, GoDaddy, etc.)
- Accès à Azure avec permissions pour créer :
  - Zone DNS publique
  - App Service
  - Certificats SSL
  - Enregistrements DNS
- Terraform ≥ 1.3  
- Provider `azurerm` ≥ 3.x

---

## ⚙️ Étapes de déploiement

### 1. Déploiement de la zone DNS Azure

Terraform crée une **zone DNS publique** (`myapp.com`) avec :
- Enregistrement `CNAME` : `www` → `app-name.azurewebsites.net`
- Enregistrement `TXT` : `asuid.www` → ID de validation App Service

### 2. Configuration chez le registrar

> 🎯 Objectif : déléguer la gestion DNS à Azure

🔁 Remplacer les **serveurs de noms (NS)** dans le panneau de gestion du registrar par ceux donnés par Azure DNS :

ns1-06.azure-dns.com
ns2-06.azure-dns.net
ns3-06.azure-dns.org
ns4-06.azure-dns.info


### 3. Propagation DNS

⌛ Attendre que la mise à jour soit propagée globalement (10 min à 48h).  
Tester avec :

```bash
dig NS myapp.com

Résultat attendu :
myapp.com.  IN  NS  ns1-06.azure-dns.com.

🔐 Validation du Domaine & SSL

Une fois la zone active et le TXT asuid.www détecté par Azure :

Le domaine personnalisé est lié à l’App Service

Un certificat SSL gratuit est généré automatiquement

📂 Composants Terraform

Ressource Terraform	Description
azurerm_dns_zone	Zone DNS publique Azure
azurerm_dns_cname_record	Enregistrement www → App Service
azurerm_dns_txt_record	Enregistrement asuid.www pour vérification
azurerm_app_service_custom_hostname_binding	Lien entre domaine personnalisé et App
azurerm_app_service_managed_certificate	Certificat SSL automatique Azure
azurerm_app_service_certificate_binding	Liaison du certificat SSL avec le domaine
azurerm_application_insights	Monitoring


Bonnes pratiques

Ne jamais supprimer manuellement un certificat SSL géré tant que le domaine est lié.

Toujours vérifier la propagation DNS avant de faire un binding.

Éviter les zones DNS privées pour des domaines publics.

📎 Auteur
Infrastructure as Code avec Terraform + Azure

Maintenu par : ton-nom
Contact : ton-email