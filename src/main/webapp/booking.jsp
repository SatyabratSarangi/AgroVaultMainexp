<%@ page import="java.sql.*, com.agrovault.DBConfig" %>
<%@ include file="components/nav.jsp" %>
<%
    // Ensure user is logged in AND is a FARMER
    if (sessionUserId == null || !"FARMER".equals(sessionRole)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String action = request.getParameter("action");
    int unitId = 0;
    if(request.getParameter("unitId") != null) {
        unitId = Integer.parseInt(request.getParameter("unitId"));
    }

    String msg = "";
    
    // Fetch Storage Info for calculation
    double pricePerTon = 0;
    String unitTitle = "";
    try (Connection conn = DBConfig.getConnection();
         PreparedStatement pstmt = conn.prepareStatement("SELECT title, price FROM storage_units WHERE id = ?")) {
        pstmt.setInt(1, unitId);
        ResultSet rs = pstmt.executeQuery();
        if(rs.next()) {
            unitTitle = rs.getString("title");
            pricePerTon = rs.getDouble("price");
        }
    }

    // Process Final Confirmation
    if ("confirm".equals(action)) {
        String productName = request.getParameter("productName");
        double tons = Double.parseDouble(request.getParameter("tons"));
        double base = tons * pricePerTon;
        double gst = base * 0.18;
        double total = base + gst;
        
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("INSERT INTO bookings (farmer_id, unit_id, product_name, tons_booked, base_amount, gst_amount, grand_total, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'CONFIRMED')")) {
            pstmt.setInt(1, sessionUserId);
            pstmt.setInt(2, unitId);
            pstmt.setString(3, productName);
            pstmt.setDouble(4, tons);
            pstmt.setDouble(5, base);
            pstmt.setDouble(6, gst);
            pstmt.setDouble(7, total);
            pstmt.executeUpdate();
            
            response.sendRedirect("booking.jsp?success=true&id=" + unitId);
            return;
        } catch (Exception e) {
            msg = "<div class='alert alert-error'>Booking Error: " + e.getMessage() + "</div>";
        }
    }
%>

<main class="container">
    <div class="header-section">
        <h1 class="page-title">Secure Your Storage</h1>
    </div>

    <% if ("true".equals(request.getParameter("success"))) { %>
        <div class="card" style="max-width: 600px; margin: 0 auto; text-align: center; padding: 4rem 2rem;">
            <svg style="color: var(--primary); width: 80px; height: 80px; margin-bottom: 1.5rem;" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
            <h2 style="color: var(--secondary); margin-bottom: 1rem;">Booking Confirmed!</h2>
            <p style="color: var(--text-muted); margin-bottom: 2rem;">Your storage has been successfully reserved. A GST E-Bill has been generated.</p>
            <a href="dashboard.jsp" class="btn btn-outline">Return to Dashboard</a>
        </div>
    <% } else if ("preview".equals(action)) { 
        String productName = request.getParameter("productName");
        double tons = Double.parseDouble(request.getParameter("tons"));
        double base = tons * pricePerTon;
        double gst = base * 0.18;
        double total = base + gst;
    %>
        <div class="form-card" style="max-width: 600px; margin: 0 auto; border: 2px solid var(--primary);">
            <h2 style="margin-bottom: 1.5rem; color: var(--secondary);">Review Your GST E-Bill</h2>
            
            <div style="background: #f8fafc; padding: 1.5rem; border-radius: 12px; margin-bottom: 2rem;">
                <div style="display: flex; justify-content: space-between; margin-bottom: 0.5rem;">
                    <span class="text-muted">Unit:</span>
                    <span style="font-weight: 600;"><%= unitTitle %></span>
                </div>
                <div style="display: flex; justify-content: space-between; margin-bottom: 0.5rem;">
                    <span class="text-muted">Product:</span>
                    <span style="font-weight: 600;"><%= productName %></span>
                </div>
                <div style="display: flex; justify-content: space-between; margin-bottom: 1rem; padding-bottom: 1rem; border-bottom: 1px solid var(--border-color);">
                    <span class="text-muted">Quantity:</span>
                    <span style="font-weight: 600;"><%= tons %> Tons</span>
                </div>
                
                <div style="display: flex; justify-content: space-between; margin-bottom: 0.5rem;">
                    <span>Base Amount:</span>
                    <span style="font-weight: 600;">&#8377;<%= String.format("%.2f", base) %></span>
                </div>
                <div style="display: flex; justify-content: space-between; margin-bottom: 1rem;">
                    <span>GST (18%):</span>
                    <span style="font-weight: 600;">&#8377;<%= String.format("%.2f", gst) %></span>
                </div>
                <div style="display: flex; justify-content: space-between; font-size: 1.2rem; border-top: 2px dashed var(--border-color); pt: 1rem; mt: 1rem;">
                    <span style="font-weight: 700;">Total Payable:</span>
                    <span style="font-weight: 800; color: var(--primary);">&#8377;<%= String.format("%.2f", total) %></span>
                </div>
            </div>

            <form method="post" action="booking.jsp">
                <input type="hidden" name="action" value="confirm">
                <input type="hidden" name="unitId" value="<%= unitId %>">
                <input type="hidden" name="productName" value="<%= productName %>">
                <input type="hidden" name="tons" value="<%= tons %>">
                
                <button type="submit" class="btn btn-primary" style="width: 100%;">Confirm & Finalize Bill</button>
                <a href="booking.jsp?unitId=<%= unitId %>" class="btn btn-outline" style="width: 100%; margin-top: 10px;">Edit Details</a>
            </form>
        </div>
    <% } else { %>
        <%= msg %>
        
        <div class="form-card" style="max-width: 600px; margin: 0 auto;">
            <h2 style="margin-bottom: 0.5rem; color: var(--secondary);">Storage: <%= unitTitle %></h2>
            <p style="color: var(--text-muted); margin-bottom: 2rem;">Rate: &#8377;<%= pricePerTon %> / Ton</p>
            
            <form method="post" action="booking.jsp">
                <input type="hidden" name="action" value="preview">
                <input type="hidden" name="unitId" value="<%= unitId %>">
                
                <div class="form-group">
                    <label class="form-label">Product to Store</label>
                    <input type="text" name="productName" class="form-control" placeholder="e.g. Wheat, Apples, Potatoes" required>
                </div>

                <div class="form-group">
                    <label class="form-label">Tons Required</label>
                    <input type="number" step="0.01" name="tons" class="form-control" required placeholder="e.g. 5.5">
                </div>
                
                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">Review E-Bill (GST Included)</button>
            </form>
        </div>
    <% } %>
</main>

<%@ include file="components/footer.jsp" %>
