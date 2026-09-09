-- ============================================================================
-- demo_data.sql — schéma + jeu de démonstration
--
-- Crée les 17 tables si elles n'existent pas, puis charge un championnat
-- régional normand complet : 6 clubs, 60 pilotes répartis sur 6 catégories
-- d'âge, 1 championnat 2026 et 2 étapes.
--
-- Ce script ne crée AUCUN compte utilisateur : aucun mot de passe ni hash
-- n'est versionné. Crée ton compte local avec seed.py (voir README).
--
-- Il ne pré-remplit pas non plus les courses : c'est l'application qui les
-- génère depuis l'écran Catégories, et elle efface toute structure existante
-- à chaque validation. Charger des courses ici ne servirait donc à rien.
--
-- Usage :
--   python source/seed.py --username admin --password "..."
--   sqlite3 source/instance/bmx.db < db/demo_data.sql
-- ============================================================================

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------------
-- 1. Schéma
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS categorie (
	id INTEGER NOT NULL, 
	etape_id INTEGER NOT NULL, 
	categorie_type_id INTEGER NOT NULL, 
	pool_finie BOOLEAN, 
	quart_finie BOOLEAN, 
	demi_finie BOOLEAN, 
	finale_finie BOOLEAN, 
	quart_genere BOOLEAN, 
	demi_genere BOOLEAN, 
	finale_genere BOOLEAN, 
	finie BOOLEAN, 
	PRIMARY KEY (id), 
	FOREIGN KEY(etape_id) REFERENCES etape (id), 
	FOREIGN KEY(categorie_type_id) REFERENCES categorie_type (id)
);

CREATE TABLE IF NOT EXISTS categorie_type (
	id INTEGER NOT NULL, 
	min_age INTEGER NOT NULL, 
	max_age INTEGER NOT NULL, 
	name VARCHAR(100) NOT NULL, 
	PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS championnat (
	id INTEGER NOT NULL, 
	championnat_type_id INTEGER NOT NULL, 
	annee INTEGER NOT NULL, 
	finie BOOLEAN, 
	PRIMARY KEY (id), 
	FOREIGN KEY(championnat_type_id) REFERENCES championnat_type (id)
);

CREATE TABLE IF NOT EXISTS championnat_type (
	id INTEGER NOT NULL, 
	type VARCHAR(50) NOT NULL, 
	nb_etapes_max INTEGER NOT NULL, 
	PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS club (
	id INTEGER NOT NULL, 
	ville VARCHAR(100) NOT NULL, 
	initiales VARCHAR(5) NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (ville), 
	UNIQUE (initiales)
);

CREATE TABLE IF NOT EXISTS couloir (
	id INTEGER NOT NULL, 
	couloir_1 INTEGER, 
	couloir_2 INTEGER, 
	couloir_3 INTEGER, 
	couloir_4 INTEGER, 
	couloir_5 INTEGER, 
	PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS etape (
	id INTEGER NOT NULL, 
	championnat_id INTEGER NOT NULL, 
	lieu_id INTEGER NOT NULL, 
	finie BOOLEAN, 
	PRIMARY KEY (id), 
	FOREIGN KEY(championnat_id) REFERENCES championnat (id), 
	FOREIGN KEY(lieu_id) REFERENCES club (id)
);

CREATE TABLE IF NOT EXISTS manche (
	id INTEGER NOT NULL, 
	race_id INTEGER NOT NULL, 
	finie BOOLEAN, 
	PRIMARY KEY (id), 
	FOREIGN KEY(race_id) REFERENCES race (id)
);

CREATE TABLE IF NOT EXISTS participant_categorie (
	id INTEGER NOT NULL, 
	titulaire_id INTEGER NOT NULL, 
	categorie_id INTEGER NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(titulaire_id) REFERENCES titulaire (id), 
	FOREIGN KEY(categorie_id) REFERENCES categorie (id)
);

CREATE TABLE IF NOT EXISTS participant_etape (
	id INTEGER NOT NULL, 
	titulaire_id INTEGER NOT NULL, 
	etape_id INTEGER NOT NULL, 
	categorie_type_id INTEGER NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(titulaire_id) REFERENCES titulaire (id), 
	FOREIGN KEY(etape_id) REFERENCES etape (id), 
	FOREIGN KEY(categorie_type_id) REFERENCES categorie_type (id)
);

CREATE TABLE IF NOT EXISTS participant_manche (
	id INTEGER NOT NULL, 
	titulaire_id INTEGER NOT NULL, 
	manche_id INTEGER NOT NULL, 
	place_depart INTEGER, 
	resultat INTEGER, 
	PRIMARY KEY (id), 
	FOREIGN KEY(titulaire_id) REFERENCES titulaire (id), 
	FOREIGN KEY(manche_id) REFERENCES manche (id)
);

CREATE TABLE IF NOT EXISTS participant_race (
	id INTEGER NOT NULL, 
	titulaire_id INTEGER NOT NULL, 
	race_id INTEGER NOT NULL, 
	couloir_id INTEGER NOT NULL, 
	resultat INTEGER, 
	PRIMARY KEY (id), 
	FOREIGN KEY(titulaire_id) REFERENCES titulaire (id), 
	FOREIGN KEY(race_id) REFERENCES race (id), 
	FOREIGN KEY(couloir_id) REFERENCES couloir (id)
);

CREATE TABLE IF NOT EXISTS race (
	id INTEGER NOT NULL, 
	name VARCHAR(1) NOT NULL, 
	etape_id INTEGER NOT NULL, 
	categorie_type_id INTEGER NOT NULL, 
	race_type_id INTEGER NOT NULL, 
	categorie_id INTEGER NOT NULL, 
	finie BOOLEAN, 
	PRIMARY KEY (id), 
	FOREIGN KEY(etape_id) REFERENCES etape (id), 
	FOREIGN KEY(categorie_type_id) REFERENCES categorie_type (id), 
	FOREIGN KEY(race_type_id) REFERENCES race_type (id), 
	FOREIGN KEY(categorie_id) REFERENCES categorie (id)
);

CREATE TABLE IF NOT EXISTS race_type (
	id INTEGER NOT NULL, 
	type VARCHAR(50) NOT NULL, 
	PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS sexe (
	id INTEGER NOT NULL, 
	denomination VARCHAR(20) NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (denomination)
);

CREATE TABLE IF NOT EXISTS titulaire (
	id INTEGER NOT NULL, 
	nom VARCHAR(100) NOT NULL, 
	prenom VARCHAR(100) NOT NULL, 
	date_naissance DATE NOT NULL, 
	numero_plaque VARCHAR(2) NOT NULL, 
	club_id INTEGER NOT NULL, 
	sexe_id INTEGER NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(club_id) REFERENCES club (id), 
	FOREIGN KEY(sexe_id) REFERENCES sexe (id)
);

CREATE TABLE IF NOT EXISTS user (
	id INTEGER NOT NULL, 
	username VARCHAR(100) NOT NULL, 
	password VARCHAR(255) NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (username)
);

-- ---------------------------------------------------------------------------
-- 2. Remise à zéro des données de démonstration
--    Ordre inverse des dépendances. Les tables de référence et 'user' sont
--    laissées intactes.
-- ---------------------------------------------------------------------------

DELETE FROM participant_manche;
DELETE FROM manche;
DELETE FROM participant_race;
DELETE FROM race;
DELETE FROM participant_categorie;
DELETE FROM categorie;
DELETE FROM participant_etape;
DELETE FROM etape;
DELETE FROM championnat;
DELETE FROM titulaire;
DELETE FROM club;

-- ---------------------------------------------------------------------------
-- 3. Données de référence (idempotent — seed.py les crée déjà)
-- ---------------------------------------------------------------------------

INSERT OR IGNORE INTO sexe (id, denomination) VALUES (1, 'Homme'), (2, 'Femme');

INSERT OR IGNORE INTO categorie_type (id, min_age, max_age, name) VALUES
    (1, 0, 6, '6 ans et moins'),
    (2, 7, 8, '7/8 ans'),
    (3, 9, 10, '9/10 ans'),
    (4, 11, 12, '11/12 ans'),
    (5, 13, 14, '13/14 ans'),
    (6, 15, 16, '15/16 ans'),
    (7, 17, 24, '14/24 ans'),
    (8, 25, 40, '25/40 ans'),
    (9, 41, 99999, '41 ans et plus');

INSERT OR IGNORE INTO championnat_type (id, type, nb_etapes_max) VALUES
    (1, 'Régional', 5),
    (2, 'Départemental', 4);

INSERT OR IGNORE INTO race_type (id, type) VALUES
    (1, 'Pool'),
    (2, '1/4 Finale'),
    (3, '1/2 Finale'),
    (4, 'Finale');

-- Rotation des couloirs : chaque ligne est la suite de couloirs d'un pilote
-- sur les 5 manches, pour que personne ne garde le même couloir.
INSERT OR IGNORE INTO couloir (id, couloir_1, couloir_2, couloir_3, couloir_4, couloir_5) VALUES
    (1, 1, 4, 6, 3, 7),
    (2, 2, 7, 4, 5, 8),
    (3, 3, 6, 1, 8, 5),
    (4, 4, 1, 7, 2, 6),
    (5, 5, 8, 2, 7, 3),
    (6, 6, 3, 8, 1, 4),
    (7, 7, 2, 5, 4, 1),
    (8, 8, 5, 3, 6, 2);

-- ---------------------------------------------------------------------------
-- 4. Clubs
-- ---------------------------------------------------------------------------

INSERT INTO club (id, ville, initiales) VALUES
    (1, 'Rouen', 'ROU'),
    (2, 'Le Havre', 'LEH'),
    (3, 'Évreux', 'EVR'),
    (4, 'Dieppe', 'DIE'),
    (5, 'Caen', 'CAE'),
    (6, 'Louviers', 'LOU');

-- ---------------------------------------------------------------------------
-- 5. Pilotes
--    Les dates de naissance sont calées sur l'année 2026 : l'application déduit
--    la catégorie par (année du championnat - année de naissance).
-- ---------------------------------------------------------------------------

INSERT INTO titulaire (id, nom, prenom, date_naissance, numero_plaque, club_id, sexe_id) VALUES
    (1, 'Bréard', 'Noah', '2016-08-28', '58', 5, 1),
    (2, 'Postel', 'Timéo', '2016-10-07', '81', 5, 1),
    (3, 'Duval', 'Maël', '2016-03-04', '19', 1, 1),
    (4, 'Osmont', 'Nathan', '2016-09-26', '77', 4, 1),
    (5, 'Pichon', 'Théo', '2016-08-21', '80', 1, 1),
    (6, 'Marchand', 'Nathan', '2016-09-03', '25', 2, 1),
    (7, 'Quesnel', 'Sarah', '2016-10-01', '42', 4, 2),
    (8, 'Vasseur', 'Romane', '2016-10-27', '82', 3, 2),
    (9, 'Levasseur', 'Chloé', '2016-08-01', '59', 6, 2),
    (10, 'Bréard', 'Chloé', '2016-05-14', '91', 3, 2),
    (11, 'Gosselin', 'Maël', '2014-06-25', '4', 1, 1),
    (12, 'Leroy', 'Baptiste', '2014-10-25', '14', 3, 1),
    (13, 'Lefebvre', 'Lucas', '2014-07-03', '28', 2, 1),
    (14, 'Cauchy', 'Baptiste', '2014-01-16', '54', 1, 1),
    (15, 'Vasseur', 'Gabin', '2014-10-21', '44', 1, 1),
    (16, 'Lefebvre', 'Émile', '2014-05-11', '98', 1, 1),
    (17, 'Osmont', 'Enzo', '2014-03-08', '2', 1, 1),
    (18, 'Renault', 'Ambre', '2014-08-26', '88', 5, 2),
    (19, 'Lecomte', 'Alice', '2014-04-15', '94', 2, 2),
    (20, 'Cauchy', 'Jade', '2014-07-21', '51', 4, 2),
    (21, 'Delaunay', 'Camille', '2014-04-01', '3', 2, 2),
    (22, 'Tessier', 'Jade', '2014-03-13', '6', 2, 2),
    (23, 'Delaunay', 'Lucas', '2012-04-15', '99', 5, 1),
    (24, 'Bouchard', 'Baptiste', '2012-06-27', '10', 1, 1),
    (25, 'Mallet', 'Jules', '2012-02-07', '2', 5, 1),
    (26, 'Thouret', 'Noah', '2012-06-12', '17', 5, 1),
    (27, 'Mallet', 'Hugo', '2012-08-27', '50', 2, 1),
    (28, 'Bouchard', 'Jules', '2012-11-05', '79', 2, 1),
    (29, 'Postel', 'Raphaël', '2012-12-07', '88', 4, 1),
    (30, 'Dubois', 'Émile', '2012-08-20', '7', 1, 1),
    (31, 'Lecomte', 'Gabin', '2012-02-02', '31', 6, 1),
    (32, 'Delaunay', 'Nina', '2012-12-13', '77', 4, 2),
    (33, 'Postel', 'Chloé', '2012-05-17', '17', 2, 2),
    (34, 'Grandin', 'Chloé', '2012-08-18', '36', 2, 2),
    (35, 'Lefebvre', 'Chloé', '2012-04-24', '35', 4, 2),
    (36, 'Marchand', 'Manon', '2012-08-08', '23', 3, 2),
    (37, 'Mallet', 'Louise', '2012-06-17', '12', 3, 2),
    (38, 'Lemonnier', 'Louise', '2012-03-15', '76', 1, 2),
    (39, 'Fouquet', 'Maël', '2010-01-16', '5', 1, 1),
    (40, 'Dubois', 'Timéo', '2010-10-21', '9', 6, 1),
    (41, 'Hamel', 'Tom', '2010-05-11', '10', 4, 1),
    (42, 'Pichon', 'Nathan', '2010-09-12', '95', 6, 1),
    (43, 'Rihouey', 'Antoine', '2010-12-05', '46', 1, 1),
    (44, 'Dubois', 'Nina', '2010-11-16', '4', 4, 2),
    (45, 'Thouret', 'Éva', '2010-10-01', '49', 5, 2),
    (46, 'Dubois', 'Chloé', '2010-01-20', '12', 6, 2),
    (47, 'Anquetil', 'Antoine', '2007-02-09', '50', 6, 1),
    (48, 'Duval', 'Noah', '2007-12-19', '60', 5, 1),
    (49, 'Quesnel', 'Lucas', '2007-02-17', '40', 5, 1),
    (50, 'Lefebvre', 'Jules', '2007-02-16', '90', 1, 1),
    (51, 'Thouret', 'Timéo', '2007-08-25', '33', 1, 1),
    (52, 'Hamel', 'Alice', '2007-06-10', '67', 2, 2),
    (53, 'Duval', 'Maëlys', '2007-06-22', '31', 3, 2),
    (54, 'Delaunay', 'Alice', '2007-07-22', '82', 4, 2),
    (55, 'Cauchy', 'Jules', '1996-04-07', '75', 3, 1),
    (56, 'Hamel', 'Timéo', '1996-04-05', '45', 1, 1),
    (57, 'Delaunay', 'Théo', '1996-12-03', '15', 4, 1),
    (58, 'Vasseur', 'Émile', '1996-08-09', '49', 6, 1),
    (59, 'Levasseur', 'Inès', '1996-09-16', '92', 5, 2),
    (60, 'Dubois', 'Manon', '1996-08-11', '36', 5, 2);

-- ---------------------------------------------------------------------------
-- 6. Championnat et étapes
-- ---------------------------------------------------------------------------

INSERT INTO championnat (id, championnat_type_id, annee, finie) VALUES (1, 1, 2026, 0);

INSERT INTO etape (id, championnat_id, lieu_id, finie) VALUES
    (1, 1, 1, 0),   -- manche d'ouverture à Rouen
    (2, 1, 5, 0);   -- deuxième manche à Caen

