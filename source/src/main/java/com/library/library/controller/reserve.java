@RestController

@RequestMapping("/libros")
public class reserve {
    private final LibroService libroService;

    public reserve(LibroService libroService) {
        this.libroService = libroService;
    }

    @GetMapping
    public List<Libro> listarLibros() {
        return libroService.listarLibros();
    }

    @PostMapping("/reserve/{BookId}/user/{user_id}")
    public ResponseEntity<Libro> reserveBook(@PathVariable("BookId") Long bookId, @PathVariable("user_id") Long userId) {
        boolean reserve = libroService.reserveBook(bookId, userId);
        if (reserve) {
            return ResponseEntity.ok("Libro reservado con éxito");
        }else{
            return ResponseEntity.badRequest().body("No se puede reservar el libro");
        }
    }
}