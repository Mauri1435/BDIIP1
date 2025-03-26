package main.java.com.library.library.model;

import java.util.Scanner;
import java.util.List;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


public class users {

    private Connection connection;

    public users(String login, String password) {
        Connection conn = checkCredentials(login, password);
        if (conn = null) {
            raise Exception ("Credenciales incorrectas");
        } else {
            this.connection = conn;
    }

    private void checkCredentials(String login, String password) {
        if (login.equals("admin") && password.equals("admin")) {
            System.out.println("Login successful");
        } else {
            System.out.println("Login failed");
        }
        this.name = name;

        private static final String URL = "jdbc:mysql://localhost:3306/mi_base_de_datos";
        private static final String USER = "mi_usuario";
        private static final String PASSWORD = "mi_contrasena";
    
        public static void main(String[] args) {
            Connection connection = null;
            PreparedStatement statement = null;
            ResultSet resultSet = null;
    
            try {
                // Establecer la conexión con la base de datos
                connection = DriverManager.getConnection(URL, USER, PASSWORD);
    
                // Crear una consulta SQL
                String sql = "SELECT * FROM usuarios WHERE correo = ? AND contrasena = ?";
                statement = connection.prepareStatement(sql);
    
                // Establecer los valores de los parámetros de la consulta
                statement.setString(1, "usuario@example.com");
                statement.setString(2, "123456");
    
                // Ejecutar la consulta
                resultSet = statement.executeQuery();
    
                // Verificar si el usuario existe
                if (resultSet.next()) {
                    System.out.println("¡Usuario autenticado exitosamente!");
                } else {
                    System.out.println("Credenciales incorrectas.");
                }
    
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                try {
                    // Cerrar los recursos
                    if (resultSet != null) resultSet.close();
                    if (statement != null) statement.close();
                    if (connection != null) connection.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    }
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
