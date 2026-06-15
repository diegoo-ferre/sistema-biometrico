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

        String usuario = request.getParameter("usuario");
        String password = request.getParameter("password");

        if (usuario == null || password == null ||
            usuario.trim().isEmpty() || password.trim().isEmpty()) {

            response.sendRedirect("login.jsp?error=1");
            return;
        }

        usuario = usuario.trim();
        password = password.trim();

        Connection con = null;

        try {

            Class.forName("org.postgresql.Driver");

            String url =
                "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";

            String user = "neondb_owner";
            String pass = "npg_6rt8OdayAHcm";

            con = DriverManager.getConnection(url, user, pass);

            String sql =
                "SELECT * FROM usuarios WHERE usuario=? AND password=?";

            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, usuario);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                String rol = rs.getString("rol");

                HttpSession session = request.getSession();

                session.setAttribute("usuario", usuario);
                session.setAttribute("rol", rol);

                if ("admin".equalsIgnoreCase(rol)) {

                    response.sendRedirect("admin.jsp");

                } else {

                    response.sendRedirect("index.jsp");
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