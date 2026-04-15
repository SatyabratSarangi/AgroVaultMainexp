<%@ page import="java.sql.*, com.agrovault.DBConfig" %>
<%@ include file="components/nav.jsp" %>
<%
    if (sessionUserId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<main class="container">
    <div class="header-section">
        <% if ("FARMER".equals(sessionRole)) { %>
            <h1 class="page-title">My GST E-Bills & Bookings</h1>
            <p class="text-muted">Track your financial storage history and view receipts.</p>
        <% } else { %>
            <h1 class="page-title">Incoming Bookings</h1>
            <p class="text-muted">Manage the inventory and farmers utilizing your units.</p>
        <% } %>
    </div>

    <div class="units-grid">
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                conn = DBConfig.getConnection();
                String query = "";
                
                if ("FARMER".equals(sessionRole)) {
                    // Farmer sees their own bookings
                    query = "SELECT b.*, s.title as unit_title, s.price as rate FROM bookings b " +
                            "JOIN storage_units s ON b.unit_id = s.id " +
                            "WHERE b.farmer_id = ? ORDER BY b.booking_date DESC";
                    pstmt = conn.prepareStatement(query);
                    pstmt.setInt(1, sessionUserId);
                } else {
                    // Owner sees bookings for their units
                    query = "SELECT b.*, s.title as unit_title, u.name as farmer_name FROM bookings b " +
                            "JOIN storage_units s ON b.unit_id = s.id " +
                            "JOIN users u ON b.farmer_id = u.id " +
                            "WHERE s.owner_id = ? ORDER BY b.booking_date DESC";
                    pstmt = conn.prepareStatement(query);
                    pstmt.setInt(1, sessionUserId);
                }

                rs = pstmt.executeQuery();
                boolean found = false;
                while (rs.next()) {
                    found = true;
                    int id = rs.getInt("id");
                    String unitTitle = rs.getString("unit_title");
                    String productName = rs.getString("product_name");
                    double tons = rs.getDouble("tons_booked");
                    double total = rs.getDouble("grand_total");
                    String date = rs.getString("booking_date");
                    String status = rs.getString("status");
        %>
            <div class="card animate-on-scroll" style="min-height: 250px;">
                <div class="card-body">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem;">
                        <span class="status-badge <%= status.equals("CONFIRMED") ? "status-available" : "status-full" %>" style="position: static;">
                            <%= status %>
                        </span>
                        <span style="font-size: 0.8rem; color: var(--text-muted);"><%= date.substring(0, 16) %></span>
                    </div>

                    <h3 class="card-title" style="margin-bottom: 0.2rem;"><%= unitTitle %></h3>
                    <p class="text-muted" style="font-size: 0.9rem; margin-bottom: 1rem;">ID: #GA-<%= 1000 + id %></p>

                    <div style="background: rgba(16, 185, 129, 0.05); padding: 1rem; border-radius: 12px; margin-bottom: 1.5rem;">
                        <div style="display: flex; justify-content: space-between; font-size: 0.85rem; margin-bottom: 0.4rem;">
                            <span>Product:</span>
                            <span style="font-weight: 600;"><%= productName != null ? productName : "General Produce" %></span>
                        </div>
                        <div style="display: flex; justify-content: space-between; font-size: 0.85rem; margin-bottom: 0.4rem;">
                            <span>Quantity:</span>
                            <span style="font-weight: 600;"><%= tons %> Tons</span>
                        </div>
                        <% if ("OWNER".equals(sessionRole)) { %>
                            <div style="display: flex; justify-content: space-between; font-size: 0.85rem; border-top: 1px solid rgba(0,0,0,0.05); padding-top: 0.4rem; margin-top: 0.4rem;">
                                <span>Farmer:</span>
                                <span style="font-weight: 600; color: var(--primary-dark);"><%= rs.getString("farmer_name") %></span>
                            </div>
                        <% } %>
                    </div>

                    <div style="display: flex; justify-content: space-between; align-items: center; margin-top: auto; border-top: 1px dashed var(--border-color); padding-top: 1rem;">
                        <div style="display: flex; flex-direction: column;">
                            <span style="font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase;">Final Amount</span>
                            <span style="font-size: 1.2rem; font-weight: 800; color: var(--secondary);">&#8377;<%= String.format("%.2f", total) %></span>
                        </div>
                    </div>
                </div>
            </div>
        <%
                }
                if (!found) {
                    out.println("<div class='alert' style='grid-column: 1/-1; text-align: center; padding: 4rem; background: #fff;'>");
                    out.println("<svg style='width: 64px; height: 64px; color: #cbd5e1; margin-bottom: 1rem;' fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M9 12h6m-6 4h6m2 5H7a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5.586a1 1 0 0 1 .707.293l5.414 5.414a1 1 0 0 1 .293.707V19a2 2 0 0 1-2 2z'></path></svg>");
                    out.println("<h3>No records found yet.</h3><p class='text-muted'>Explore listings and start booking storage space.</p></div>");
                }
            } catch (Exception e) {
                out.println("<div class='alert alert-error'>System Error: " + e.getMessage() + "</div>");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        %>
    </div>
</main>

<script src="js/main.js"></script>
<%@ include file="components/footer.jsp" %>
