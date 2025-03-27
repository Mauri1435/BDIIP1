package com.library.library.model;

public class author {
    private int id;
    private String name;
    private String last_name;
    
    public author(int id, String name, String last_name) {
        this.id = id;
        this.name = name;
        this.last_name = last_name;
    }

    public Integer getID() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getLast_name() {
        return last_name;
    }
    
}
