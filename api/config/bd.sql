-- Création de la base de données
CREATE DATABASE IF NOT EXISTS parrainagefinal;
USE parrainagefinal;

--------------------------------------------------
-- 1. Table pour les membres de la DGE
--------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--------------------------------------------------
-- 2. Tables pour la gestion des électeurs
--------------------------------------------------

-- Table principale contenant la liste validée des électeurs
CREATE TABLE electeurs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    prenom VARCHAR(100) NOT NULL,
    nom VARCHAR(100) NOT NULL,
    date_naissance DATE NOT NULL,
    sexe ENUM('M','F') NOT NULL,
    taille DECIMAL(4,1) NOT NULL,
    lieu_naissance VARCHAR(255) NOT NULL,
    date_delivrance DATE NOT NULL,
    date_expiration DATE NOT NULL,
    centre_enregistrement VARCHAR(255) NOT NULL,
    cni CHAR(13) NOT NULL, -- doit commencer par '1' (H) ou '2' (F)
    adresse_domicile VARCHAR(255) NOT NULL,
    codepays VARCHAR(3) NOT NULL DEFAULT 'SEN',
    numeroElecteur CHAR(9) NOT NULL, -- 9 chiffres
    region VARCHAR(100) NOT NULL,
    departement VARCHAR(100) NOT NULL,
    commune VARCHAR(100) NOT NULL,
    lieu_vote VARCHAR(255) NOT NULL,
    bureau_vote CHAR(2) NOT NULL,
    UNIQUE(numeroElecteur),
    UNIQUE(cni),
    CHECK(CHAR_LENGTH(numeroElecteur) = 9),
    CHECK(CHAR_LENGTH(cni) = 13),
    CHECK(
      (sexe = 'M' AND cni LIKE '1%') OR
      (sexe = 'F' AND cni LIKE '2%')
    )
);

--3 Table temporaire utilisée lors de l'import du fichier CSV

CREATE TABLE electeurs_temp (
    id INT AUTO_INCREMENT PRIMARY KEY,
    prenom VARCHAR(100) NOT NULL,
    nom VARCHAR(100) NOT NULL,
    date_naissance DATE NOT NULL,
    sexe ENUM('M','F') NOT NULL,
    taille DECIMAL(4,1) NOT NULL,
    lieu_naissance VARCHAR(255) NOT NULL,
    date_delivrance DATE NOT NULL,
    date_expiration DATE NOT NULL,
    centre_enregistrement VARCHAR(255) NOT NULL,
    cni CHAR(13) NOT NULL, -- doit commencer par '1' (H) ou '2' (F)
    adresse_domicile VARCHAR(255) NOT NULL,
    codepays VARCHAR(3) NOT NULL DEFAULT 'SEN',
    numeroElecteur CHAR(9) NOT NULL, -- 9 chiffres
    region VARCHAR(100) NOT NULL,
    departement VARCHAR(100) NOT NULL,
    commune VARCHAR(100) NOT NULL,
    lieu_vote VARCHAR(255) NOT NULL,
    bureau_vote CHAR(2) NOT NULL,
    UNIQUE(numeroElecteur),
    UNIQUE(cni),
    CHECK(CHAR_LENGTH(numeroElecteur) = 9),
    CHECK(CHAR_LENGTH(cni) = 13),
    CHECK(
      (sexe = 'M' AND cni LIKE '1%') OR
      (sexe = 'F' AND cni LIKE '2%')
    )
);

-- 4 Table pour les uploads
CREATE TABLE uploads (
    id INT AUTO_INCREMENT PRIMARY KEY,
    users_id INT NOT NULL,
    fichier_nom VARCHAR(255) NOT NULL,
    checksum VARCHAR(64) NOT NULL,
    date_upload TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    adresse_ip VARCHAR(45) NOT NULL,
    etat ENUM('succès','échec') NOT NULL,
    message TEXT
);

-- 5 Table pour enregistrer les erreurs lors de l'importation
CREATE TABLE IF NOT EXISTS electeurs_erreurs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_cin CHAR(13) NOT NULL,
    numero_electeur CHAR(9) NOT NULL,
    erreur TEXT NOT NULL,
    upload_attempt INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--------------------------------------------------
-- 6. Table pour les candidats
--------------------------------------------------
CREATE TABLE IF NOT EXISTS candidats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_electeur CHAR(9) NOT NULL UNIQUE,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100),
    date_naissance DATE NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telephone VARCHAR(15) NOT NULL UNIQUE,
    parti_politique VARCHAR(100),
    slogan VARCHAR(255),
    photo VARCHAR(255),
    url VARCHAR(255),
    code_auth VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (numero_electeur) REFERENCES electeurs(numeroElecteur)
);

-- 7 Table pour l'etat d'upload
CREATE TABLE global_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value VARCHAR(255) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO global_settings (setting_key, setting_value)
VALUES ('EtatUploadElecteurs', 'false');


--------------------------------------------------
-- 8. Table pour la période de parrainage
--------------------------------------------------
CREATE TABLE IF NOT EXISTS periode_parrainage (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--------------------------------------------------
-- 9. Table pour les parrains (électeurs inscrits pour parrainer)
--------------------------------------------------
CREATE TABLE IF NOT EXISTS parrains (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_cin CHAR(13) NOT NULL UNIQUE,
    numero_electeur CHAR(9) NOT NULL UNIQUE,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100),
    bureau_vote CHAR(2) NOT NULL,
    telephone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    code_auth VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (numero_electeur) REFERENCES electeurs(numeroElecteur)
);

--------------------------------------------------
-- 10. Table pour enregistrer les parrainages
--------------------------------------------------
CREATE TABLE IF NOT EXISTS parrainages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    parrain_id INT NOT NULL UNIQUE, -- Un parrain ne peut parrainer qu'une seule fois
    candidat_id INT NOT NULL,
    code_verification VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parrain_id) REFERENCES parrains(id),
    FOREIGN KEY (candidat_id) REFERENCES candidats(id)
);
