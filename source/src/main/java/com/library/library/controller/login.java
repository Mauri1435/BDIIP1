@RestController
@RequestMapping("/login")
public class login {
    
    @GetMapping("/login")
    public String showLogin(Model model) {
        model.addAttribute("login", new Login());
        return "login";
    }

    @PostMapping("/login")
    public String checkLogin(@ModelAttribute("login") Login login, Model model) {
        if (login.getUsername().equals("admin") && login.getPassword().equals("admin")) {
            return "redirect:/libros";
        } else {
            model.addAttribute("error", "Usuario o contraseña incorrectos");
            return "login";
        }
    }
    
}
