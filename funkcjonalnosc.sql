-- PROCEDURY

-- dodajEgzemplarzDoWypozyczenia( pracownik_id, wypozyczenie_id, egzemplarz_id )

create or replace PROCEDURE dodajEgzemplarzDoWypozyczenia (
p_id NUMBER,
w_id NUMBER,
e_id NUMBER
)
AS
p_id_weryf pracownik.pracownik_id%TYPE;
w_id_weryf wypozyczenie.wypozyczenie_id%TYPE;
e_id_weryf egzemplarz.egzemplarz_id%TYPE;

blad_wypozyczenia EXCEPTION;
blad_pracownika EXCEPTION;
blad_egzemplarza EXCEPTION;
BEGIN
    SELECT pracownik_id INTO p_id_weryf FROM pracownik
    WHERE pracownik_id=p_id AND status LIKE 'zalogowany';
    IF p_id_weryf!=p_id THEN
    RAISE blad_pracownika;
    END IF;

    SELECT wypozyczenie_id INTO w_id_weryf FROM wypozyczenie
    WHERE wypozyczenie_id=w_id AND data_wypozyczenia>SYSDATE-1;
    IF w_id_weryf!=w_id THEN
    RAISE blad_wypozyczenia;
    END IF;

    SELECT egzemplarz_id INTO e_id_weryf FROM egzemplarz
    WHERE egzemplarz_id=e_id AND dostepnosc LIKE 'dostepna';
    IF e_id_weryf!=e_id THEN
    RAISE blad_egzemplarza;
    END IF;

    INSERT INTO egzemplarz_wypozyczenie VALUES ( e_id_weryf, w_id_weryf, SYSDATE, null, null );
    COMMIT;
EXCEPTION
    WHEN no_data_found THEN
    dbms_output.put_line('Wystapil blad - sprawdz, czy wprowadzono prawidlowe dane');
    WHEN blad_wypozyczenia THEN
    dbms_output.put_line('Brak wypozyczenia');
    WHEN blad_pracownika THEN
    dbms_output.put_line('Brak pracownika lub pracownik jest wylogowany');
    WHEN blad_egzemplarza THEN
    dbms_output.put_line('Brak egzemplarza lub dany egzemplarz jest wypozyczony');

END dodajEgzemplarzDoWypozyczenia;
/

-- stworzWypozyczenie( pracownik_id, czytelnik_id, egzemplarz_id )

create or replace PROCEDURE stworzWypozyczenie (
p_id NUMBER,
c_id NUMBER,
e_id NUMBER
)
AS
c_id_weryf czytelnik.czytelnik_id%TYPE;
p_id_weryf pracownik.pracownik_id%TYPE;
e_id_weryf egzemplarz.egzemplarz_id%TYPE;

blad_czytelnika EXCEPTION;
blad_pracownika EXCEPTION;
blad_egzemplarza EXCEPTION;
BEGIN
    SELECT pracownik_id INTO p_id_weryf FROM pracownik
    WHERE pracownik_id=p_id AND status LIKE 'zalogowany';
    IF p_id_weryf!=p_id THEN
    RAISE blad_pracownika;
    END IF;

    SELECT czytelnik_id INTO c_id_weryf FROM czytelnik
    WHERE czytelnik_id=c_id;
    IF c_id_weryf!=c_id THEN
    RAISE blad_czytelnika;
    END IF;

    SELECT egzemplarz_id INTO e_id_weryf FROM egzemplarz
    WHERE egzemplarz_id=e_id AND dostepnosc LIKE 'dostepna';
    IF e_id_weryf!=e_id THEN
    RAISE blad_egzemplarza;
    END IF;

    INSERT INTO wypozyczenie VALUES ( wypozyczenie_id.nextval, c_id_weryf, SYSDATE, null, null, p_id_weryf, null);
    INSERT INTO egzemplarz_wypozyczenie VALUES ( e_id_weryf, wypozyczenie_id.currval, SYSDATE, null, null );
    COMMIT;
EXCEPTION
    WHEN blad_czytelnika THEN
    dbms_output.put_line('Brak czytelnika o takim id');
    WHEN no_data_found THEN
    dbms_output.put_line('Blad tworzenia wypozyczenia - sprawdz wprowadzone dane');
    WHEN blad_pracownika THEN
    dbms_output.put_line('Brak pracownika lub pracownik jest wylogowany');
    WHEN blad_egzemplarza THEN
    dbms_output.put_line('Brak egzemplarza lub dany egzemplarz jest wypozyczony');

END stworzWypozyczenie;
/

-- wyloguj( login, pracownik_id )

create or replace PROCEDURE wyloguj (
p_login VARCHAR2,
p_id NUMBER
)
AS
potwierdzone_id pracownik.pracownik_id%TYPE;
potwierdzony_login pracownik.login%TYPE;
obecny_status pracownik.status%TYPE;

brak_pracownika EXCEPTION;
pracownik_wylogowany EXCEPTION;
BEGIN
    potwierdzone_id:=-1;
    SELECT pracownik_id, login INTO potwierdzone_id, potwierdzony_login FROM pracownik
    WHERE pracownik_id=p_id;

    IF potwierdzony_login NOT LIKE p_login THEN
    RAISE brak_pracownika;
    END IF;

	SELECT status INTO obecny_status FROM pracownik
    WHERE pracownik_id=p_id;
    IF obecny_status NOT LIKE 'zalogowany' THEN
    RAISE pracownik_wylogowany;
    END IF;
    UPDATE pracownik SET status='wylogowany'
    WHERE login LIKE p_login AND pracownik_id=p_id;
    COMMIT;
EXCEPTION
    WHEN brak_pracownika THEN
    dbms_output.put_line('Nieprawidlowy login');
    WHEN no_data_found THEN
    dbms_output.put_line('Nieprawidlowe id pracownika');
    WHEN pracownik_wylogowany THEN
    dbms_output.put_line('Pracownik byl wylogowany');
END wyloguj;
/

-- zaloguj( login, haslo)

create or replace PROCEDURE zaloguj
(
p_login VARCHAR2,
p_haslo VARCHAR2
)
AS
p_id pracownik.pracownik_id%TYPE;
BEGIN
    SELECT pracownik_id INTO p_id
    FROM pracownik
    WHERE login LIKE p_login AND haslo LIKE p_haslo;

    UPDATE pracownik SET status='zalogowany'
    WHERE pracownik_id=p_id;
    COMMIT;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('Sprawdz ponownie login i haslo uzytkownika' );
END zaloguj;
/

-- zwrocDlugWyp( pracownik_id, czytelnik_id, wypozyczenie_id )

create or replace PROCEDURE zwrocDlugWyp (
p_id NUMBER,
c_id NUMBER,
w_id NUMBER
)
AS
p_id_weryf pracownik.pracownik_id%TYPE;
c_id_weryf czytelnik.czytelnik_id%TYPE;
w_id_weryf wypozyczenie.wypozyczenie_id%TYPE;

blad_czytelnika EXCEPTION;
blad_pracownika EXCEPTION;
BEGIN
    SELECT pracownik_id INTO p_id_weryf FROM pracownik
    WHERE pracownik_id=p_id AND status LIKE 'zalogowany';
    IF p_id_weryf!=p_id THEN
    RAISE blad_pracownika;
    END IF;

    SELECT czytelnik_id INTO c_id_weryf FROM czytelnik
    WHERE czytelnik_id=c_id;
    IF c_id_weryf!=c_id THEN
    RAISE blad_czytelnika;
    END IF;

    SELECT wypozyczenie_id INTO w_id_weryf FROM wypozyczenie
    WHERE wypozyczenie_id=w_id AND czy_oplacone LIKE 'n';
    IF c_id_weryf!=c_id THEN
    RAISE blad_czytelnika;
    END IF;

    UPDATE wypozyczenie SET czy_oplacone='t'
    WHERE wypozyczenie_id=w_id;

EXCEPTION
    WHEN blad_czytelnika THEN
    dbms_output.put_line('Brak czytelnika');
    WHEN blad_pracownika THEN
    dbms_output.put_line('Brak pracownika lub pracownik jest wylogowany');

END;
/

-- zwrocEgzemplarz( pracownik_id, wypozyczenie_id, egzemplarz_id )

create or replace PROCEDURE zwrocEgzemplarz (
p_id NUMBER,
w_id NUMBER,
e_id NUMBER
)
AS
p_id_weryf pracownik.pracownik_id%TYPE;
w_id_weryf wypozyczenie.wypozyczenie_id%TYPE;
e_id_weryf egzemplarz.egzemplarz_id%TYPE;
data_wyp_e DATE;
oplata_e NUMBER(9,2);

suma_oplat NUMBER(6,2);
wszystkie_zwrocone VARCHAR2(2);

 CURSOR egzemplarze_w IS
 SELECT egzemplarz_id, oplata_egzemplarz, data_zwrotu
 FROM egzemplarz_wypozyczenie
 WHERE wypozyczenie_id=w_id;

blad_pracownika EXCEPTION;
blad_egzemplarza EXCEPTION;
BEGIN
    wszystkie_zwrocone:='t';
    oplata_e:=0;
    SELECT pracownik_id INTO p_id_weryf FROM pracownik
    WHERE pracownik_id=p_id AND status LIKE 'zalogowany';
    IF p_id_weryf!=p_id THEN
    RAISE blad_pracownika;
    END IF;

    SELECT egzemplarz_id INTO e_id_weryf FROM egzemplarz
    WHERE egzemplarz_id=e_id AND dostepnosc LIKE 'niedostepna';
    IF e_id_weryf!=e_id THEN
    RAISE blad_egzemplarza;
    END IF;

    SELECT data_wypozyczenia INTO data_wyp_e FROM egzemplarz_wypozyczenie
    WHERE egzemplarz_id=e_id AND wypozyczenie_id=w_id;
    
    IF (SYSDATE-data_wyp_e-30)>0 THEN
    oplata_e:=(SYSDATE-data_wyp_e-30)*0.1;
    END IF;
    
    UPDATE egzemplarz_wypozyczenie SET
         data_zwrotu=SYSDATE,
         oplata_egzemplarz=oplata_e
    WHERE egzemplarz_id=e_id_weryf AND data_zwrotu IS null;
    
        suma_oplat:=0;
    FOR i IN egzemplarze_w
    LOOP
        suma_oplat:=suma_oplat+i.oplata_egzemplarz;
        IF i.data_zwrotu IS null THEN
        wszystkie_zwrocone:='n';
        END IF;
    END LOOP;
    
    IF wszystkie_zwrocone LIKE 't' THEN
    UPDATE wypozyczenie SET
        data_zwrotu=SYSDATE,
        kwota_do_zaplaty=suma_oplat,
        czy_oplacone='n'
    WHERE wypozyczenie_id=w_id;
    END IF;

    IF suma_oplat=0 THEN
    UPDATE wypozyczenie SET
        czy_oplacone='t'
    WHERE wypozyczenie_id=w_id;
    END IF;

    UPDATE wypozyczenie SET kwota_do_zaplaty=suma_oplat
    WHERE wypozyczenie_id=w_id;
    
    COMMIT;
EXCEPTION
    WHEN no_data_found THEN
    dbms_output.put_line('Blad podczas zwrotu egzemplarza - sprawdz dane');
    WHEN blad_pracownika THEN
    dbms_output.put_line('Brak pracownika lub pracownik jest wylogowany');
    WHEN blad_egzemplarza THEN
    dbms_output.put_line('Brak egzemplarza lub dany egzemplarz jest wypozyczony');

END zwrocEgzemplarz;
/

-- FUNKCJE


-- pobierzDlugCzytelnika( pracownik_id, czytelnik_id )

create or replace FUNCTION pobierzDlugCzytelnika (
p_id NUMBER,
c_id NUMBER
)
RETURN NUMBER
AS
p_id_weryf pracownik.pracownik_id%TYPE;
c_id_weryf czytelnik.czytelnik_id%TYPE;
wszystkie_zwrocone VARCHAR2(2);
calkowite_zadluzenie NUMBER;

CURSOR wypozyczenie_do_opl IS
 SELECT wypozyczenie_id, kwota_do_zaplaty
 FROM wypozyczenie
 WHERE czytelnik_id=c_id AND czy_oplacone LIKE 'n' AND data_zwrotu IS NOT null;

blad_czytelnika EXCEPTION;
blad_pracownika EXCEPTION;
BEGIN
    calkowite_zadluzenie:=0;
    SELECT pracownik_id INTO p_id_weryf FROM pracownik
    WHERE pracownik_id=p_id AND status LIKE 'zalogowany';
    IF p_id_weryf!=p_id THEN
    RAISE blad_pracownika;
    END IF;

    SELECT czytelnik_id INTO c_id_weryf FROM czytelnik
    WHERE czytelnik_id=c_id;
    IF c_id_weryf!=c_id THEN
    RAISE blad_czytelnika;
    END IF;

    FOR i IN wypozyczenie_do_opl
    LOOP
      calkowite_zadluzenie:=calkowite_zadluzenie+i.kwota_do_zaplaty;
    END LOOP;

    RETURN calkowite_zadluzenie;
EXCEPTION
    WHEN blad_czytelnika THEN
    dbms_output.put_line('Brak czytelnika');
    WHEN no_data_found THEN
    dbms_output.put_line('Blad pobierania dlugu - brak czytelnika, badz brak danych');
    WHEN blad_pracownika THEN
    dbms_output.put_line('Brak pracownika lub pracownik jest wylogowany');

END pobierzDlugCzytelnika;
/

-- pobierzNajCzytAut( pracownik_id, czytelnik_id )

create or replace FUNCTION pobierzNajCzytAut (
p_id NUMBER,
c_id NUMBER
)
RETURN NUMBER
AS
p_id_weryf pracownik.pracownik_id%TYPE;
c_id_weryf czytelnik.czytelnik_id%TYPE;
wszystkie_zwrocone VARCHAR2(2);
najczesciej_czyt_aut NUMBER;

TYPE r_type_autor IS RECORD
(
    imie autor.imie%TYPE,
    nazwisko autor.nazwisko%TYPE,
    narodowosc autor.narodowosc%TYPE
);
r_autor r_type_autor;

blad_czytelnika EXCEPTION;
blad_pracownika EXCEPTION;
BEGIN
    SELECT pracownik_id INTO p_id_weryf FROM pracownik
    WHERE pracownik_id=p_id AND status LIKE 'zalogowany';
    IF p_id_weryf!=p_id THEN
    RAISE blad_pracownika;
    END IF;

    SELECT czytelnik_id INTO c_id_weryf FROM czytelnik
    WHERE czytelnik_id=c_id;
    IF c_id_weryf!=c_id THEN
    RAISE blad_czytelnika;
    END IF;

    SELECT max(k.autor_id) INTO najczesciej_czyt_aut
    FROM czytelnik c
    JOIN wypozyczenie w
    ON w.czytelnik_id=c.czytelnik_id
    JOIN egzemplarz_wypozyczenie ew
    ON ew.wypozyczenie_id=w.wypozyczenie_id
    JOIN egzemplarz e
    ON e.egzemplarz_id=ew.egzemplarz_id
    JOIN ksiazka k
    ON k.ISBN_id=e.ISBN_id
    WHERE c.czytelnik_id=c_id
    GROUP BY k.autor_id;    

    SELECT autor.imie, autor.nazwisko, autor.narodowosc INTO r_autor.imie, r_autor.nazwisko, r_autor.narodowosc
    FROM autor
    WHERE autor_id=najczesciej_czyt_aut;

    dbms_output.put_line('Najczesciej czytany autor: ' || r_autor.imie || ' ' || r_autor.nazwisko || ' ' || r_autor.narodowosc);

    RETURN najczesciej_czyt_aut;
EXCEPTION
    WHEN no_data_found THEN
    dbms_output.put_line('Brak czytelnika, badz czytelnik jeszcze nie korzystal z biblioteki');
    WHEN blad_czytelnika THEN
    dbms_output.put_line('Brak czytelnika');
    WHEN blad_pracownika THEN
    dbms_output.put_line('Brak pracownika lub pracownik jest wylogowany');

END pobierzNajCzytAut;
/


-- TRIGGERY


-- dokupienieEgzemplarzaT

create or replace TRIGGER dokupienieEgzemplarzaT
AFTER
INSERT ON egzemplarz
FOR EACH ROW
DECLARE
k_ISBN NUMBER;

brakKsiazki EXCEPTION;
BEGIN
    SELECT ISBN_id INTO k_ISBN FROM ksiazka
    WHERE :new.ISBN_id=ISBN_id;

    IF k_ISBN!=null THEN
    UPDATE ksiazka SET dostepne_egzemplarze=dostepne_egzemplarze+1
    WHERE ISBN_id=k_ISBN;
    ELSE
    RAISE brakKsiazki;
    END IF;
EXCEPTION
    WHEN brakKsiazki THEN
    dbms_output.put_line('Najpierw dodaj nowa ksiazke do zbioru biblioteki, potem egzemplarze');
END;
/

-- wypozyczenieT

create or replace TRIGGER wypozyczenieT
AFTER
INSERT ON egzemplarz_wypozyczenie
FOR EACH ROW
DECLARE
ISBN_ksiazki NUMBER;
e_id_weryf NUMBER;
e_id NUMBER;
blad_egzemplarza EXCEPTION;
BEGIN
    e_id:=:new.egzemplarz_id;
    SELECT egzemplarz_id, ISBN_id INTO e_id_weryf, ISBN_ksiazki FROM egzemplarz
    WHERE egzemplarz_id=e_id AND dostepnosc LIKE 'dostepna';

    IF e_id_weryf!=e_id THEN
    RAISE blad_egzemplarza;
    ELSE
    UPDATE egzemplarz SET dostepnosc='niedostepna'
    WHERE egzemplarz_id=e_id_weryf;
    UPDATE ksiazka SET dostepne_egzemplarze=dostepne_egzemplarze-1
    WHERE ISBN_id=ISBN_ksiazki;
    END IF;
EXCEPTION
    WHEN blad_egzemplarza THEN
    dbms_output.put_line('Blad egzemplarza');
END;
/

-- zwrotksiazkiT

create or replace TRIGGER zwrotksiazkiT
AFTER
UPDATE OF data_zwrotu ON egzemplarz_wypozyczenie
FOR EACH ROW
DECLARE
ISBN_ksiazki NUMBER;
e_id_weryf NUMBER;
e_id NUMBER;
blad_egzemplarza EXCEPTION;
BEGIN
    e_id:=:new.egzemplarz_id;
    SELECT egzemplarz_id, ISBN_id INTO e_id_weryf, ISBN_ksiazki FROM egzemplarz
    WHERE egzemplarz_id=e_id AND dostepnosc LIKE 'niedostepna';

    IF e_id_weryf!=e_id THEN
    RAISE blad_egzemplarza;
    ELSE
    UPDATE egzemplarz SET dostepnosc='dostepna'
    WHERE egzemplarz_id=e_id_weryf;
    UPDATE ksiazka SET dostepne_egzemplarze=dostepne_egzemplarze+1
    WHERE ISBN_id=ISBN_ksiazki;
    END IF;
EXCEPTION
    WHEN blad_egzemplarza THEN
    dbms_output.put_line('Blad egzemplarza');
END;
/