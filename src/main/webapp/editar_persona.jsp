<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
String id = request.getParameter("id");
String nombre = "", ci = "";
String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
String dbUser = "neondb_owner";
String dbPass = "npg_6rt8OdayAHcm";

// REEMPLAZA tu bloque POST actual con este código robusto:
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String nuevoNombre = request.getParameter("nombre");
    String nuevaCi = request.getParameter("ci");
    
    try (Connection conn = DriverManager.getConnection(url, "neondb_owner", "npg_6rt8OdayAHcm")) {
        conn.setAutoCommit(false); // 1. Iniciamos transacción: Todo o nada

        // 2. Buscamos la CI que tiene actualmente (la "vieja") usando el ID
        String ciAntigua = "";
        try (PreparedStatement psSel = conn.prepareStatement("SELECT ci FROM personas WHERE id=?")) {
            psSel.setInt(1, Integer.parseInt(id));
            ResultSet rs = psSel.executeQuery();
            if (rs.next()) ciAntigua = rs.getString("ci");
        }

        // 3. Actualizamos la persona
        try (PreparedStatement psP = conn.prepareStatement("UPDATE personas SET nombre=?, ci=? WHERE id=?")) {
            psP.setString(1, nuevoNombre);
            psP.setString(2, nuevaCi);
            psP.setInt(3, Integer.parseInt(id));
            psP.executeUpdate();
        }

        // 4. Actualizamos el usuario usando la CI antigua como referencia
        try (PreparedStatement psU = conn.prepareStatement("UPDATE usuarios SET usuario=?, password=?, ci=? WHERE ci=?")) {
            psU.setString(1, nuevoNombre); // Nombre nuevo
            psU.setString(2, nuevaCi);     // CI nueva como pass
            psU.setString(3, nuevaCi);     // CI nueva
            psU.setString(4, ciAntigua);   // Buscamos por la vieja para no perderlo
            psU.executeUpdate();
        }

        conn.commit(); // 5. Si todo salió bien, guardamos los cambios en ambas tablas
        response.sendRedirect("lista.jsp");
        return;
    } catch (Exception e) {
        // Si algo falla, el sistema no hace nada y evita inconsistencias
    }
}

try (Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
     PreparedStatement ps = conn.prepareStatement("SELECT * FROM personas WHERE id=?")) {
    ps.setInt(1, Integer.parseInt(id));
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
        nombre = rs.getString("nombre");
        ci = rs.getString("ci");
    }
}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Editar Persona</title>
    <style>
        body { background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); color: white; display:flex; justify-content:center; align-items:center; min-height:100vh; font-family: Arial, sans-serif; margin: 0; }
        .contenedor { background: rgba(10, 15, 25, 0.9); padding: 40px; border-radius: 30px; width: 100%; max-width: 400px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        h2 { margin-bottom: 25px; }
        input { width: 100%; padding: 12px; margin: 10px 0; border-radius: 15px; border: none; outline: none; background: rgba(255,255,255,0.05); color: white; }
        
        /* Tu diseño exacto para botones principales */
        .btn-custom { display: block; width: 100%; max-width: 360px; margin: 15px auto; padding: 12px; border: none; border-radius: 30px; color: white; font-weight: bold; text-decoration: none; transition: 0.3s; background: linear-gradient(30deg, #4225a3, #000738); cursor: pointer; }
        .btn-custom:hover { transform: scale(1.03); color: white; text-decoration: none; }
        
        /* Estilo rojo para cancelar (basado en tu botón eliminar) */
        .btn-cancelar { display: block; width: 100%; max-width: 360px; margin: 15px auto; padding: 12px; border: none; border-radius: 30px; color: white; font-weight: bold; text-decoration: none; transition: 0.3s; background: linear-gradient(35deg, #f74040, #f50404); cursor: pointer; text-align: center; }
        .btn-cancelar:hover { transform: scale(1.03); color: white; text-decoration: none; }
    </style>
</head>
<body>
    <div class="contenedor">
        <h2>Editar Registro</h2>
        <form method="post">
            <input type="text" name="nombre" value="<%= nombre %>" required placeholder="Nombre">
            <input type="text" name="ci" value="<%= ci %>" required placeholder="CI">
            <button type="submit" class="btn-custom">Guardar Cambios</button>
            <a href="lista.jsp" class="btn-cancelar">Cancelar</a>
        </form>
    </div>
</body>
</html>