<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
// 1. Verificar sesión
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}

// 2. Recibir los datos del formulario
String personaId = request.getParameter("persona_id");
String sueldoBase = request.getParameter("sueldo_base");
String montoDescuento = request.getParameter("monto_descuento");
String sueldoFinal = request.getParameter("sueldo_final");
String motivo = request.getParameter("motivo");
String mes = request.getParameter("mes");
String anio = request.getParameter("anio");

Connection con = null;
PreparedStatement ps = null;

try {
    // 3. Conexión a la BD
    Class.forName("org.postgresql.Driver");
    String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
    con = DriverManager.getConnection(url, "neondb_owner", "npg_6rt8OdayAHcm");

    // 4. Lógica UPSERT: Intentar actualizar primero
    String sqlUpdate = "UPDATE salarios SET sueldo_base = ?, monto_descuento = ?, sueldo_final = ?, motivo_descuento = ?, fecha_registro = CURRENT_TIMESTAMP " +
                       "WHERE persona_id = ? AND mes = ? AND anio = ?";
    
    ps = con.prepareStatement(sqlUpdate);
    ps.setDouble(1, Double.parseDouble(sueldoBase));
    ps.setDouble(2, Double.parseDouble(montoDescuento));
    ps.setDouble(3, Double.parseDouble(sueldoFinal));
    ps.setString(4, motivo);
    ps.setInt(5, Integer.parseInt(personaId));
    ps.setInt(6, Integer.parseInt(mes));
    ps.setInt(7, Integer.parseInt(anio));

    int filasAfectadas = ps.executeUpdate();
    ps.close(); // Cerrar para reutilizar la variable

    // 5. Si no se actualizó nada, entonces insertar
    if (filasAfectadas == 0) {
        String sqlInsert = "INSERT INTO salarios (persona_id, sueldo_base, monto_descuento, sueldo_final, motivo_descuento, mes, anio, fecha_registro) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
        
        ps = con.prepareStatement(sqlInsert);
        ps.setInt(1, Integer.parseInt(personaId));
        ps.setDouble(2, Double.parseDouble(sueldoBase));
        ps.setDouble(3, Double.parseDouble(montoDescuento));
        ps.setDouble(4, Double.parseDouble(sueldoFinal));
        ps.setString(5, motivo);
        ps.setInt(6, Integer.parseInt(mes));
        ps.setInt(7, Integer.parseInt(anio));
        
        ps.executeUpdate();
    }

    // 6. Redireccionar
    response.sendRedirect("editar_salario_guardado.jsp?mensaje=GuardadoExitoso");

} catch (Exception e) {
    out.println("Error al guardar: " + e.getMessage());
} finally {
    if (ps != null) ps.close();
    if (con != null) con.close();
}
%>