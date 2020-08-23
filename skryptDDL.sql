-- AUTOR

CREATE TABLE AUTOR (
Autor_id NUMBER(4) PRIMARY KEY,
Imie VARCHAR2(20) NOT NULL,
Nazwisko VARCHAR2(20) NOT NULL,
Narodowosc VARCHAR(25)
)
/

-- RODZAJ_KSIAZKI

CREATE TABLE RODZAJ_KSIAZKI (
rodzaj_id NUMBER(4) PRIMARY KEY,
nazwa VARCHAR2(30) NOT NULL
)
/

-- KSIAZKA

CREATE TABLE KSIAZKA (
ISBN_id NUMBER(4) PRIMARY KEY,
Tytul VARCHAR2(40) NOT NULL,
Rodzaj_id NUMBER(4),
Autor_id NUMBER(4)
);
/

ALTER TABLE ksiazka ADD (
    dostepne_egzemplarze NUMBER(4) CONSTRAINT d_egz_zakres CHECK ( dostepne_egzemplarze >=0 )
);
/

ALTER TABLE ksiazka ADD CONSTRAINT ksiazka_autor FOREIGN KEY (autor_id) REFERENCES autor (autor_id) ON DELETE SET NULL;
/

ALTER TABLE ksiazka ADD CONSTRAINT ksiazka_rodzaj FOREIGN KEY (rodzaj_id) REFERENCES rodzaj_ksiazki (rodzaj_id) ON DELETE SET NULL;
/

-- EGZEMPLARZ
CREATE TABLE egzemplarz (
    egzemplarz_id NUMBER(4) PRIMARY KEY,
    ISBN_id NUMBER(4),
    stan_ksiazki VARCHAR2(20) DEFAULT 'bardzo dobry' CONSTRAINT stan_ksiazki_zbior CHECK ( stan_ksiazki IN ( 'bardzo dobry', 'dobry', 'zniszczona') ),
    dostepnosc VARCHAR2(20) DEFAULT 'dostepna' CONSTRAINT dostepnosc_zbior CHECK ( dostepnosc IN ( 'dostepna', 'niedostepna' ) )
);
/

ALTER TABLE egzemplarz ADD CONSTRAINT f_key_ISBN FOREIGN KEY (ISBN_id) REFERENCES KSIAZKA ( ISBN_id ) ON DELETE CASCADE;
/

-- CZYTELNIK
CREATE TABLE czytelnik (
czytelnik_id NUMBER(4) PRIMARY KEY,
imie VARCHAR2(20) NOT NULL,
nazwisko VARCHAR2(20) NOT NULL,
email VARCHAR2(30) NOT NULL,
telefon NUMBER(9) NOT NULL
);
/


-- PRACOWNIK
CREATE TABLE pracownik (
pracownik_id NUMBER(4) PRIMARY KEY,
imie VARCHAR2(20) NOT NULL,
nazwisko VARCHAR2(20) NOT NULL,
telefon NUMBER(9) NOT NULL,
login VARCHAR2(20) NOT NULL,
haslo VARCHAR2(20) NOT NULL
);
/


ALTER TABLE pracownik ADD CONSTRAINT h_min
CHECK ( length(haslo) >=8 );
ALTER TABLE pracownik ADD(
status VARCHAR2(14) DEFAULT 'wylogowany' CONSTRAINT zbior_statusu CHECK ( status IN ( 'zalogowany', 'wylogowany' ) )
);
/

-- WYPOZYCZENIE
CREATE TABLE wypozyczenie (
wypozyczenie_id NUMBER(4) PRIMARY KEY,
czytelnik_id NUMBER(4),
data_wypozyczenia DATE,
data_zwrotu DATE DEFAULT NULL,
kwota_do_zaplaty NUMBER(6,2),
pracownik_id NUMBER(4)
);
/

ALTER TABLE wypozyczenie ADD CONSTRAINT czyt_fk
FOREIGN KEY ( czytelnik_id ) REFERENCES czytelnik ( czytelnik_id ) ON DELETE CASCADE;
/

ALTER TABLE wypozyczenie ADD CONSTRAINT prac_fk
FOREIGN KEY ( pracownik_id ) REFERENCES pracownik (pracownik_id) ON DELETE set null;
/

-- EGZEMPLARZ_WYPOZYCZENIE
CREATE TABLE egzemplarz_wypozyczenie (
egzemplarz_id NUMBER(4),
wypozyczenie_id NUMBER(4)
);
ALTER TABLE wypozyczenie ADD (
czy_oplacone VARCHAR2(2) DEFAULT 'n'CONSTRAINT t_n CHECK ( czy_oplacone IN ('t', 'n'))
);
/

ALTER TABLE egzemplarz_wypozyczenie ADD (
data_wypozyczenia DATE,
data_zwrotu DATE DEFAULT NULL,
oplata_egzemplarz NUMBER(6,2) DEFAULT 0 CONSTRAINT oplata_nieujemna CHECK ( oplata_egzemplarz >= 0 )
);
/

ALTER TABLE egzemplarz_wypozyczenie ADD CONSTRAINT egz_wyp_pk
PRIMARY KEY ( egzemplarz_id, wypozyczenie_id );
/

ALTER TABLE egzemplarz_wypozyczenie ADD CONSTRAINT wyp_fk
FOREIGN KEY ( wypozyczenie_id ) REFERENCES wypozyczenie (wypozyczenie_id) ON DELETE SET NULL;
/

ALTER TABLE egzemplarz_wypozyczenie ADD CONSTRAINT egz_fk
FOREIGN KEY ( egzemplarz_id ) REFERENCES egzemplarz (egzemplarz_id) ON DELETE SET NULL;
/

-- SEKWENCJE

CREATE SEQUENCE rodzaj_ksiazki_id
MINVALUE 1
MAXVALUE 9999
START WITH 1
INCREMENT BY 1;
/

CREATE SEQUENCE autor_id
MINVALUE 1
MAXVALUE 9999
START WITH 1
INCREMENT BY 1;
/

CREATE SEQUENCE ksiazka_id
MINVALUE 1
MAXVALUE 9999
START WITH 1
INCREMENT BY 1;
/

CREATE SEQUENCE egzemplarz_id
MINVALUE 1
MAXVALUE 9999
START WITH 1
INCREMENT BY 1;
/

CREATE SEQUENCE czytelnik_id
MINVALUE 1
MAXVALUE 9999
START WITH 0
INCREMENT BY 1;
/

CREATE SEQUENCE pracownik_id
MINVALUE 1
MAXVALUE 9999
START WITH 1
INCREMENT BY 1;
/

CREATE SEQUENCE wypozyczenie_id
MINVALUE 1
MAXVALUE 9999
START WITH 1
INCREMENT BY 1
CYCLE;
/

CREATE SEQUENCE egzemplarz_wypozyczenie_id
MINVALUE 1
MAXVALUE 9999
START WITH 1
INCREMENT BY 1
CYCLE;
/

COMMIT;
