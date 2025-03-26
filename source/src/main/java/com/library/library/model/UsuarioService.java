import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UsuarioService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public boolean validarUsuario(String correo, String contrasena) {
        String sql = "SELECT COUNT(*) FROM usuarios WHERE correo = ? AND contrasena = ?";
        int count = jdbcTemplate.queryForObject(sql, Integer.class, correo, contrasena);
        return count > 0;
    }
}