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
        String imageUrl = request.getParameter("imageUrl");
        
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("INSERT INTO storage_units (owner_id, title, city, capacity, price, status, description, image_url) VALUES (?, ?, ?, ?, ?, 'AVAILABLE', ?, ?)")) {
            pstmt.setInt(1, sessionUserId);
            pstmt.setString(2, title);
            pstmt.setString(3, city);
            pstmt.setDouble(4, capacity);
            pstmt.setDouble(5, price);
            pstmt.setString(6, desc);
            pstmt.setString(7, imageUrl);
            pstmt.executeUpdate();
            response.sendRedirect("dashboard.jsp?msg=added");
            return;
        } catch (Exception e) {
            msg = "<div class='alert alert-error'>Error adding unit: " + e.getMessage() + "</div>";
        }
    } else if ("update".equals(action)) {
        int unitId = Integer.parseInt(request.getParameter("unitId"));
        String title = request.getParameter("title");
        String city = request.getParameter("city");
        double capacity = Double.parseDouble(request.getParameter("capacity"));
        double price = Double.parseDouble(request.getParameter("price"));
        String desc = request.getParameter("description");
        String imageUrl = request.getParameter("imageUrl");

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("UPDATE storage_units SET title=?, city=?, capacity=?, price=?, description=?, image_url=? WHERE id=? AND owner_id=?")) {
            pstmt.setString(1, title);
            pstmt.setString(2, city);
            pstmt.setDouble(3, capacity);
            pstmt.setDouble(4, price);
            pstmt.setString(5, desc);
            pstmt.setString(6, imageUrl);
            pstmt.setInt(7, unitId);
            pstmt.setInt(8, sessionUserId);
            pstmt.executeUpdate();
            response.sendRedirect("dashboard.jsp?msg=updated");
            return;
        } catch (Exception e) {
            msg = "<div class='alert alert-error'>Error updating unit: " + e.getMessage() + "</div>";
        }
    } else if ("delete".equals(action)) {
        int unitId = Integer.parseInt(request.getParameter("unitId"));
        try (Connection conn = DBConfig.getConnection()) {
            conn.setAutoCommit(false); // Use transaction for safety
            try {
                // Delete associated reviews first (though they should cascade if DB was updated, this is safer)
                try (PreparedStatement ps1 = conn.prepareStatement("DELETE FROM reviews WHERE unit_id = ?")) {
                    ps1.setInt(1, unitId);
                    ps1.executeUpdate();
                }
                // Delete associated bookings
                try (PreparedStatement ps2 = conn.prepareStatement("DELETE FROM bookings WHERE unit_id = ?")) {
                    ps2.setInt(1, unitId);
                    ps2.executeUpdate();
                }
                // Finally delete the unit
                try (PreparedStatement ps3 = conn.prepareStatement("DELETE FROM storage_units WHERE id = ? AND owner_id = ?")) {
                    ps3.setInt(1, unitId);
                    ps3.setInt(2, sessionUserId);
                    int deleted = ps3.executeUpdate();
                    if (deleted > 0) {
                        conn.commit();
                        response.sendRedirect("dashboard.jsp?msg=deleted");
                        return;
                    } else {
                        conn.rollback();
                        msg = "<div class='alert alert-error'>Error: Listing not found or you don't have permission.</div>";
                    }
                }
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
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
            response.sendRedirect("dashboard.jsp?msg=updated");
            return;
        } catch (Exception e) {
            msg = "<div class='alert alert-error'>Error updating status: " + e.getMessage() + "</div>";
        }
    }

    // Check for Edit Mode
    String editIdStr = request.getParameter("editId");
    String eTitle="", eCity="", eDesc="", eImg="";
    double eCap=0, ePrice=0;
    boolean isEdit = false;

    if (editIdStr != null) {
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM storage_units WHERE id=? AND owner_id=?")) {
            pstmt.setInt(1, Integer.parseInt(editIdStr));
            pstmt.setInt(2, sessionUserId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                eTitle = rs.getString("title");
                eCity = rs.getString("city");
                eCap = rs.getDouble("capacity");
                ePrice = rs.getDouble("price");
                eDesc = rs.getString("description");
                eImg = rs.getString("image_url");
                isEdit = true;
            }
        } catch (Exception e) {}
    }
%>

<main class="container">
    <div class="header-section">
        <h1 class="page-title">Manage My Listings</h1>
    </div>

    <%= msg %>

    <!-- Listings Table -->
    <h2 style="margin-bottom: 1.5rem; color: var(--secondary);"><%= isEdit ? "Editing: " + eTitle : "Add New Storage Unit" %></h2>
    <div class="card" style="padding: 2rem; margin-bottom: 3rem; border: <%= isEdit ? "2px solid var(--primary)" : "1px solid var(--border-color)" %>;">
        <form method="post" action="manage-listings.jsp">
            <input type="hidden" name="action" value="<%= isEdit ? "update" : "add" %>">
            <% if (isEdit) { %>
                <input type="hidden" name="unitId" value="<%= editIdStr %>">
            <% } %>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <div class="form-group">
                    <label class="form-label">Storage Name/Title</label>
                    <input type="text" name="title" class="form-control" value="<%= eTitle %>" required>
                </div>
                <div class="form-group">
                    <label class="form-label">City</label>
                    <input type="text" name="city" class="form-control" value="<%= eCity %>" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Capacity (in Tons)</label>
                    <input type="number" step="0.01" name="capacity" class="form-control" value="<%= eCap %>" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Price per Ton (&#8377;)</label>
                    <input type="number" step="0.01" name="price" class="form-control" value="<%= ePrice %>" required>
                </div>
                <div class="form-group" style="grid-column: span 2;">
                    <label class="form-label">Image URL</label>
                    <input type="text" name="imageUrl" class="form-control" value="<%= eImg %>" placeholder="https://example.com/image.jpg">
                </div>
            </div>
            <div class="form-group">
                <label class="form-label">Description</label>
                <textarea name="description" class="form-control" rows="3"><%= eDesc %></textarea>
            </div>
            
            <div style="display: flex; gap: 1rem;">
                <button type="submit" class="btn btn-primary"><%= isEdit ? "Save Changes" : "Add Listing" %></button>
                <% if (isEdit) { %>
                    <a href="manage-listings.jsp" class="btn btn-outline">Cancel</a>
                <% } %>
            </div>
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
                            <td class="action-links" style="display: flex; gap: 0.5rem;">
                                <a href="manage-listings.jsp?editId=<%= id %>" class="btn btn-outline" style="padding: 0.3rem 0.8rem; font-size: 0.8rem; border-color: var(--primary); color: var(--primary);">Edit</a>
                                <a href="manage-listings.jsp?action=toggle&unitId=<%= id %>&status=<%= nextStatus %>" class="btn btn-outline" style="padding: 0.3rem 0.8rem; font-size: 0.8rem;">Mark <%= nextStatus %></a>
                                <a href="manage-listings.jsp?action=delete&unitId=<%= id %>" class="btn btn-danger" style="padding: 0.3rem 0.8rem; font-size: 0.8rem; background: #fee2e2; color: #ef4444; border: none;" onclick="return confirm('Are you sure you want to delete this listing?');">Delete</a>
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
