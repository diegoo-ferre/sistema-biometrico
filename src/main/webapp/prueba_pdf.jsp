<%@ page import="com.itextpdf.text.Document" %>
<%@ page import="com.itextpdf.text.Paragraph" %>
<%@ page import="com.itextpdf.text.pdf.PdfWriter" %>

<%
response.setContentType("application/pdf");

Document documento = new Document();
PdfWriter.getInstance(documento, response.getOutputStream());

documento.open();
documento.add(new Paragraph("PDF funcionando correctamente"));
documento.close();
%>