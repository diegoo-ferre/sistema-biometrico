<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires", 0);

if (session == null || session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}

String usuarioLogueado = (String) session.getAttribute("usuario");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Justificativos y Reportes | Sistema Biométrico</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        :root {
            --bg-main: #030712;
            --sidebar-bg: rgba(10, 15, 25, 0.95);
            --card-bg: rgba(17, 24, 39, 0.75);
            --border-color: rgba(255, 255, 255, 0.08);
            --accent-glow: rgba(99, 102, 241, 0.15);
        }

        body { margin: 0; min-height: 100vh; background: var(--bg-main); font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #f8fafc; display: flex; overflow-x: hidden; }
        
        .sidebar { width: 280px; background: var(--sidebar-bg); padding: 20px; border-right: 1px solid var(--border-color); height: 100vh; position: fixed; overflow-y: auto; z-index: 100; backdrop-filter: blur(10px); }
        .sidebar::-webkit-scrollbar { width: 6px; }
        .sidebar::-webkit-scrollbar-track { background: rgba(0, 0, 0, 0.1); }
        .sidebar::-webkit-scrollbar-thumb { background: rgba(99, 102, 241, 0.3); border-radius: 10px; }

        .sidebar-brand { font-size: 16px; font-weight: bold; color: #fff; text-align: center; margin-bottom: 25px; padding-bottom: 15px; border-bottom: 1px solid var(--border-color); letter-spacing: 0.5px; }
        .sidebar-brand i { color: #818cf8; margin-right: 8px; }
        
        .menu-seccion { font-size: 10px; text-transform: uppercase; color: #64748b; font-weight: 700; margin-top: 20px; margin-bottom: 8px; letter-spacing: 1.2px; padding-left: 5px; }
        
        .sub-menu a { display: flex; align-items: center; color: #94a3b8; padding: 10px 14px; text-decoration: none; font-size: 13px; border-radius: 8px; transition: all 0.25s ease; margin-bottom: 3px; font-weight: 500; }
        .sub-menu a i { width: 20px; margin-right: 10px; font-size: 14px; color: #64748b; transition: 0.25s; }
        .sub-menu a:hover { color: #ffffff !important; background: rgba(99, 102, 241, 0.2); text-decoration: none; transform: translateX(4px); }
        .sub-menu a:hover i { color: #ffffff !important; }

        .btn-cerrar { 
            background: linear-gradient(35deg, #f74040, #f50404); 
            border: none; 
            border-radius: 25px; 
            padding: 12px 24px; 
            color: white; 
            font-weight: bold; 
            text-decoration: none; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            margin-top: 25px; 
            box-shadow: 0 4px 12px rgba(247, 64, 64, 0.3);
            transition: 0.2s;
        }
        .btn-cerrar i { margin-right: 8px; color: white !important; }
        .btn-cerrar:hover { color: white; text-decoration: none; opacity: 0.9; transform: translateY(-1px); }

        .main-content { margin-left: 280px; padding: 35px; flex-grow: 1; display: flex; flex-direction: column; }
        
        .topbar { display: flex; justify-content: space-between; align-items: center; background: var(--card-bg); padding: 15px 30px; border-radius: 16px; border: 1px solid var(--border-color); margin-bottom: 30px; backdrop-filter: blur(10px); }
        .topbar h2 { font-size: 20px; font-weight: 600; margin: 0; color: #f1f5f9; }
        .user-badge { display: flex; align-items: center; font-size: 14px; color: #94a3b8; background: rgba(255,255,255,0.03); padding: 6px 14px; border-radius: 30px; border: 1px solid var(--border-color); }
        .user-badge i { color: #818cf8; margin-right: 8px; }

        .content-card { background: var(--card-bg); border-radius: 16px; border: 1px solid var(--border-color); padding: 25px; box-shadow: 0 10px 25px -5px rgba(0,0,0,0.3); }
        .content-card h4 { font-size: 16px; font-weight: 600; margin-bottom: 20px; color: #f1f5f9; display: flex; align-items: center; }
        .content-card h4 i { margin-right: 10px; color: #818cf8; }

        .table { color: #cbd5e1; margin-bottom: 0; font-size: 14px; }
        .table th { border-top: none; border-bottom: 1px solid var(--border-color); color: #64748b; font-weight: 600; text-transform: uppercase; font-size: 11px; letter-spacing: 0.5px; }
        .table td { border-top: 1px solid var(--border-color); vertical-align: middle; padding: 12px 8px; color: #cbd5e1 !important; }
        .table-hover tbody tr:hover { background-color: rgba(255, 255, 255, 0.03); color: #cbd5e1 !important; }
        .table-hover tbody tr:hover td { color: #f1f5f9 !important; }

        /* Estilo lila degradado para el botón de acción */
        .btn-lila-action {
            background: linear-gradient(30deg, #4225a3, #000738);
            border: none;
            border-radius: 20px;
            padding: 6px 14px;
            color: white;
            font-size: 12px;
            font-weight: bold;
            text-decoration: none;
            transition: 0.2s ease;
            box-shadow: 0 4px 10px rgba(66, 37, 163, 0.3);
        }
        .btn-lila-action:hover {
            color: white;
            text-decoration: none;
            opacity: 0.9;
            transform: translateY(-1px);
        }

        .fondo-animado { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: -1; overflow: hidden; pointer-events: none; }
        .logo-flotante { position: absolute; width: 70px; opacity: 0.03; animation: flotar linear infinite; }
        .logo-flotante:nth-child(1) { top: 10%; left: 10%; animation-duration: 30s; }
        .logo-flotante:nth-child(2) { top: 70%; left: 80%; animation-duration: 40s; }
        .logo-flotante:nth-child(3) { top: 40%; left: 50%; animation-duration: 35s; }
        @keyframes flotar {
            0% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(40px) rotate(5deg); }
            100% { transform: translateY(0) rotate(0deg); }
        }
    </style>
</head>
<body>

<div class="fondo-animado">
    <img src="img/loogoproyecto.png" class="logo-flotante">
    <img src="img/loogoproyecto.png" class="logo-flotante">
    <img src="img/loogoproyecto.png" class="logo-flotante">
</div>

<div class="sidebar">
    <div class="sidebar-brand">
        <i class="fas fa-user-check"></i> Sistema Biométrico
    </div>
    
    <div class="sub-menu">
        <div class="menu-seccion">Principal</div>
        <a href="admin.jsp"><i class="fas fa-chart-pie"></i> Dashboard</a>

        <div class="menu-seccion">Gestión de Personal</div>
        <a href="lista.jsp"><i class="fas fa-users"></i> Lista de Personas</a>
        <a href="gestion_usuarios.jsp"><i class="fas fa-user-shield"></i> Gestión de Usuarios</a>

        <div class="menu-seccion">Control de Asistencia</div>
        <a href="ver_accesos.jsp"><i class="fas fa-clipboard-list"></i> Marcaciones</a>
        <a href="ver_justificativos.jsp" style="background: rgba(99, 102, 241, 0.2); color: #ffffff;"><i class="fas fa-bell" style="color: #ffffff;"></i> Justificativos</a>
        <a href="configurar_horario.jsp"><i class="fas fa-clock"></i> Horarios</a>

        <div class="menu-seccion">Nómina y Salarios</div>
        <a href="salario_base.jsp"><i class="fas fa-money-bill-wave"></i> Asignar Salario Base</a>
        <a href="editar_salario_guardado.jsp"><i class="fas fa-calculator"></i> Gestión de Salarios</a>
        <a href="liquidacion_mensual.jsp"><i class="fas fa-file-invoice-dollar"></i> Liquidación Mensual</a>

        <div class="menu-seccion">Configuración y Ajustes</div>
        <a href="aplicar_descuentos.jsp"><i class="fas fa-percentage"></i> Aplicar Descuentos</a>
        <a href="aplicar_bonificaciones.jsp"><i class="fas fa-plus-circle"></i> Aplicar Bonificaciones</a>
        <a href="motivos_descuento.jsp"><i class="fas fa-tag"></i> Motivos de Descuento</a>
        <a href="motivos_bonificacion.jsp"><i class="fas fa-tags"></i> Motivos de Bonificación</a>
        <a href="configurar_periodo.jsp"><i class="fas fa-calendar-plus"></i> Configurar Periodo</a>
        <a href="Listar_periodos.jsp"><i class="fas fa-calendar-alt"></i> Ver Todos los Periodos</a>
    </div>

    <a href="logout.jsp" class="btn-cerrar"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a>
</div>

<div class="main-content">
    
    <div class="topbar">
        <h2>Justificativos de Empleados</h2>
        <div class="user-badge">
            <i class="fas fa-user-circle"></i> <%= usuarioLogueado %>
        </div>
    </div>

    <!-- SECCIÓN DE REPORTES / JUSTIFICATIVOS -->
    <div class="content-card">
        <h4><i class="fas fa-bell"></i> Justificativos y Reportes de Empleados</h4>
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Empleado</th>
                        <th>Incidencia</th>
                        <th>Fecha</th>
                        <th>Motivo / Descargo</th>
                        <th>Acción</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Connection connRep = null;
                    try {
                        Class.forName("org.postgresql.Driver");
                        connRep = DriverManager.getConnection("jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require", "neondb_owner", "npg_6rt8OdayAHcm");
                        Statement stRep = connRep.createStatement();
                        ResultSet rsRep = stRep.executeQuery("SELECT r.id, p.nombre, r.tipo_incidencia, r.fecha, r.motivo FROM reportes_empleado r JOIN personas p ON r.persona_id = p.id ORDER BY r.id DESC");
                        
                        boolean hayReportes = false;
                        while(rsRep.next()) {
                            hayReportes = true;
                            String tipoInc = rsRep.getString("tipo_incidencia");
                            String badgeInc = "badge-warning";
                            if("Ausencia".equalsIgnoreCase(tipoInc)) {
                                badgeInc = "badge-danger";
                            }
                    %>
                    <tr>
                        <td><strong><%= rsRep.getString("nombre") %></strong></td>
                        <td><span class="badge <%= badgeInc %>" style="font-size: 11px; padding: 5px 8px;"><%= tipoInc %></span></td>
                        <td><%= rsRep.getDate("fecha") %></td>
                        <td><%= rsRep.getString("motivo") %></td>
                        <td>
                            <a href="aplicar_descuentos.jsp" class="btn-lila-action">Gestionar Descuento</a>
                        </td>
                    </tr>
                    <%
                        }
                        rsRep.close();
                        stRep.close();
                        if(!hayReportes) {
                    %>
                    <tr>
                        <td colspan="5" class="text-center text-muted py-4">No hay reportes o justificativos enviados por los empleados.</td>
                    </tr>
                    <%
                        }
                    } catch(Exception ex) {
                    %>
                    <tr>
                        <td colspan="5" class="text-center text-danger py-4">Error al cargar los reportes de empleados.</td>
                    </tr>
                    <%
                    } finally {
                        if(connRep != null) connRep.close();
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>

</div>

</body>
</html>