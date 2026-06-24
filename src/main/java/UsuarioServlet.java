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

        String accion = request.getParameter("accion");

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:postgresql://localhost:5432/biometrico",
                    "postgres",
                    "1234"
            );

            if ("crear".equals(accion)) {

                String usuario = request.getParameter("usuario");
                String password = request.getParameter("password");
                String rol = request.getParameter("rol");

                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO usuarios(usuario,password,rol) VALUES (?,?,?)"
                );

                ps.setString(1, usuario);
                ps.setString(2, password);
                ps.setString(3, rol);

                ps.executeUpdate();
            }

            con.close();

            response.sendRedirect("usuarios.jsp");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:postgresql://localhost:5432/biometrico",
                    "postgres",
                    "1234"
            );

            if ("eliminar".equals(accion)) {

                int id = Integer.parseInt(request.getParameter("id"));

                PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM usuarios WHERE id=?"
                );

                ps.setInt(1, id);
                ps.executeUpdate();
            }

            con.close();

            response.sendRedirect("usuarios.jsp");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}