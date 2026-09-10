# Installation

Temps nécessaire : **environ 5 minutes**, données de démonstration comprises.

## Prérequis

| Outil | Version | Vérifier |
| --- | --- | --- |
| Python | 3.10 ou supérieur | `python --version` |
| pip | fourni avec Python | `pip --version` |

Aucun serveur de base de données n'est requis : SQLite est intégré à Python.

---

## 1. Récupérer le projet

```bash
git clone https://github.com/juleescourne/bmx-competition-manager.git
cd bmx-competition-manager
```

## 2. Créer un environnement virtuel

```bash
python -m venv .venv
```

Activation selon la plateforme :

```bash
# Linux / macOS
source .venv/bin/activate
```

```powershell
# Windows PowerShell
.\.venv\Scripts\Activate.ps1
```

```cmd
:: Windows cmd.exe
.venv\Scripts\activate.bat
```

## 3. Installer les dépendances

```bash
pip install -r requirements.txt
```

Cinq paquets seulement : Flask, Flask-Login, Flask-SQLAlchemy, SQLAlchemy, Werkzeug.

## 4. Créer la base et un compte local

```bash
python source/seed.py --username admin --password "choisissez-un-mot-de-passe"
```

Cette commande crée `source/instance/bmx.db`, les 17 tables, les données de
référence (catégories d'âge, types de courses, table de brassage des couloirs) et
un compte de connexion.

> N'utilisez pas un vrai mot de passe : ce compte n'existe que sur votre machine.

La base est exclue de Git, comme tout le contenu de `instance/`.

## 5. Charger le jeu de démonstration *(recommandé)*

Sans données, l'application s'ouvre sur des écrans vides. Ce script charge un
championnat régional complet : 6 clubs normands, 60 pilotes répartis sur 6 catégories
d'âge, 1 championnat 2026 et 2 étapes.

```bash
sqlite3 source/instance/bmx.db < db/demo_data.sql
```

Si l'outil en ligne de commande `sqlite3` n'est pas installé — c'est fréquent sous
Windows — le module Python intégré fait le même travail :

```bash
python -c "import sqlite3; sqlite3.connect('source/instance/bmx.db').executescript(open('db/demo_data.sql', encoding='utf-8').read())"
```

Le script ne contient **ni compte ni empreinte de mot de passe** : les identifiants
restent créés par l'étape 4.

## 6. Lancer l'application

```bash
python source/app.py
```

Puis ouvrez <http://127.0.0.1:5000> et connectez-vous avec le compte de l'étape 4.

---

## Vérifier que tout fonctionne

```bash
pip install -r requirements-dev.txt
pytest -q
```

Vous pouvez également contrôler l'algorithme de brassage des couloirs, sur la table
de référence puis sur celle réellement chargée en base :

```bash
python scripts/verify_lane_rotation.py
python scripts/verify_lane_rotation.py --db source/instance/bmx.db
```

Les deux doivent afficher `Carré latin valide.` et sortir avec le code 0.

---

## Configuration

L'application lit deux variables d'environnement, toutes deux facultatives :

| Variable | Défaut | Rôle |
| --- | --- | --- |
| `SECRET_KEY` | secret aléatoire régénéré à chaque démarrage | signature des sessions |
| `DATABASE_URL` | `sqlite:///instance/bmx.db` | URI SQLAlchemy |

```bash
export SECRET_KEY="une-valeur-longue-et-aleatoire"
export DATABASE_URL="postgresql://user:motdepasse@localhost/bmx"
```

L'application ne lit pas `.env` automatiquement : exportez les variables dans votre
shell, ou configurez-les dans votre plateforme de déploiement. Voir `.env.example`.

> Sans `SECRET_KEY` fixe, un redémarrage invalide toutes les sessions ouvertes.
> C'est sans conséquence en développement, mais à définir pour tout déploiement.

---

## Problèmes courants

**`ModuleNotFoundError: No module named 'flask'`**
L'environnement virtuel n'est pas activé, ou les dépendances ne sont pas installées.
Reprenez les étapes 2 et 3.

**`sqlite3` n'est pas reconnu comme une commande**
Utilisez la variante Python de l'étape 5.

**`RuntimeError: The current Flask app is not registered with this 'SQLAlchemy' instance`**
Ce défaut a été corrigé : les modules importaient la base via `from .__init__ import db`,
ce qui créait deux instances SQLAlchemy distinctes. Si vous le rencontrez encore,
vous travaillez sur une version antérieure du dépôt — mettez-la à jour.

**La page se charge sans style**
Vérifiez que `source/website/static/` est complet. Les noms de fichiers sont
sensibles à la casse sous Linux, contrairement à Windows.
