package com.library.library.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.List;
import java.util.ArrayList;

import com.library.library.model.book;


@RequestMapping("/libros")
public class reserve {

    private login loginInstance = login.getInstance();

    @GetMapping
    public ResponseEntity<?> getBooks(String name, String author, String editorial, String type) {
        try{
            Connection connection = loginInstance.getConnection(loginInstance.getToken());
            Statement statement = connection.createStatement();
            String query = "SELECT * FROM libros JOIN WHERE";
            if (name != null) {
                query += " titulo = '" + name + "'";
            }
            if (author != null) {
                query += " nombre_autor = '" + author + "'";
            }
            if (editorial != null) {
                query += " editorial = '" + editorial + "'";
            }
            if (type != null) {
                query += " genere = '" + type + "'";
            }
            ResultSet resultSet = statement.executeQuery(query);
            List<book> books = new ArrayList<book>();
            while (resultSet.next()) {
                book book = new book(resultSet.getInt("id"),resultSet.getString("titulo"), resultSet.getString("nombre_autor"), resultSet.getString("genere"), resultSet.getInt("restriccion_edad"), resultSet.getInt("isbn"), resultSet.getInt("cantidad"), resultSet.getString("editorial"));
                books.add(book);
            }
            return ResponseEntity.ok(books);
        }catch (SQLException e){
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body("No se encontraron libros disponibles.");
        }
    }

    @PostMapping("/reserve/{BookId}")
    public ResponseEntity<?> reserveBook(@PathVariable("BookId") Long bookId) {
        try{
            Connection connection = loginInstance.getConnection(loginInstance.getToken());
            CallableStatement statement = connection.prepareCall("CALL reserveBook(?)");
            statement.setLong(1, bookId);
            return ResponseEntity.ok("Libro reservado con éxito");
        } catch (SQLException e) {
            return ResponseEntity.badRequest().body("No se puede reservar el libro");
        }
    }

  
}