package com.library.library.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

//Database models
import com.library.library.model.users;


@RestController
@RequestMapping("/api/auth")
public class Login {

    public static Login instance;
    private Map<String,users> sessionConns = new HashMap<String,users>();

    private Login() {
    }
    
    @PostMapping("/login")
    public ResponseEntity<String> authLogin(@RequestBody LoginRequest request, HttpSession session) {
        try {
            users sessionConn = new users(request.getUsername(), request.getPassword());
            String jwtToken = new jwtService().generateToken(request.getUsername());
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

    public static synchronized Login getInstance() {
        if (instance == null) {
            instance = new Login();
        }
        return instance;
    }

    public void addLogin(String token,users sessionConn) {
        this.sessionConns.put(token, sessionConn);
    }

    public Connection getConnection(String id){
        return this.sessionConns.get(id).getConnection();
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout(HttpServletRequest request, HttpServletResponse response) {
        Cookie cookie = new Cookie("jwt_token", null);
        cookie.setMaxAge(0);
        cookie.setPath("/");
        response.addCookie(cookie);
        return ResponseEntity.ok("Logout exitoso");
    }

    public String getToken(HttpServletRequest request) {    
        String token = null;
        Cookie[] cookies = request.getCookies();
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
