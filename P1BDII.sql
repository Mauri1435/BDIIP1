CREATE TABLE Usuario (
    ID_Usuario NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    Cedula VARCHAR2(20) UNIQUE NOT NULL,
    Nombre VARCHAR2(50) NOT NULL,
    Apellidos VARCHAR2(100) NOT NULL,
    Numero_Telefonico VARCHAR2(20)
);

CREATE TABLE Editorial (
    ID_Editorial NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    Nombre VARCHAR2(100) UNIQUE NOT NULL
);

CREATE TABLE Autor (
    ID_Autor NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    Nombre VARCHAR2(50) NOT NULL,
    Apellidos VARCHAR2(100) NOT NULL,
    UNIQUE (Nombre, Apellidos)
);

CREATE TABLE Genero (
    ID_Genero NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    Nombre VARCHAR2(50) UNIQUE NOT NULL,
    Descripcion VARCHAR2(255)
);

CREATE TABLE Libros (
    ID_Libro NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    Titulo VARCHAR2(200) UNIQUE NOT NULL,
    ISBN VARCHAR2(20) UNIQUE NOT NULL,
    Edad_Recomendada VARCHAR2(10), --Lo cambié a VARCHAR2 para poder poner 3-5, +18, etc 
    Inventario NUMBER NOT NULL,
    ID_Editorial NUMBER NOT NULL,
    FOREIGN KEY (ID_Editorial) REFERENCES Editorial(ID_Editorial)
);

CREATE TABLE Reservas (
    ID_Reserva NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    Fecha_Reserva DATE NOT NULL,
    Fecha_Devolucion DATE NOT NULL,
    ID_Usuario NUMBER NOT NULL,
    FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario)
);

-- Tablas intermedias 
CREATE TABLE Libro_Reserva(
    ID_Reserva NUMBER NOT NULL,
    ID_Libro NUMBER NOT NULL,
    FOREIGN KEY (ID_Reserva) REFERENCES Reservas(ID_Reserva),
    FOREIGN KEY (ID_Libro) REFERENCES Libros(ID_Libro),
    PRIMARY KEY (ID_Reserva, ID_Libro)
);

CREATE TABLE Autor_Libro(
    ID_Autor NUMBER NOT NULL,
    ID_Libro NUMBER NOT NULL,
    FOREIGN KEY (ID_Autor) REFERENCES Autor(ID_Autor),
    FOREIGN KEY (ID_Libro) REFERENCES Libros(ID_Libro),
    PRIMARY KEY (ID_Autor, ID_Libro)
);

CREATE TABLE Genero_Libro(
    ID_Genero NUMBER NOT NULL,
    ID_Libro NUMBER NOT NULL,
    FOREIGN KEY (ID_Genero) REFERENCES Genero(ID_Genero),
    FOREIGN KEY (ID_Libro) REFERENCES Libros(ID_Libro),
    PRIMARY KEY (ID_Genero, ID_Libro)
);

-- Package de inserts, podría combinarse en uno de modificaciones o mantenerse separado por comodidad

CREATE OR REPLACE PACKAGE pkg_inserts AS
    --Usuario
    PROCEDURE insert_usuario(
        p_cedula IN VARCHAR2,
        p_nombre IN VARCHAR2,
        p_apellidos IN VARCHAR2,
        p_numero_telefonico IN VARCHAR2 DEFAULT NULL
    );
    --Editorial
    PROCEDURE insert_editorial(
        p_nombre IN VARCHAR2
    );
    -- Autor
    PROCEDURE insert_autor(
        p_nombre IN VARCHAR2,
        p_apellidos IN VARCHAR2
    );
    -- Genero
    PROCEDURE insert_genero(
        p_nombre IN VARCHAR2,
        p_descripcion IN VARCHAR2 DEFAULT NULL
    );
    --Libro
    PROCEDURE insert_libro(
        p_titulo IN VARCHAR2,
        p_isbn IN VARCHAR2,
        p_edad_recomendada IN VARCHAR2,
        p_inventario IN NUMBER,
        p_id_editorial IN NUMBER,
        p_autores IN VARCHAR2 DEFAULT NULL,  -- IDs de autores relacionados (ej: '1,2,3')
        p_generos IN VARCHAR2 DEFAULT NULL  -- IDs de generos relacionados (ej: '1,,2,3')
    );
    
END pkg_inserts;
/


CREATE OR REPLACE PACKAGE BODY pkg_inserts AS
    -- USUARIO
    PROCEDURE insert_usuario(
        p_cedula IN VARCHAR2,
        p_nombre IN VARCHAR2,
        p_apellidos IN VARCHAR2,
        p_numero_telefonico IN VARCHAR2 DEFAULT NULL
    ) IS

    BEGIN
        INSERT INTO Usuario (Cedula, Nombre, Apellidos, Numero_Telefonico)
        VALUES (p_cedula, p_nombre, p_apellidos, p_numero_telefonico);
        COMMIT;

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error al insertar Usuario');
            RAISE_APPLICATION_ERROR(-20001, 'Ya existe un usario con la cédula ' || p_cedula);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al insertar Usuario');
            ROLLBACK;
            RAISE;

    END insert_usuario;

    -- EDITORIAL
    PROCEDURE insert_editorial(
        p_nombre IN VARCHAR2
    ) IS

    BEGIN
        INSERT INTO Editorial (Nombre)
        VALUES (p_nombre);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Editorial insertada correctamente');

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error al insertar Editorial');
            RAISE_APPLICATION_ERROR(-20002, 'La editorial ' || p_nombre || ' ya existe');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al insertar Editorial');
            ROLLBACK;
            RAISE;
            
    END insert_editorial;

    --AUTOR
    PROCEDURE insert_autor(
        p_nombre IN VARCHAR2,
        p_apellidos IN VARCHAR2
    ) IS
    BEGIN
        INSERT INTO Autor (Nombre, Apellidos)
        VALUES (p_nombre, p_apellidos);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Autor insertado correctamente');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error al insertar Autor');
            RAISE_APPLICATION_ERROR(-20003, 
                'Ya existe un autor con nombre "' || p_nombre || 
                '" y apellidos "' || p_apellidos || '"');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END insert_autor;

    
    -- GENERO
    PROCEDURE insert_genero(
        p_nombre IN VARCHAR2,
        p_descripcion IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        INSERT INTO Genero (Nombre, Descripcion)
        VALUES (p_nombre, p_descripcion);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Género insertado correctamente');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Error al insertar Género');
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20004, 'El genero ' || p_nombre || ' ya existe');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al insertar Género');
            ROLLBACK;
            RAISE;
    END insert_genero;
    
        
PROCEDURE insert_libro(
    p_titulo IN VARCHAR2,
    p_isbn IN VARCHAR2,
    p_edad_recomendada IN VARCHAR2,
    p_inventario IN NUMBER,
    p_id_editorial IN NUMBER,
    p_autores IN VARCHAR2 DEFAULT NULL, -- IDs de autores relacionados (ej: '1,2,3')
    p_generos IN VARCHAR2 DEFAULT NULL -- IDs de generos relacionados (ej: '1,2,3')
) IS

    v_id_libro NUMBER;
    v_editorial_existe NUMBER;
    v_autor_existe NUMBER;
    v_genero_existe NUMBER;
    
    e_editorial_no_existe EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_editorial_no_existe, -20010);

    e_autor_no_existe EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_autor_no_existe, -20011);

    e_genero_no_existe EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_genero_no_existe, -20012);
    
BEGIN
    -- Validar EDITORIAL existe
    SELECT COUNT(*) INTO v_editorial_existe
    FROM Editorial
    WHERE ID_Editorial = p_id_editorial;
    
    IF v_editorial_existe = 0 THEN
        RAISE e_editorial_no_existe;
    END IF;
    
    -- Validar AUTORES existen 
    IF p_autores IS NOT NULL THEN
        FOR r IN (
            SELECT regexp_substr(p_autores, '[^,]+', 1, LEVEL) AS id_autor
            FROM dual
            CONNECT BY regexp_substr(p_autores, '[^,]+', 1, LEVEL) IS NOT NULL
        ) LOOP
            SELECT COUNT(*) INTO v_autor_existe
            FROM Autor
            WHERE ID_Autor = TO_NUMBER(r.id_autor);
            
            IF v_autor_existe = 0 THEN
                RAISE_APPLICATION_ERROR(-20011, 'Error: No existe el autor con ID ' || r.id_autor);
            END IF;
        END LOOP;
    END IF;
    
    -- Validar GÉNEROS existen 
    IF p_generos IS NOT NULL THEN
        FOR r IN (
            SELECT regexp_substr(p_generos, '[^,]+', 1, LEVEL) AS id_genero
            FROM dual
            CONNECT BY regexp_substr(p_generos, '[^,]+', 1, LEVEL) IS NOT NULL
        ) LOOP
            SELECT COUNT(*) INTO v_genero_existe
            FROM Genero
            WHERE ID_Genero = TO_NUMBER(r.id_genero);
            
            IF v_genero_existe = 0 THEN
                RAISE_APPLICATION_ERROR(-20012, 'Error: No existe el género con ID ' || r.id_genero);
            END IF;
        END LOOP;
    END IF;
    
    -- Insertar el libro 
    INSERT INTO Libros (Titulo, ISBN, Edad_Recomendada, Inventario, ID_Editorial)
    VALUES (p_titulo, p_isbn, p_edad_recomendada, p_inventario, p_id_editorial)
    RETURNING ID_Libro INTO v_id_libro;
    
    -- Insertar relaciones con autores
    IF p_autores IS NOT NULL THEN
        FOR r IN (
            SELECT regexp_substr(p_autores, '[^,]+', 1, LEVEL) AS id_autor
            FROM dual
            CONNECT BY regexp_substr(p_autores, '[^,]+', 1, LEVEL) IS NOT NULL
        ) LOOP
            INSERT INTO Autor_Libro (ID_Autor, ID_Libro)
            VALUES (TO_NUMBER(r.id_autor), v_id_libro);
        END LOOP;
    END IF;
    
    -- Insertar relaciones con géneros
    IF p_generos IS NOT NULL THEN
        FOR r IN (
            SELECT regexp_substr(p_generos, '[^,]+', 1, LEVEL) AS id_genero
            FROM dual
            CONNECT BY regexp_substr(p_generos, '[^,]+', 1, LEVEL) IS NOT NULL
        ) LOOP
            INSERT INTO Genero_Libro (ID_Genero, ID_Libro)
            VALUES (TO_NUMBER(r.id_genero), v_id_libro);
        END LOOP;
    END IF;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Libro insertado correctamente con ID: ' || v_id_libro);
    
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            IF SQLERRM LIKE '%TITULO%' THEN
                RAISE_APPLICATION_ERROR(-20005, 'Error: Ya existe un libro con el título "' || p_titulo || '"');
            ELSIF SQLERRM LIKE '%ISBN%' THEN
                RAISE_APPLICATION_ERROR(-20006, 'Error: Ya existe un libro con el ISBN "' || p_isbn || '"');
            ELSE
                RAISE_APPLICATION_ERROR(-20007, 'Error de duplicado: ' || SQLERRM);
            END IF;
            
        WHEN e_editorial_no_existe THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20010, 'Error: No existe la editorial con ID ' || p_id_editorial);
            
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
END insert_libro;

    
END pkg_inserts;
/


/*
--Trigger para manejar inventario al añadir o eliminar libros de a reserva
CREATE OR REPLACE TRIGGER t_actualizar_invetario
    BEFORE INSERT OR DELETE
    ON Libro_Reserva
    FOR EACH ROW
DECLARE
    v_inventario_actual INTEGER;
    v_titulo VARCHAR(100);

    BEGIN
        IF inserting THEN
            SELECT Inventario, Titulo INTO v_inventario_actual, v_titulo
            FROM Libros
            WHERE ID_Libro = :NEW.ID_Libro;

            IF v_inventario_actual <= 0 THEN
                RAISE_APPLICATION_ERROR(-20101, 'Error 20101: No se cuenta con inventario del título' || v_titulo);

            ELSE
            UPDATE Libros
                SET Inventario = Inventario - 1
            WHERE ID_Libro  = :NEW.ID_Libro;
            END IF;

        ELSIF deleting THEN
            UPDATE Libros
                SET Inventario = Inventario + 1
            WHERE ID_Libro = :OLD.ID_Libro;
        END IF;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Error 20002: Error al buscar el libro con el ID ' || :NEW.ID_Libro);
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Error 20000: Error inesperado');    

    END;
/
*/