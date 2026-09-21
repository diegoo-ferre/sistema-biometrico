<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}

String personaIdStr = request.getParameter("persona_id");
String sueldoBaseStr = request.getParameter("sueldo_base");
String montoDescStr = request.getParameter("monto_descuento");
String sueldoFinalStr = request.getParameter("sueldo_final");

Connection con = null;
PreparedStatement ps = null;

try {
    int personaId = Integer.parseInt(personaIdStr);
    double sueldoBase = Double.parseDouble(sueldoBaseStr);
    double montoDesc = Double.parseDouble(montoDescStr);
    double sueldoFinal = Double.parseDouble(sueldoFinalStr);

    Class.forName("org.postgresql.Driver");
    String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
    con = DriverManager.getConnection(url, "neondb_owner", "npg_6rt8OdayAHcm");

    // Obtenemos el mes y el año activos configurados en el panel de administración
    int mesActivo = 0;
    int anioActivo = 0;
    Statement stPeriodo = con.createStatement();
    ResultSet rsPeriodo = stPeriodo.executeQuery("SELECT mes, anio FROM periodo_activo LIMIT 1");
    if (rsPeriodo.next()) {
        mesActivo = rsPeriodo.getInt("mes");
        anioActivo = rsPeriodo.getInt("anio");
    }
    rsPeriodo.close();
    stPeriodo.close();

    // Insertamos los datos incluyendo el mes y el año del período activo
    String sql = "INSERT INTO salarios (persona_id, sueldo_base, monto_descuento, sueldo_final, fecha_registro, mes, anio) VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP, ?, ?)";
    ps = con.prepareStatement(sql);
    ps.setInt(1, personaId);
    ps.setDouble(2, sueldoBase);
    ps.setDouble(3, montoDesc);
    ps.setDouble(4, sueldoFinal);
    ps.setInt(5, mesActivo);
    ps.setInt(6, anioActivo);
    ps.executeUpdate();

    response.sendRedirect("guardar_liquidacion.jsp");

} catch (Exception e) {
    out.println("Error al guardar: " + e.getMessage());
} finally {
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (con != null) try { con.close(); } catch (Exception e) {}
}
%>