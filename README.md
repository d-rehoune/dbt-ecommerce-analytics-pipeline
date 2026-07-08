# dbt Ecommerce Analytics Pipeline

Pipeline de transformation de données construit avec **dbt (data build tool)** pour une plateforme e-commerce. Le projet consolide les données de trois sources distinctes (base de données de ventes, Google Sheets, Google Analytics 4) et produit des modèles analytiques prêts à l'emploi pour le reporting métier, notamment le suivi des performances par account manager et par région.

## Table des matières

- [Architecture du projet](#architecture-du-projet)
- [Sources de données](#sources-de-données)
- [Structure des dossiers](#structure-des-dossiers)
- [Description des modèles](#description-des-modèles)
  - [Staging](#staging)
  - [Intermediate](#intermediate)
  - [Mart](#mart)
- [Tests](#tests)
- [Documentation](#documentation)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Utilisation](#utilisation)

## Architecture du projet

Le projet suit l'architecture en couches recommandée par dbt :

```
Sources brutes  →  Staging  →  Intermediate  →  Mart
(sales_database,     (nettoyage,   (jointures,      (agrégats
 google_sheets,       renommage,    agrégations      métier finaux,
 google_analytics_4)  typage)       intermédiaires)  prêts pour le BI)
```

- **Staging** : une vue par table source, nettoyée et renommée selon les conventions du projet, sans logique métier.
- **Intermediate** : combine et agrège les modèles de staging (matérialisés en tables pour les modèles les plus lourds).
- **Mart** : modèles finaux, matérialisés en tables, destinés à la consommation par les outils de BI.

## Sources de données

Déclarées dans [`models/sources.yml`](models/sources.yml) :

| Source | Schéma | Tables |
|---|---|---|
| `sales_database` | `sales_database` | `feedback`, `order`, `order_item`, `payment`, `product`, `seller`, `user` |
| `google_sheets` | `google_sheets` | `mapping` (correspondance état → account manager) |
| `google_analytics_4` | `google_analytics_4` | `events_20210131` (événements bruts GA4) |

## Structure des dossiers

```
dbt-ecommerce-analytics-pipeline/
├── analyses/
├── dbt_packages/
├── logs/
├── macros/
├── models/
│   ├── staging/
│   │   ├── google_analytics/
│   │   │   └── schema.yml
│   │   ├── google_sheets/
│   │   │   ├── schema.yml
│   │   │   └── stg_google_sheets__account_manager_region_mapping.sql
│   │   └── sales_database/
│   │       ├── schema.yml
│   │       ├── stg_sales_database__feedback.sql
│   │       ├── stg_sales_database__order.sql
│   │       ├── stg_sales_database__order_item.sql
│   │       ├── stg_sales_database__payment.sql
│   │       ├── stg_sales_database__product.sql
│   │       ├── stg_sales_database__seller.sql
│   │       └── stg_sales_database__user.sql
│   ├── intermediate/
│   │   ├── google_analytics/
│   │   │   ├── _int_google_analytics__session.yml
│   │   │   ├── int_google_analytics__session.md
│   │   │   └── int_google_analytics__session.sql
│   │   └── sales_database/
│   │       ├── _int_sales_database__order.yml
│   │       ├── _int_sales_database__user.yml
│   │       ├── int_sales_database__order_item.sql
│   │       ├── int_sales_database__order.md
│   │       ├── int_sales_database__order.sql
│   │       ├── int_sales_database__user_favorite_product.sql
│   │       ├── int_sales_database__user.md
│   │       └── int_sales_database__user.sql
│   ├── mart/
│   │   ├── _mrt_order_daily_report.yml
│   │   ├── mrt_order_daily_report.md
│   │   └── mrt_order_daily_report.sql
│   └── sources.yml
├── seeds/
├── snapshots/
├── target/
├── tests/
│   ├── average_feedback_score_within_valid_range.sql
│   └── total_order_amount_positive.sql
├── .gitignore
├── dbt_project.yml
└── README.md
```

## Description des modèles

### Staging

Modèles matérialisés en **vue**, un par table source, respectant la convention de nommage `stg_<source>__<table>`.

| Modèle | Description |
|---|---|
| `stg_sales_database__order` | Commandes : identifiant, statut, client associé, dates clés (création, approbation, ramassage, livraison, livraison estimée). |
| `stg_sales_database__order_item` | Lignes de commande : produit, vendeur, prix unitaire, frais de port, quantité, montant total. |
| `stg_sales_database__user` | Clients : identifiant, code postal, ville, état. |
| `stg_sales_database__product` | Produits : catégorie, dimensions, poids, nombre de photos. |
| `stg_sales_database__seller` | Vendeurs : identifiant, localisation (code postal, ville, état). |
| `stg_sales_database__payment` | Paiements : type, nombre d'échéances, montant. |
| `stg_sales_database__feedback` | Avis clients : score de satisfaction, dates d'envoi/réponse du formulaire. |
| `stg_google_sheets__account_manager_region_mapping` | Correspondance entre chaque état client et son account manager. |
| `stg_google_analytics__event_flattened` | Événements GA4 avec aplatissement des champs imbriqués (source, campagne, session, page). Matérialisé en **table**, clusterisé sur `event_name`. |

### Intermediate

Modèles combinant plusieurs sources de staging pour produire des agrégats réutilisables.

| Modèle | Description | Matérialisation |
|---|---|---|
| `int_sales_database__order` | Vue enrichie des commandes : montant total, nombre d'items (total et distincts), score de feedback moyen, ville/état du client. | table |
| `int_sales_database__user` | Vue agrégée par client : montant total dépensé, nombre total de commandes, produits distincts achetés, produit favori. | table |
| `int_sales_database__order_item` | Lignes de commande intermédiaires utilisées comme base d'agrégation. | table |
| `int_sales_database__user_favorite_product` | Calcule le produit le plus fréquemment acheté par client. | table |
| `int_google_analytics__session` | Sessions GA4 reconstituées à partir des événements, avec `unique_session_id` généré à partir de `user_pseudo_id` + `ga_session_id` (durée, pages vues, nombre d'événements, source de trafic). | table |

### Mart

| Modèle | Description | Matérialisation |
|---|---|---|
| `mrt_order_daily_report` | Rapport journalier des commandes par état et account manager : nombre total de commandes, nombre moyen d'items par commande, score de feedback moyen, montant moyen dépensé par commande. | table |

## Tests

### Tests génériques (schema tests)

Appliqués directement dans les fichiers `schema.yml`/`.yml` de chaque modèle :

- **`unique`** / **`not_null`** sur toutes les clés primaires (`order_id`, `order_item_id`, `user_id`, `product_id`, `seller_id`, `payment_id`, `feedback_id`, `unique_session_id`).
- **`relationships`** sur les clés étrangères pour garantir l'intégrité référentielle :
  - `stg_sales_database__order.user_id` → `stg_sales_database__user.user_id`
  - `stg_sales_database__order_item.order_id` → `stg_sales_database__order.order_id`
  - `stg_sales_database__payment.order_id` → `stg_sales_database__order.order_id`
  - `stg_sales_database__feedback.order_id` → `stg_sales_database__order.order_id`
- **`accepted_values`** sur `order_status`, limité aux valeurs métier valides (`created`, `shipped`, `approved`, `canceled`, `invoiced`, `delivered`, `processing`, `unavailable`).

### Tests personnalisés (singular tests)

Situés dans le dossier `tests/` :

| Fichier | Objectif |
|---|---|
| `average_feedback_score_within_valid_range.sql` | Vérifie que le score de feedback moyen calculé dans les modèles reste dans une plage de valeurs valide (ex. cohérente avec l'échelle de notation source). |
| `total_order_amount_positive.sql` | Vérifie que le montant total de chaque commande (`total_order_amount`) est toujours strictement positif. |

> Ces tests échouent si une ligne est retournée par la requête SQL — comportement standard des tests singuliers dbt.

Pour exécuter l'ensemble des tests :

```bash
dbt test
```

## Documentation

Chaque modèle dispose d'une description dans son fichier `schema.yml`, et les modèles les plus complexes bénéficient en plus d'une documentation étendue via des blocs `{% docs %}` dans des fichiers `.md` dédiés, référencés dans le YAML avec `'{{ doc("nom_du_bloc") }}'` :

- `int_sales_database__order.md`
- `int_sales_database__user.md`
- `int_google_analytics__session.md`
- `mrt_order_daily_report.md`

Le projet est configuré pour persister les descriptions directement dans les métadonnées de l'entrepôt de données (`persist_docs: relation + columns` dans `dbt_project.yml`), ce qui rend les descriptions visibles depuis des outils tiers (ex. l'explorateur de schéma de l'entrepôt).

Pour générer et consulter la documentation interactive (catalogue de modèles + graphe de dépendances/DAG) :

```bash
dbt docs generate
dbt docs serve
```

## Prérequis

- [dbt Core](https://docs.getdbt.com/docs/core/installation-overview) (ou dbt Cloud)
- Un adaptateur compatible avec votre entrepôt de données cible (BigQuery, Snowflake, etc.)
- Un fichier `profiles.yml` configuré localement avec les identifiants de connexion (non versionné, à créer dans `~/.dbt/`)

## Installation

```bash
# Cloner le dépôt
git clone https://github.com/<votre-utilisateur>/dbt-ecommerce-analytics-pipeline.git
cd dbt-ecommerce-analytics-pipeline

# Installer les dépendances éventuelles (packages dbt)
dbt deps

# Vérifier la connexion à l'entrepôt de données
dbt debug
```

## Utilisation

```bash
# Construire l'ensemble des modèles (staging → intermediate → mart)
dbt run

# Exécuter tous les tests (génériques + personnalisés)
dbt test

# Construire et tester en une seule commande
dbt build

# Ne construire qu'une couche spécifique
dbt run --select staging
dbt run --select intermediate
dbt run --select mart

# Générer et visualiser la documentation
dbt docs generate
dbt docs serve
```

## Configuration du projet

Le fichier [`dbt_project.yml`](dbt_project.yml) définit :

- La matérialisation par défaut de chaque couche (`view` pour staging et intermediate, `table` pour mart).
- Un schéma cible dédié par sous-dossier de source (`stg_sales_database`, `stg_google_sheets`, `stg_google_analytics`, `int_sales_database`, `int_google_analytics`, `mart`).
- La persistance automatique des descriptions dans l'entrepôt de données (`persist_docs`).
- Une matérialisation en `table` forcée pour les modèles intermediate de `google_analytics` (volumétrie plus importante) et pour les modèles `mart`.