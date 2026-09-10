# -*- coding: utf-8 -*-
"""Vérifie que la table de brassage des couloirs est un carré latin valide.

La table `couloir` détermine à quel couloir chaque pilote part, manche après manche.
Trois propriétés doivent tenir, sinon le classement est faussé :

1. dans une manche, deux pilotes n'occupent jamais le même couloir ;
2. un pilote ne reprend jamais un couloir déjà emprunté ;
3. l'exposition aux couloirs intérieurs (1-4), avantageux au premier virage, est
   équilibrée entre tous les pilotes.

Ce script vérifie les trois, sur la table par défaut ou sur celle réellement
chargée en base.

Usage :
    python scripts/verify_lane_rotation.py
    python scripts/verify_lane_rotation.py --db source/instance/bmx.db
"""

from __future__ import annotations

import argparse
import sqlite3
import sys
from pathlib import Path

# La console Windows utilise cp1252 par défaut et ne sait pas afficher les accents :
# sans cela, le script lève UnicodeEncodeError au premier print.
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# Table de référence, identique à LANE_ROTATIONS dans source/seed.py.
DEFAULT_ROTATIONS = [
    (1, 4, 6, 3, 7),
    (2, 7, 4, 5, 8),
    (3, 6, 1, 8, 5),
    (4, 1, 7, 2, 6),
    (5, 8, 2, 7, 3),
    (6, 3, 8, 1, 4),
    (7, 2, 5, 4, 1),
    (8, 5, 3, 6, 2),
]


def load_from_database(path: Path) -> list[tuple[int, ...]]:
    """Lit les rotations réellement présentes en base."""
    connection = sqlite3.connect(path)
    rows = connection.execute(
        "SELECT couloir_1, couloir_2, couloir_3, couloir_4, couloir_5 "
        "FROM couloir ORDER BY id"
    ).fetchall()
    connection.close()
    return [tuple(row) for row in rows]


def check(rotations: list[tuple[int, ...]]) -> bool:
    if not rotations:
        print("Aucune rotation trouvée.")
        return False

    lanes = len(rotations)
    heats = len(rotations[0])
    expected = set(range(1, lanes + 1))
    ok = True

    print(f"Table : {lanes} rotations x {heats} manches\n")
    header = "  rotation | " + " ".join(f"M{k}" for k in range(1, heats + 1))
    print(header)
    print("  " + "-" * (len(header) - 2))
    for index, rotation in enumerate(rotations, 1):
        print(f"     {index}     | " + "  ".join(str(v) for v in rotation))

    print("\n1. Aucun couloir occupé deux fois dans une même manche")
    for heat in range(heats):
        column = [rotation[heat] for rotation in rotations]
        if set(column) != expected:
            missing = sorted(expected - set(column))
            print(f"   [FAIL] manche {heat + 1} : ce n'est pas une permutation "
                  f"(manquants : {missing})")
            ok = False
        else:
            print(f"   [OK]   manche {heat + 1} : permutation complète de 1..{lanes}")

    print("\n2. Aucun pilote ne reprend un couloir")
    for index, rotation in enumerate(rotations, 1):
        if len(set(rotation)) != len(rotation):
            print(f"   [FAIL] rotation {index} : couloir répété — {rotation}")
            ok = False
    if ok:
        print(f"   [OK]   les {lanes} rotations visitent {heats} couloirs distincts")

    print("\n3. Équilibre des départs intérieurs (couloirs 1-4)")
    inside_counts = []
    for index, rotation in enumerate(rotations, 1):
        inside = sum(1 for lane in rotation if lane <= lanes // 2)
        inside_counts.append(inside)
        print(f"   rotation {index} : {inside}/{heats} départs intérieurs")
    spread = max(inside_counts) - min(inside_counts)
    print(f"   -> écart entre le plus et le moins favorisé : {spread}")
    if spread > 1:
        print("   [FAIL] déséquilibre supérieur à un départ")
        ok = False
    else:
        print("   [OK]   équilibré (écart maximal d'un départ)")

    print("\n" + ("Carré latin valide." if ok else "Table INVALIDE."))
    return ok


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--db",
        type=Path,
        help="vérifier la table chargée dans cette base plutôt que la table de référence",
    )
    args = parser.parse_args()

    if args.db:
        if not args.db.exists():
            parser.error(f"{args.db} est introuvable — lancez d'abord source/seed.py")
        rotations = load_from_database(args.db)
        print(f"Source : {args.db}\n")
    else:
        rotations = DEFAULT_ROTATIONS
        print("Source : table de référence de seed.py\n")

    return 0 if check(rotations) else 1


if __name__ == "__main__":
    sys.exit(main())
