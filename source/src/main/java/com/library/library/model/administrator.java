package com.library.library.model;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.springframework.beans.factory.annotation.Value;

public class administrator {

    @Value("${db.url}")
    private String url;
    private Connection connection;
    public String cedula;
    public String nombre;
    public String apellido;
    public String telefono;
    public String Login;

    public administrator(String Login, String password) {
        try {
            this.connection =  checkCredentials(Login, password);
            setUserData();
        } catch (SQLException e) {
            throw new RuntimeException("No se pudo iniciar sesión", e);
        }
    }

    private Connection checkCredentials(String login, String password) throws SQLException {
        return DriverManager.getConnection(url, login, password);
    }

    public void close() {
        try {
            connection.close();
        } catch (SQLException e) {
            throw new RuntimeException("No se pudo cerrar la conexión", e);
        }
    }

    public Boolean registerUser(String cedula, String nombre, String apellido, String telefono, String Login, String password) {
        try {
            CallableStatement statement = connection.prepareCall("CALL registerAdmin(?, ?, ?, ?, ?, ?)");
            statement.setString(1, cedula);
            statement.setString(2, nombre);
            statement.setString(3, apellido);
            statement.setString(1, Login);
            statement.setString(2, password);
            statement.executeUpdate();
            return true;
        } catch (SQLException e) {
            throw new RuntimeException("No se pudo registrar el usuario", e);
        }
    }

    private void setUserData() {
        try {
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery("SELECT * FROM administrador WHERE id_usuario = USER");
            while (resultSet.next()) {
                this.cedula = resultSet.getString("cedula");
                this.nombre = resultSet.getString("nombre");
                this.apellido = resultSet.getString("apellido");
            }
        } catch (SQLException e) {
            throw new RuntimeException("No se pudo obtener los datos del usuario", e);
        }
    }


    
}