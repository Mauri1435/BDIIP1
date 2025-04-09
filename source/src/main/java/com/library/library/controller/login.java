package com.library.library.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.http.RequestEntity;
import org.springframework.http.HttpStatus;
import jakarta.servlet.http.*;
import javax.servlet.ServletRequest;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;


import com.library.library.model.users;

@RestController
@RequestMapping("/api/auth")
public class login {

    public static login instance;
    private Map<String,users> sessionConns = new HashMap<String,users>();

    private login(users sessionConn) {
        if (sessionConn != null) {
            this.sessionConns.put(sessionConn.getID(), sessionConn);
        }
    }
    
    @PostMapping("/login")
    public ResponseEntity<String> authLogin(@RequestBody LoginRequest request, HttpSession session) {
        try {
            users sessionConn = new users(request.getUsername(), request.getPassword());
            String jwtToken = jwtService.generateToken(request.getUsername());
            Cookie cookie = new Cookie("jwt_token", jwtToken);
            cookie.setHttpOnly(true);
            cookie.setPath("/");
            cookie.setMaxAge(60 * 60);
            getInstance().addLogin(jwtToken,sessionConn);

            session.setAttribute("dbUsername", request.getUsername());
            return ResponseEntity.ok("Login exitoso");
        } catch (SQLException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login fallido: " + e.getMessage());
        }
    }

    public static login getInstance() {
        if (instance == null) {
            instance = new login(null);
        }
        return instance;
    }

    public void addLogin(String token,users sessionConn) {
        this.sessionConns.put(token, sessionConn);
    }

    public Connection getConnection(String id){
        return this.sessionConns.get(id).getConnection();
    }

    public String getToken(){    
        String token = null;
        Cookie[] cookies = httpRequest.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("jwt_token".equals(cookie.getName())) {
                    token = cookie.getValue();
                }
            }
        }
        return token;
    }
}
