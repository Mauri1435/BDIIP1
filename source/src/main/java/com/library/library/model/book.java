package com.library.library.model;

public class book {
    private Integer id;
    private String title;
    private String author;
    private String type;
    private Integer age_restriction;
    private Integer isbn;
    private Integer quantity;
    private String editorial;

    public book(Integer id, String title, String author, String type, Integer age_restriction, Integer isbn, Integer quantity, String editorial) {
        this.id = id;
        this.title = title;
        this.author = author;
        this.type = type;
        this.age_restriction = age_restriction;
        this.isbn = isbn;
        this.quantity = quantity;
        this.editorial = editorial;
    }
    public Integer getId() {
        return id;
    }
    public String getTitle() {
        return title;
    }
    public String getAuthor() {
        return author;
    }
    public String getType() {
        return type;
    }
    public Integer getAge_restriction() {
        return age_restriction;
    }
    public Integer getIsbn() {
        return isbn;
    }
    public Integer getQuantity() {
        return quantity;
    }
    public String getEditorial() {
        return editorial;
    }

    
}
