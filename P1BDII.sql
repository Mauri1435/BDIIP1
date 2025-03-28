CREATE TABLE Usuario (
    ID_Usuario NUMBER PRIMARY KEY,
    Cedula VARCHAR2(20) UNIQUE NOT NULL,
    Nombre VARCHAR2(50) NOT NULL,
    Apellidos VARCHAR2(100) NOT NULL,
    Numero_Telefonico VARCHAR2(20)
);

CREATE TABLE Administrador (
    ID_Admin NUMBER PRIMARY KEY,
    Cedula VARCHAR2(20) UNIQUE NOT NULL,
    Nombre VARCHAR2(50) NOT NULL,
    Apellidos VARCHAR2(100) NOT NULL
);

CREATE TABLE Editorial (
    ID_Editorial NUMBER PRIMARY KEY,
    Nombre VARCHAR2(100) NOT NULL
);

CREATE TABLE Autor (
    ID_Autor NUMBER PRIMARY KEY,
    Nombre VARCHAR2(50) NOT NULL,
    Apellidos VARCHAR2(100) NOT NULL
);

CREATE TABLE Genero (
    ID_Genero NUMBER PRIMARY KEY,
    Nombre VARCHAR2(50) NOT NULL,
    Descripcion VARCHAR2(255)
);

CREATE TABLE Libros (
    ID_Libro NUMBER PRIMARY KEY,
    Titulo VARCHAR2(200) NOT NULL,
    ISBN VARCHAR2(20) UNIQUE NOT NULL,
    Edad_Recomendada NUMBER,
    Inventario NUMBER NOT NULL,
    ID_Editorial NUMBER,
    FOREIGN KEY (ID_Editorial) REFERENCES Editorial(ID_Editorial)
);

CREATE TABLE Reservas (
    ID_Reserva NUMBER PRIMARY KEY,
    Fecha_Reserva DATE NOT NULL,
    Fecha_Devolucion DATE NOT NULL,
    ID_Usuario NUMBER NOT NULL,
    ID_Libro NUMBER NOT NULL,
    FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario),
    FOREIGN KEY (ID_Libro) REFERENCES Libros(ID_Libro)
);


/*
--Trigger para manejar inventario al añadir o eliminar libros de la reserva
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
                RAISE_APPLICATION_ERROR(-20001, 'Error 20001: No se cuenta con inventario del título' || v_titulo);

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