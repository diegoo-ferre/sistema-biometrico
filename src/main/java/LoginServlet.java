import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String usuarioInput = request.getParameter("usuario");
        String password = request.getParameter("password");

        if (usuarioInput == null || password == null ||
            usuarioInput.trim().isEmpty() || password.trim().isEmpty()) {
            response.sendRedirect("login.jsp?error=1");
            return;
        }

        usuarioInput = usuarioInput.trim();
        password = password.trim();

        Connection con = null;

        try {
            Class.forName("org.postgresql.Driver");
            String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
            String user = "neondb_owner";
            String pass = "npg_6rt8OdayAHcm";

            con = DriverManager.getConnection(url, user, pass);

            // Seleccionamos también la columna 'usuario' real de la BD
            String sql = "SELECT usuario, rol, ci FROM usuarios WHERE (LOWER(TRIM(usuario)) = LOWER(TRIM(?)) OR TRIM(ci) = TRIM(?)) AND password = ?";
            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, usuarioInput);
            ps.setString(2, usuarioInput);
            ps.setString(3, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String usuarioReal = rs.getString("usuario"); // El nombre exacto guardado en la BD
                String rol = rs.getString("rol");
                String ci = rs.getString("ci");

                HttpSession session = request.getSession();
                session.setAttribute("usuario", usuarioReal); // Guardamos el nombre real de la BD en la sesión
                session.setAttribute("rol", rol);
                session.setAttribute("ci", ci);

                if ("admin".equalsIgnoreCase(rol)) {
                    response.sendRedirect("admin.jsp");
                } else {
                    response.sendRedirect("empleado_dashboard.jsp");
                }
            } else {
                response.sendRedirect("login.jsp?error=1");
            }

            rs.close();
            ps.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=2");
        } finally {
            try {
                if (con != null) {
                    con.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
