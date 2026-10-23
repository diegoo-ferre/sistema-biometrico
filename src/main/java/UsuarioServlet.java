import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.sql.*;

@WebServlet("/UsuarioServlet")
public class UsuarioServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");

        Connection con = null;
        try {
            Class.forName("org.postgresql.Driver");
            String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
            String user = "neondb_owner";
            String pass = "npg_6rt8OdayAHcm";

            con = DriverManager.getConnection(url, user, pass);

            if ("crear".equals(accion)) {
                String usuario = request.getParameter("usuario");
                String password = request.getParameter("password");
                String rol = request.getParameter("rol");

                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO usuarios (usuario, password, rol) VALUES (?, ?, ?)"
                );

                ps.setString(1, usuario);
                ps.setString(2, password);
                ps.setString(3, rol);

                ps.executeUpdate();
                ps.close();
            }

            response.sendRedirect("usuarios.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("usuarios.jsp?error=1");
        } finally {
            try {
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");

        Connection con = null;
        try {
            Class.forName("org.postgresql.Driver");
            String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
            String user = "neondb_owner";
            String pass = "npg_6rt8OdayAHcm";

            con = DriverManager.getConnection(url, user, pass);

            if ("eliminar".equals(accion)) {
                int id = Integer.parseInt(request.getParameter("id"));

                PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM usuarios WHERE id = ?"
                );

                ps.setInt(1, id);
                ps.executeUpdate();
                ps.close();
            }

            response.sendRedirect("usuarios.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("usuarios.jsp?error=1");
        } finally {
            try {
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
