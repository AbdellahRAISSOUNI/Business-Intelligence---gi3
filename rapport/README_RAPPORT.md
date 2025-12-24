# Rapport LaTeX - Instructions de Compilation

## Structure du Rapport

Le fichier principal est `Rapport_Projet_BI.tex`. Il contient un rapport académique complet en français.

## Images Requises

Le rapport fait référence aux images suivantes qui doivent être placées dans le dossier `rapport/images/` :

### Architecture et Conception
1. **architecture_globale.png** - Diagramme de l'architecture globale du système
2. **etl_process.png** - Diagramme du processus ETL
3. **schema_operational.png** - Schéma relationnel de la base opérationnelle
4. **dimensions_shared.png** - Diagramme des dimensions partagées

### Data Marts
5. **datamart_consumption.png** - Schéma en étoile du Data Mart Consommation
6. **datamart_economic.png** - Schéma en étoile du Data Mart Économique
7. **datamart_environmental.png** - Schéma en étoile du Data Mart Environnemental

### Processus ETL
8. **pdi_json_extraction.png** - Capture d'écran de la transformation PDI d'extraction JSON
9. **load_dim_region.png** - Capture d'écran du chargement de dim_region
10. **fact_consumption_loading.png** - Diagramme du processus de chargement fact_energy_consumption
11. **fact_economic_loading.png** - Capture d'écran du chargement fact_economic
12. **etl_job.png** - Capture d'écran du job PDI principal

### Automatisation
13. **batch_script.png** - Extrait du script batch
14. **task_scheduler.png** - Configuration du Planificateur de tâches

### Reporting
15. **powerbi_connection.png** - Configuration de la connexion Power BI
16. **powerbi_model.png** - Vue du modèle de données dans Power BI
17. **dashboard_consumption.png** - Tableau de bord Consommation
18. **dashboard_economic.png** - Tableau de bord Économique
19. **dashboard_environmental.png** - Tableau de bord Environnemental
20. **dashboard_overview.png** - Tableau de bord Vue d'ensemble
21. **dashboard_interactivity.png** - Démonstration de l'interactivité

## Comment Obtenir les Images

### Diagrammes d'Architecture
- Créer des diagrammes avec des outils comme :
  - Draw.io / diagrams.net
  - Lucidchart
  - Microsoft Visio
  - Ou même PowerPoint exporté en PNG haute résolution

### Schémas de Base de Données
- Utiliser MySQL Workbench pour exporter les schémas ER
- Ou créer des diagrammes avec des outils de modélisation

### Captures d'Écran PDI
- Prendre des captures d'écran des transformations PDI ouvertes dans Spoon
- Utiliser l'outil de capture Windows (Win + Shift + S)
- Sauvegarder en PNG avec bonne résolution (minimum 1920x1080 recommandé)

### Captures Power BI
- Prendre des captures d'écran des tableaux de bord dans Power BI Desktop
- Utiliser "File > Export > Export to PDF" puis convertir en images si nécessaire
- Ou utiliser l'outil de capture pour des vues spécifiques

## Compilation LaTeX

### Prérequis

Installer une distribution LaTeX complète :
- **Windows** : MiKTeX ou TeX Live
- **Linux** : TeX Live
- **Mac** : MacTeX

### Compilation

Ouvrir un terminal dans le dossier `rapport/` et exécuter :

```bash
pdflatex Rapport_Projet_BI.tex
pdflatex Rapport_Projet_BI.tex  # Deuxième passe pour les références
```

Ou utiliser un éditeur LaTeX comme :
- **TeXstudio**
- **Overleaf** (en ligne)
- **TeXmaker**
- **Visual Studio Code** avec extension LaTeX

### Compilation avec BibTeX (si nécessaire)

Si vous ajoutez des références bibliographiques avec BibTeX :

```bash
pdflatex Rapport_Projet_BI.tex
bibtex Rapport_Projet_BI
pdflatex Rapport_Projet_BI.tex
pdflatex Rapport_Projet_BI.tex
```

## Structure du Dossier

```
rapport/
├── Rapport_Projet_BI.tex          # Fichier principal LaTeX
├── README_RAPPORT.md              # Ce fichier
└── images/                        # Dossier pour les images
    ├── architecture_globale.png
    ├── etl_process.png
    ├── schema_operational.png
    └── ... (toutes les autres images)
```

## Personnalisation

### Modifier les Auteurs

Dans le fichier `.tex`, ligne ~87-91 :

```latex
\textbf{Auteurs:}\\
Raissouni Abdellah\\
Bencaid Mouad
```

### Modifier la Date

Ligne ~110 :

```latex
{\large Janvier 2025}
```

### Ajouter des Sections

Le document utilise la classe `report` avec des `\chapter{}` pour les sections principales et `\section{}` pour les sous-sections.

## Conseils pour les Images

1. **Résolution** : Minimum 300 DPI pour une qualité d'impression
2. **Format** : PNG recommandé pour les diagrammes, JPG acceptables pour les captures d'écran
3. **Taille** : Optimiser la taille des fichiers pour un PDF raisonnable
4. **Lisibilité** : S'assurer que le texte dans les images est lisible à la taille d'affichage

## Résolution des Problèmes

### Erreur "File not found" pour les images

Vérifier que :
- Les images sont dans le dossier `images/`
- Les noms de fichiers correspondent exactement (sensible à la casse)
- Les extensions sont correctes (.png, .jpg, etc.)

### Erreurs de compilation LaTeX

- Vérifier que tous les packages nécessaires sont installés
- Compiler plusieurs fois si nécessaire pour résoudre les références croisées
- Vérifier les logs d'erreur LaTeX pour plus de détails

### Problèmes d'encodage

Le document utilise UTF-8. Si vous avez des problèmes avec les caractères accentués :
- Vérifier que votre éditeur sauvegarde en UTF-8
- Utiliser `\usepackage[utf8]{inputenc}` (déjà inclus)

## Génération du PDF Final

Après compilation réussie, vous obtiendrez :
- `Rapport_Projet_BI.pdf` - Le rapport final prêt à être remis

Assurez-vous de :
1. Vérifier que toutes les images sont présentes et visibles
2. Vérifier que les numéros de page, table des matières, etc. sont corrects
3. Faire une relecture complète du contenu

