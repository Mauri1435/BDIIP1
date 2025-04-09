package com.library.library.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.http.RequestEntity;
import org.springframework.http.HttpStatus;
import jakarta.servlet.http.*;
import javax.servlet.ServletRequest;
import java.sql.Connection;
import java.sql.CallableStatement;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.List;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;


import com.library.library.model.users;
import com.library.library.model.book;


@RestController
@RequestMapping("/api/auth")
public class config {

    private login loginInstance = login.getInstance();

    @PostMapping("/addBook")
    public ResponseEntity<?> addBook(@RequestBody List<book> books) {
        try {
            Connection conn = loginInstance.getConnection(loginInstance.getToken());
            CallableStatement statement = conn.prepareCall("CALL addBook(?, ?, ?, ?, ?, ?, ?)");
            for (book book:books){
                statement.setString(1, book.getTitle());
                statement.setString(2, book.getAuthor());
                statement.setString(3, book.getType());
                statement.setInt(4, book.getAge_restriction());
                statement.setInt(5, book.getIsbn());
                statement.setInt(6, book.getQuantity());
                statement.setString(7, book.getEditorial());
                statement.addBatch();
            }
            statement.executeBatch();
            return ResponseEntity.ok("Libros añadidos con éxito");
        } catch (SQLException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Error al añadir libros: " + e.getMessage());
        }
    }

    
}
