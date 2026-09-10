"""Initialize reference data and optionally create a local application user."""

import argparse

from werkzeug.security import generate_password_hash

from website import create_app, db
from website.models import (
    Categorie_type,
    Championnat_type,
    Couloir,
    Race_type,
    Sexe,
    User,
)


SEXES = ("Homme", "Femme")

CATEGORIES = (
    (0, 6, "6 ans et moins"),
    (7, 8, "7/8 ans"),
    (9, 10, "9/10 ans"),
    (11, 12, "11/12 ans"),
    (13, 14, "13/14 ans"),
    (15, 16, "15/16 ans"),
    (17, 24, "17/24 ans"),
    (25, 40, "25/40 ans"),
    (41, 99999, "41 ans et plus"),
)

CHAMPIONSHIP_TYPES = (
    ("Régional", 5),
    ("Départemental", 4),
)

RACE_TYPES = ("Pool", "1/4 Finale", "1/2 Finale", "Finale")

LANE_ROTATIONS = (
    (1, 4, 6, 3, 7),
    (2, 7, 4, 5, 8),
    (3, 6, 1, 8, 5),
    (4, 1, 7, 2, 6),
    (5, 8, 2, 7, 3),
    (6, 3, 8, 1, 4),
    (7, 2, 5, 4, 1),
    (8, 5, 3, 6, 2),
)


def seed_reference_data():
    for denomination in SEXES:
        if not Sexe.query.filter_by(denomination=denomination).first():
            db.session.add(Sexe(denomination=denomination))

    for min_age, max_age, name in CATEGORIES:
        if not Categorie_type.query.filter_by(name=name).first():
            db.session.add(Categorie_type(min_age=min_age, max_age=max_age, name=name))

    for championship_type, max_steps in CHAMPIONSHIP_TYPES:
        if not Championnat_type.query.filter_by(type=championship_type).first():
            db.session.add(
                Championnat_type(type=championship_type, nb_etapes_max=max_steps)
            )

    for race_type in RACE_TYPES:
        if not Race_type.query.filter_by(type=race_type).first():
            db.session.add(Race_type(type=race_type))

    if Couloir.query.count() == 0:
        for rotation in LANE_ROTATIONS:
            db.session.add(
                Couloir(
                    couloir_1=rotation[0],
                    couloir_2=rotation[1],
                    couloir_3=rotation[2],
                    couloir_4=rotation[3],
                    couloir_5=rotation[4],
                )
            )

    db.session.commit()


def create_or_update_user(username, password):
    user = User.query.filter_by(username=username).first()
    password_hash = generate_password_hash(password)

    if user:
        user.password = password_hash
    else:
        db.session.add(User(username=username, password=password_hash))

    db.session.commit()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--username", help="Create or update a local login user")
    parser.add_argument("--password", help="Password for --username")
    args = parser.parse_args()

    if bool(args.username) != bool(args.password):
        parser.error("--username and --password must be provided together")

    app = create_app()
    with app.app_context():
        seed_reference_data()
        if args.username:
            create_or_update_user(args.username, args.password)
            print(f"Reference data initialized. User '{args.username}' is ready.")
        else:
            print("Reference data initialized.")


if __name__ == "__main__":
    main()
