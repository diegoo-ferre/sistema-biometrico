<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
// 1. Verificar sesión
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}

// 2. Obtener parámetros directamente con manejo de seguridad integrado
String pId = request.getParameter("persona_id");
String sBase = request.getParameter("sueldo_base");
String mDesc = request.getParameter("monto_descuento");
String sFinal = request.getParameter("sueldo_final");
String motivo = request.getParameter("motivo");

// Validar que no sean nulos antes de convertir
int personaId = (pId != null && !pId.isEmpty()) ? Integer.parseInt(pId) : 0;
double sueldoBase = (sBase != null && !sBase.isEmpty()) ? Double.parseDouble(sBase) : 0.0;
double montoDescuento = (mDesc != null && !mDesc.isEmpty()) ? Double.parseDouble(mDesc) : 0.0;
double sueldoFinal = (sFinal != null && !sFinal.isEmpty()) ? Double.parseDouble(sFinal) : 0.0;

if (motivo == null || motivo.trim().isEmpty()) {
    motivo = "Sin detalles";
}

Connection con = null;
PreparedStatement ps = null;

try {
    // 3. Conexión a la BD
    Class.forName("org.postgresql.Driver");
    String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
    con = DriverManager.getConnection(url, "neondb_owner", "npg_6rt8OdayAHcm");

    // 4. Insertar el registro
    String sql = "INSERT INTO salarios (persona_id, sueldo_base, porcentaje_descuento, monto_descuento, sueldo_final, motivo_descuento, fecha_registro) VALUES (?, ?, 0, ?, ?, ?, CURRENT_TIMESTAMP)";
    
    ps = con.prepareStatement(sql);
    ps.setInt(1, personaId);
    ps.setDouble(2, sueldoBase);
    ps.setDouble(3, montoDescuento);
    ps.setDouble(4, sueldoFinal);
    ps.setString(5, motivo);
    
    ps.executeUpdate();
    
    // 5. Redireccionar
    response.sendRedirect("editar_salario_guardado.jsp?mensaje=GuardadoExitoso");

} catch (Exception e) {
    out.println("Error al guardar: " + e.getMessage());
} finally {
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (con != null) try { con.close(); } catch (Exception e) {}
}
%>