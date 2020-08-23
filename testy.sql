-- TESTY PROCEDUR I FUNKCJI

-- TEST LOGOWANIA - procedury zaloguj, wyloguj

-- zalogowanie
    EXECUTE zaloguj('login2', 'haslopracownik2');
    EXECUTE zaloguj('login4', 'haslopracownik4');
-- zalogowani pracownicy: 2 i 4


-- proba zalogowania pracownika, ktory jest zalogowany - nic nie zmienia
    EXECUTE zaloguj('login2', 'haslopracownik2');


-- wylogowanie pracownika 2
    EXECUTE wyloguj('login2', 2);
-- zalogowany tylko pracownik o id=4

-- proba wylogowania pracownika 1 zakonczona niepowodzeniem, bo byl juz wylogowany
	EXECUTE wyloguj('login1', 1);
-- sygnalizacja, ze uzytkownik byl juz wylogowany


-- nieprawidlowe haslo lub login w czasie logownia
	EXECUTE zaloguj('zlylogin', 'haslopracownik1');
	EXECUTE zaloguj('login1', 'zlehaslo');
-- sygnalizacja blednego hasla lub loginu


-- nieprawidlowe login lub id prac w czasie logowania
	EXECUTE wyloguj('zlylog', 1);
-- sygnalizacja nieprawidlowego loginu
	
	EXECUTE wyloguj('login1', -1);
-- sygnalizacja nieprawidlowego id



-- TEST TWORZENIA WYPOZYCZEN, DODAWANIA DO NICH KOLEJNYCH EGZEMPLARZY ( czytelnik moze wypozyczyc na raz wiele egzemplarzy - minimum 1 )
-- na poczatku egzemplarze powinny byc dostepne, potem niedostepne ( o ile wczesniej nie zostaly wypozyczone )
DECLARE
w_test NUMBER(4) := wypozyczenie_id.nextval+1;
egz_1 NUMBER(4) := 1;
egz_2 NUMBER(4) := 2;
egz_3 NUMBER(4) := 3;
dost_1 VARCHAR2(20) := 'brak';
dost_2 VARCHAR2(20) := 'brak';
dost_3 VARCHAR2(20) := 'brak';
BEGIN

SELECT dostepnosc INTO dost_1 FROM egzemplarz
WHERE egzemplarz_id=egz_1;
SELECT dostepnosc INTO dost_2 FROM egzemplarz
WHERE egzemplarz_id=egz_2;
SELECT dostepnosc INTO dost_3 FROM egzemplarz
WHERE egzemplarz_id=egz_3;

dbms_output.put_line('egz1: ' || dost_1 || ' egz2: ' || dost_2 || ' egz3: ' || dost_3);

zaloguj('login4', 'haslopracownik4');
stworzWypozyczenie(4, 2, egz_1);

dodajEgzemplarzDoWypozyczenia(4, w_test, egz_2);
dodajEgzemplarzDoWypozyczenia(4, w_test, egz_3);

SELECT dostepnosc INTO dost_1 FROM egzemplarz
WHERE egzemplarz_id=egz_1;
SELECT dostepnosc INTO dost_2 FROM egzemplarz
WHERE egzemplarz_id=egz_2;
SELECT dostepnosc INTO dost_3 FROM egzemplarz
WHERE egzemplarz_id=egz_3;

dbms_output.put_line('egz1: ' || dost_1 || ' egz2: ' || dost_2 || ' egz3: ' || dost_3);

END;


-- TEST ZWRACANIE KSIAZEK
DECLARE
w_test NUMBER(4) := wypozyczenie_id.nextval+1;
egz_1 NUMBER(4) := 31;
egz_2 NUMBER(4) := 32;
egz_3 NUMBER(4) := 33;
dost_1 VARCHAR2(20) := 'brak';
dost_2 VARCHAR2(20) := 'brak';
dost_3 VARCHAR2(20) := 'brak';
BEGIN
zaloguj('login4', 'haslopracownik4');
stworzWypozyczenie(4, 2, egz_1);
dodajEgzemplarzDoWypozyczenia(4, w_test, egz_2);
dodajEgzemplarzDoWypozyczenia(4, w_test, egz_3);


SELECT dostepnosc INTO dost_1 FROM egzemplarz
WHERE egzemplarz_id=egz_1;
SELECT dostepnosc INTO dost_2 FROM egzemplarz
WHERE egzemplarz_id=egz_2;
SELECT dostepnosc INTO dost_3 FROM egzemplarz
WHERE egzemplarz_id=egz_3;
dbms_output.put_line('egz1: ' || dost_1 || ' egz2: ' || dost_2 || ' egz3: ' || dost_3);

zwrocEgzemplarz(4, w_test, egz_1);
zwrocEgzemplarz(4, w_test, egz_2);
zwrocEgzemplarz(4, w_test, egz_3);

SELECT dostepnosc INTO dost_1 FROM egzemplarz
WHERE egzemplarz_id=egz_1;
SELECT dostepnosc INTO dost_2 FROM egzemplarz
WHERE egzemplarz_id=egz_2;
SELECT dostepnosc INTO dost_3 FROM egzemplarz
WHERE egzemplarz_id=egz_3;

dbms_output.put_line('egz1: ' || dost_1 || ' egz2: ' || dost_2 || ' egz3: ' || dost_3);

END;


-- TEST NAJCZESCIEJ WYBIERANEGO AUTORA
-- wypisanie danych autora oraz zwrocenie jego id, np w celu pozniejszego wyszukania jego ksiazek

BEGIN
    dbms_output.put_line( pobierzNajCzytAut(4, 2));
END;


-- TEST POBIERANIA DLUGU CZYTELNIKA

-- pobranie dlugu czytelnika o id 2, ktory wynosi 0
BEGIN
    dbms_output.put_line( pobierzDlugCzytelnika(4, 2));
END;


-- TEST ZAPISYWANIA DLUGU PO ODDANIU KSIAZEK ORAZ POBIERANIA CALKOWITEGO NIEODDANEGO DLUGU
-- sztucznie wydluzony czas przetrzymywania ksiazki do 61 dni, czyli przekroczony termin o 31 dni
-- oraz test zwrotu - po zwroceniu dlugu dlug sie zmniejsza
DECLARE
nowe_wyp_id NUMBER(4):=wypozyczenie_id.nextval;

BEGIN
    nowe_wyp_id:=nowe_wyp_id+1;
    stworzWypozyczenie(4,1,7);
    
    UPDATE wypozyczenie SET data_wypozyczenia=SYSDATE-61
    WHERE wypozyczenie_id=nowe_wyp_id;
    
    UPDATE egzemplarz_wypozyczenie SET data_wypozyczenia=SYSDATE-61
    WHERE egzemplarz_id=7 AND wypozyczenie_id=nowe_wyp_id;
    
    zwrocEgzemplarz(4,nowe_wyp_id, 7);
    dbms_output.put_line('Dlug czytelnika wynosi: ' || pobierzDlugCzytelnika(4,1));
    
    zwrocdlugwyp(4, 1, nowe_wyp_id);
    dbms_output.put_line('Dlug czytelnika po zwroceniu naleznosci wynosi: ' || pobierzDlugCzytelnika(4,1));
END;