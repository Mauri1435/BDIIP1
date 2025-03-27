package com.library.library.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.util.ArrayList;

import com.library.library.model.users;
import com.library.library.model.type;
import com.library.library.model.book;
import com.library.library.model.author;
import com.library.library.model.editorial;
import com.library.library.model.reservation;

@Controller
@RequestMapping("/login")
public class login {

    public users user;
    public ArrayList<type> types;
    public ArrayList<book> books;
    public ArrayList<author> authors;
    public ArrayList<editorial> editorials;
    public ArrayList<reservation> reservations;
    
    @GetMapping("/login")
    public String showLogin(Model model) {
        model.addAttribute("login", new login());
        return "login";
    }

    @PostMapping("/login")
    public String checkLogin(@ModelAttribute("login") login login, Model model) {
        try{
            users user = new users(login.getLogin(), login.getPassword());
        }catch(Exception e){
            model.addAttribute("error", "Usuario o contraseña incorrectos");
            return "login";
        }
        
    }
    
}
