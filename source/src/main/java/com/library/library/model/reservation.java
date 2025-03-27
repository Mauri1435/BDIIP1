package com.library.library.model;

public class reservation {
    private int id;
    private int id_book;
    private int id_user;
    private String date_reservation;
    private String date_devolution;

    public reservation(int id, int id_book, int id_user, String date_reservation, String date_devolution) {
        this.id = id;
        this.id_book = id_book;
        this.id_user = id_user;
        this.date_reservation = date_reservation;
        this.date_devolution = date_devolution;
    }
    public int getId() {
        return id;
    }
    public int getId_book() {
        return id_book;
    }
    public int getId_user() {
        return id_user;
    }
    public String getDate_reservation() {
        return date_reservation;
    }
    public String getDate_devolution() {
        return date_devolution;
    }
    
    
}
