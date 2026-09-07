# BMX Competition Manager

A Flask web application for managing BMX championships and race events.

The application manages riders, clubs, championships, event stages, age categories, race phases, lane assignments and results through a relational SQLAlchemy data model. It also contains the competition logic used to generate race structures and advance riders between phases.

## What this project demonstrates

- Relational data modelling with SQLAlchemy
- Python backend development with Flask
- Authentication with Flask-Login
- CRUD workflows for riders, clubs and championships
- Generation of race pools and elimination phases
- Automated lane rotation / assignment
- Result entry and score aggregation
- Server-rendered HTML templates and a Bootstrap-based interface

## Tech stack

`Python` · `Flask` · `SQLAlchemy` · `Flask-SQLAlchemy` · `Flask-Login` · `SQLite` · `HTML/CSS` · `Bootstrap` · `JavaScript`

## Data model

The project uses a relational model covering users, riders, clubs, championships, stages, categories, races, heats, participations and lane rotations.

![Class diagram](docs/classes.png)

A package-level diagram is also available in [`docs/packages.png`](docs/packages.png).

## Project structure

```text
BMX/
├── .github/workflows/tests.yml
├── docs/
│   ├── classes.png
│   └── packages.png
├── source/
│   ├── app.py
│   ├── seed.py
│   └── website/
│       ├── __init__.py
│       ├── auth.py
│       ├── models.py
│       ├── views.py
│       ├── static/
│       └── templates/
├── tests/
│   └── test_smoke.py
├── .env.example
├── .gitignore
├── requirements.txt
└── requirements-dev.txt
```

## Local setup

### 1. Create a virtual environment

```bash
python -m venv .venv
```

Linux/macOS:

```bash
source .venv/bin/activate
```

Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Initialize the database

The SQLite database is created locally in `instance/bmx.db` and is intentionally excluded from Git.

Initialize the reference tables and create a local login account:

```bash
python source/seed.py --username admin --password "choose-a-local-password"
```

Do not reuse a real password here. This command is intended for a local development account.

### 4. Run the application

```bash
python source/app.py
```

Then open:

```text
http://127.0.0.1:5000
```

## Configuration

The application can be configured through environment variables:

```text
SECRET_KEY=<long-random-secret>
DATABASE_URL=<SQLAlchemy database URI>
```

If `DATABASE_URL` is omitted, the application uses a local SQLite database in the Flask instance directory. If `SECRET_KEY` is omitted, a temporary development secret is generated when the application starts.

See `.env.example` for examples. The application does not automatically load `.env`; export the variables in your shell or configure them in your deployment environment.

## Tests

Install development dependencies:

```bash
pip install -r requirements-dev.txt
```

Run:

```bash
pytest -q
```

A small GitHub Actions workflow runs the smoke test on pushes and pull requests.

## Repository hygiene and security

## Maintenance notes

This is an existing application that has been cleaned for publication rather than rewritten from scratch. Several unambiguous runtime issues from the original code were corrected, including invalid foreign-key assignments, inconsistent relationship names, plate-number validation and quarter/semi-final variable mistakes.

The competition progression code contains domain-specific rules for different rider counts. Those rules should be validated against the intended BMX competition regulations before using the application for an official event, and additional tests should be added for each participant-count boundary.

## Suggested GitHub topics

`python` `flask` `sqlalchemy` `sqlite` `relational-database` `data-modeling` `backend` `competition-management`
