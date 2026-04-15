<%@ page import="java.sql.*, com.agrovault.DBConfig" %>
<%@ include file="components/nav.jsp" %>
<%
    // Ensure user is logged in AND is an OWNER
    if (sessionUserId == null || !"OWNER".equals(sessionRole)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String action = request.getParameter("action");
    String msg = "";
    
    // Process Actions BEFORE rendering the View
    if ("add".equals(action)) {
        String title = request.getParameter("title");
        String city = request.getParameter("city");
        double capacity = Double.parseDouble(request.getParameter("capacity"));
        double price = Double.parseDouble(request.getParameter("price"));
        String desc = request.getParameter("description");
        
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("INSERT INTO storage_units (owner_id, title, city, capacity, price, status, description) VALUES (?, ?, ?, ?, ?, 'AVAILABLE', ?)")) {
            pstmt.setInt(1, sessionUserId);
            pstmt.setString(2, title);
            pstmt.setString(3, city);
            pstmt.setDouble(4, capacity);
            pstmt.setDouble(5, price);
            pstmt.setString(6, desc);
            pstmt.executeUpdate();
            msg = "<div class='alert alert-success'>Storage Unit Added Successfully!</div>";
        } catch (Exception e) {
            msg = "<div class='alert alert-error'>Error adding unit: " + e.getMessage() + "</div>";
        }
    } else if ("delete".equals(action)) {
        int unitId = Integer.parseInt(request.getParameter("unitId"));
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("DELETE FROM storage_units WHERE id = ? AND owner_id = ?")) {
            pstmt.setInt(1, unitId);
            pstmt.setInt(2, sessionUserId);
            pstmt.executeUpdate();
            msg = "<div class='alert alert-success'>Storage Unit Deleted Successfully!</div>";
        } catch (Exception e) {
            msg = "<div class='alert alert-error'>Error deleting unit: " + e.getMessage() + "</div>";
        }
    } else if ("toggle".equals(action)) {
        int unitId = Integer.parseInt(request.getParameter("unitId"));
        String newStatus = request.getParameter("status");
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("UPDATE storage_units SET status = ? WHERE id = ? AND owner_id = ?")) {
            pstmt.setString(1, newStatus);
            pstmt.setInt(2, unitId);
            pstmt.setInt(3, sessionUserId);
            pstmt.executeUpdate();
            msg = "<div class='alert alert-success'>Status Updated!</div>";
        } catch (Exception e) {
            msg = "<div class='alert alert-error'>Error updating status: " + e.getMessage() + "</div>";
        }
    }
%>

<main class="container">
    <div class="header-section">
        <h1 class="page-title">Manage My Listings</h1>
    </div>

    <%= msg %>

    <!-- Add New Listing Form -->
    <div class="card" style="padding: 2rem; margin-bottom: 3rem;">
        <h2 style="margin-bottom: 1.5rem; color: var(--secondary);">Add New Storage Unit</h2>
        <form method="post" action="manage-listings.jsp">
            <input type="hidden" name="action" value="add">
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <div class="form-group">
                    <label class="form-label">Storage Name/Title</label>
                    <input type="text" name="title" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">City</label>
                    <input type="text" name="city" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Capacity (in Tons)</label>
                    <input type="number" step="0.01" name="capacity" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Price per Ton (&#8377;)</label>
                    <input type="number" step="0.01" name="price" class="form-control" required>
                </div>
            </div>
            <div class="form-group">
                <label class="form-label">Description</label>
                <textarea name="description" class="form-control" rows="3"></textarea>
            </div>
            
            <button type="submit" class="btn btn-primary">Add Listing</button>
        </form>
    </div>

    <!-- Listings Table -->
    <h2 style="margin-bottom: 1.5rem; color: var(--secondary);">Current Listings</h2>
    <div class="table-responsive">
        <table class="table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Title</th>
                    <th>City</th>
                    <th>Capacity</th>
                    <th>Price/Ton</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% 
                    try (Connection conn = DBConfig.getConnection();
                         PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM storage_units WHERE owner_id = ? ORDER BY id DESC")) {
                        pstmt.setInt(1, sessionUserId);
                        ResultSet rs = pstmt.executeQuery();
                        
                        while(rs.next()) {
                            int id = rs.getInt("id");
                            String status = rs.getString("status");
                            String nextStatus = status.equals("AVAILABLE") ? "FULL" : "AVAILABLE";
                %>
                        <tr>
                            <td>#<%= id %></td>
                            <td><%= rs.getString("title") %></td>
                            <td><%= rs.getString("city") %></td>
                            <td><%= rs.getDouble("capacity") %>T</td>
                            <td>&#8377;<%= rs.getDouble("price") %></td>
                            <td>
                                <span class="status-badge <%= status.equals("AVAILABLE") ? "status-available" : "status-full" %>" style="position:static; display:inline-block; padding:0.2rem 0.8rem;">
                                    <%= status %>
                                </span>
                            </td>
                            <td class="action-links">
                                <a href="manage-listings.jsp?action=toggle&unitId=<%= id %>&status=<%= nextStatus %>" class="btn btn-outline" style="padding: 0.3rem 0.8rem; font-size: 0.8rem;">Mark <%= nextStatus %></a>
                                <a href="manage-listings.jsp?action=delete&unitId=<%= id %>" class="btn btn-danger" style="padding: 0.3rem 0.8rem; font-size: 0.8rem;" onclick="return confirm('Are you sure you want to delete this listing?');">Delete</a>
                            </td>
                        </tr>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<tr><td colspan='7'>Error loading listings: " + e.getMessage() + "</td></tr>");
                    }
                %>
            </tbody>
        </table>
    </div>
</main>

<%@ include file="components/footer.jsp" %>
