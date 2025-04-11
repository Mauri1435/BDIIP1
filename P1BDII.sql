CREATE TABLE Usuario (
    ID_Usuario NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    Cedula VARCHAR2(20) UNIQUE NOT NULL,
    Nombre VARCHAR2(50) NOT NULL,
    Apellidos VARCHAR2(100) NOT NULL,
    Numero_Telefonico VARCHAR2(20),
    Multa NUMBER DEFAULT NULL,
    Cantidad_Libros NUMBER DEFAULT NULL
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
    Activo NUMBER(1) DEFAULT 1 CHECK (Activo IN (0, 1)), -- Para guardar y poder manejar reservas concluidas
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
    -- Libro
    PROCEDURE insert_libro(
        p_titulo IN VARCHAR2,
        p_isbn IN VARCHAR2,
        p_edad_recomendada IN VARCHAR2,
        p_inventario IN NUMBER,
        p_id_editorial IN NUMBER,
        p_autores IN VARCHAR2 DEFAULT NULL,  -- IDs de autores relacionados (ej: '1,2,3')
        p_generos IN VARCHAR2 DEFAULT NULL  -- IDs de generos relacionados (ej: '1,,2,3')
    );
    --Reserva
    PROCEDURE insert_reserva(
        p_fecha_reserva IN DATE,
        p_fecha_devolucion IN DATE,
        p_id_usuario IN NUMBER,
        p_libros IN VARCHAR2 DEFAULT NULL -- IDs de libros relacionados (ej: '1,2,3')
    );
    -- Autor_Libro
    PROCEDURE insert_autor_libro(
        p_id_autor IN NUMBER,
        p_id_libro IN NUMBER
    );
    -- Genero_Libro
    PROCEDURE insert_genero_libro(
        p_id_genero IN NUMBER,
        p_id_libro IN NUMBER
    );
    -- Libro_Reserva
    PROCEDURE insert_libro_reserva(
        p_id_reserva IN NUMBER,
        p_id_libro IN NUMBER
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
    
-- LIBRO            
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

--RESERVA
    PROCEDURE insert_reserva(
        p_fecha_reserva IN DATE,
        p_fecha_devolucion IN DATE,
        p_id_usuario IN NUMBER,
        p_libros IN VARCHAR2 DEFAULT NULL
    ) IS
        v_id_reserva NUMBER;
        v_usuario_existe NUMBER;
        v_libro_existe NUMBER;
        v_id_libro_invalido VARCHAR2 (100);
        
        e_usuario_no_existe EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_usuario_no_existe, -20020);
        
        e_libro_no_existe EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_libro_no_existe, -20021);
    BEGIN
        -- Validar USUARIO
        SELECT COUNT(*) INTO v_usuario_existe
        FROM Usuario
        WHERE ID_Usuario = p_id_usuario;
        
        IF v_usuario_existe = 0 THEN
            RAISE e_usuario_no_existe;
        END IF;
        
        -- Validar LIBROS
        IF p_libros IS NOT NULL THEN
            FOR r IN (
                SELECT regexp_substr(p_libros, '[^,]+', 1, LEVEL) AS id_libro
                FROM dual
                CONNECT BY regexp_substr(p_libros, '[^,]+', 1, LEVEL) IS NOT NULL
            ) LOOP
                v_id_libro_invalido := r.id_libro; 
                
                SELECT COUNT(*) INTO v_libro_existe
                FROM Libros
                WHERE ID_Libro = TO_NUMBER(r.id_libro);
                
                IF v_libro_existe = 0 THEN
                    RAISE e_libro_no_existe;
                END IF;
            END LOOP;
        END IF;
        
        -- Insertar la reserva
        INSERT INTO Reservas (Fecha_Reserva, Fecha_Devolucion, ID_Usuario)
        VALUES (p_fecha_reserva, p_fecha_devolucion, p_id_usuario)
        RETURNING ID_Reserva INTO v_id_reserva;
        
        -- Insertar relaciones con libros (el trigger ajustará el inventario)
        FOR r IN (
            SELECT regexp_substr(p_libros, '[^,]+', 1, LEVEL) AS id_libro
            FROM dual
            CONNECT BY regexp_substr(p_libros, '[^,]+', 1, LEVEL) IS NOT NULL
        ) LOOP
            INSERT INTO Libro_Reserva (ID_Reserva, ID_Libro)
            VALUES (v_id_reserva, TO_NUMBER(r.id_libro));
        END LOOP;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Reserva creada correctamente con ID: ' || v_id_reserva);
        
    EXCEPTION
        WHEN e_usuario_no_existe THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20020, 'Error: No existe el usuario con ID ' || p_id_usuario);
            
        WHEN e_libro_no_existe THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20021, 'Error: No existe el libro con ID ' || v_id_libro_invalido); -- Usamos la variable guardada
            
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE = -20101 THEN
                RAISE;  
            ELSE
                RAISE_APPLICATION_ERROR(-20000, 'Error inesperado: ' || SQLERRM);
            END IF;
    END insert_reserva;


-- AUTOR_LIBRO
    PROCEDURE insert_autor_libro(
        p_id_autor IN NUMBER,
        p_id_libro IN NUMBER
    ) IS
        v_autor_existe NUMBER;
        v_libro_existe NUMBER;
    BEGIN
        -- Validar AUTOR existe
        SELECT COUNT(*) INTO v_autor_existe
        FROM Autor
        WHERE ID_Autor = p_id_autor;
        
        IF v_autor_existe = 0 THEN
            RAISE_APPLICATION_ERROR(-20030, 'Error: No existe el autor con ID ' || p_id_autor);
        END IF;
        
        -- Validar LIBRO existe
        SELECT COUNT(*) INTO v_libro_existe
        FROM Libros
        WHERE ID_Libro = p_id_libro;
        
        IF v_libro_existe = 0 THEN
            RAISE_APPLICATION_ERROR(-20031, 'Error: No existe el libro con ID ' || p_id_libro);
        END IF;
        
        -- Insertar relación
        INSERT INTO Autor_Libro (ID_Autor, ID_Libro)
        VALUES (p_id_autor, p_id_libro);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Relación autor-libro insertada correctamente');
        
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20032, 'Error: Relación autor-libro ya existe');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END insert_autor_libro;
    
-- GENERO_LIBRO
    PROCEDURE insert_genero_libro(
        p_id_genero IN NUMBER,
        p_id_libro IN NUMBER
    ) IS
        v_genero_existe NUMBER;
        v_libro_existe NUMBER;
    BEGIN
        -- Validar GENERO existe
        SELECT COUNT(*) INTO v_genero_existe
        FROM Genero
        WHERE ID_Genero = p_id_genero;
        
        IF v_genero_existe = 0 THEN
            RAISE_APPLICATION_ERROR(-20033, 'Error: No existe el género con ID ' || p_id_genero);
        END IF;
        
        -- Validar LIBRO existe
        SELECT COUNT(*) INTO v_libro_existe
        FROM Libros
        WHERE ID_Libro = p_id_libro;
        
        IF v_libro_existe = 0 THEN
            RAISE_APPLICATION_ERROR(-20034, 'Error: No existe el libro con ID ' || p_id_libro);
        END IF;
        
        -- Insertar relación
        INSERT INTO Genero_Libro (ID_Genero, ID_Libro)
        VALUES (p_id_genero, p_id_libro);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Relación género-libro insertada correctamente');
        
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20035, 'Error: Relación género-libro ya existe');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END insert_genero_libro;
    
-- LIBRO_RESERVA
    PROCEDURE insert_libro_reserva(
        p_id_reserva IN NUMBER,
        p_id_libro IN NUMBER
    ) IS
        v_reserva_existe NUMBER;
        v_libro_existe NUMBER;
        v_inventario_actual NUMBER;
        v_titulo VARCHAR2(200);
    BEGIN
        -- Validar RESERVA existe
        SELECT COUNT(*) INTO v_reserva_existe
        FROM Reservas
        WHERE ID_Reserva = p_id_reserva;
        
        IF v_reserva_existe = 0 THEN
            RAISE_APPLICATION_ERROR(-20036, 'Error: No existe la reserva con ID ' || p_id_reserva);
        END IF;
        
        -- Validar LIBRO existe
        SELECT Inventario, Titulo INTO v_inventario_actual, v_titulo
        FROM Libros
        WHERE ID_Libro = p_id_libro;
        
        -- Insertar relación 
        INSERT INTO Libro_Reserva (ID_Reserva, ID_Libro)
        VALUES (p_id_reserva, p_id_libro);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Libro añadido a la reserva correctamente');
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20037, 'Error: No existe el libro con ID ' || p_id_libro);
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20038, 'Error: El libro indicado ya está en la reserva');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END insert_libro_reserva;
    
END pkg_inserts;
/

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



