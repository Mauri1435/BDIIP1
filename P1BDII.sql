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
