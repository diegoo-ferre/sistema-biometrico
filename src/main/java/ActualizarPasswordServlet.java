import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/ActualizarPasswordServlet")
public class ActualizarPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        
        // 1. Verificar si hay sesión activa
        String nombreUsuario = (String) session.getAttribute("usuario");
        if (nombreUsuario == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Obtener los parámetros enviados desde el formulario
        String passwordActual = request.getParameter("passwordActual");
        String nuevoPassword = request.getParameter("nuevoPassword");
        String confirmarPassword = request.getParameter("confirmarPassword");

        // 3. Validar que las contraseñas nuevas coincidan
        if (nuevoPassword == null || !nuevoPassword.equals(confirmarPassword)) {
            response.sendRedirect("cambiar_password.jsp?error=noCoinciden");
            return;
        }

        // 4. Configuración exacta de la conexión a Neon con tus credenciales
        String URL = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
        String USER = "neondb_owner";
        String PASS = "npg_6rt8OdayAHcm";

        try {
            Class.forName("org.postgresql.Driver");
            Connection conn = DriverManager.getConnection(URL, USER, PASS);

            // 5. Verificar la contraseña actual en la tabla "usuarios"
            String sqlVerificar = "SELECT * FROM usuarios WHERE usuario = ? AND password = ?";
            PreparedStatement pstmtVerificar = conn.prepareStatement(sqlVerificar);
            pstmtVerificar.setString(1, nombreUsuario);
            pstmtVerificar.setString(2, passwordActual);
            ResultSet rs = pstmtVerificar.executeQuery();

            if (rs.next()) {
                rs.close();
                pstmtVerificar.close();

                // 6. Si es correcta, actualizamos con el nuevo password
                String sqlActualizar = "UPDATE usuarios SET password = ? WHERE usuario = ?";
                PreparedStatement pstmtActualizar = conn.prepareStatement(sqlActualizar);
                pstmtActualizar.setString(1, nuevoPassword);
                pstmtActualizar.setString(2, nombreUsuario);
                pstmtActualizar.executeUpdate();

                pstmtActualizar.close();
                conn.close();

                // CORREGIDO: Redirigir de vuelta a cambiar_password.jsp para que muestre el mensaje verde en su lugar
                response.sendRedirect("cambiar_password.jsp?exito=passwordActualizado");
            } else {
                // Si la contraseña actual no coincide
                rs.close();
                pstmtVerificar.close();
                conn.close();
                response.sendRedirect("cambiar_password.jsp?error=actualIncorrecto");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("cambiar_password.jsp?error=excepcion");
        }
    }
}