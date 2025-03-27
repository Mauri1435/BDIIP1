package com.library.library.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.sql.Statement;
import java.util.ArrayList;

import com.library.library.model.book;
import com.library.library.model.reservation;

@RequestMapping("/libros")
public class reserve {

    @PostMapping
    public ArrayList<book> getBooks(String name, String author, String editorial, String type) {
        Statement statement = new Statement("SELECT * FROM usuario WHERE id_usuario = USER");
        ArrayList<book> books = statement.getBooks(name, author, editorial, type);
        return books;
    }

    @PostMapping("/reserve/{BookId}/user/{user_id}")
    public ResponseEntity<Libro> reserveBook(@PathVariable("BookId"t) Long bookId, @PathVariable("user_id") Long userId) {
        boolean reserve = libroService.reserveBook(bookId, userId);
        if (reserve) {
            return ResponseEntity.ok("Libro reservado con éxito");
        }else{
            return ResponseEntity.badRequest().body("No se puede reservar el libro");
        }
    }
}