//package main.java.com.library.library.model;

import java.util.Scanner;
import java.util.List;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.hibernate.annotations.processing.SQL;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import javax.sql.DataSource;


public class users {

    @Value("${db.url}")
    private String url;
    private final DataSource Datasource;
    private Connection connection;
    private String id;
    public String cedula;
    public String nombre;
    public String apellido;
    public String telefono;
    public String login;


    public users(String login, String password) throws SQLException {
        try {
            this.connection =  checkCredentials(login, password);
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

    public Boolean registerUser(String cedula, String nombre, String apellido, String telefono, String login, String password) {
        try {
            CallableStatement statement = connection.prepareCall("CALL registerUser(?, ?, ?, ?, ?, ?)");
            statement.setString(1, cedula);
            statement.setString(2, nombre);
            statement.setString(3, apellido);
            statement.setString(4, telefono);
            statement.setString(1, login);
            statement.setString(2, password);
            statement.executeUpdate();
            return true;
        } catch (SQLException e) {
            throw new RuntimeException("No se pudo registrar el usuario", e);
        }
    }

    private void setUserData() {
        java.sql.Statement statement = connection.createStatement();
        ResultSet resultSet = statement.executeQuery("SELECT * FROM usuario WHERE id_usuario = USER");
        while (resultSet.next()) {
            this.cedula = resultSet.getString("cedula");
            this.nombre = resultSet.getString("nombre");
            this.apellido = resultSet.getString("apellido");
            this.telefono = resultSet.getString("telefono");
            this.login = resultSet.getString("login");
        }
    }

    public String getID(){
        return this.id;
    }

    public Connection getConnection() {
        return this.connection;
    }





}
