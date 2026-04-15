<%@ page import="java.sql.*, com.agrovault.DBConfig" %>
<%@ include file="components/nav.jsp" %>
<%
    // Ensure user is logged in
    if (sessionUserId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userCity = (String) session.getAttribute("city");
%>

<main class="container">
    <div class="header-section">
        <div>
            <h1 class="page-title">Available Cold Storage</h1>
            <p class="text-muted">Showing units near: <strong><%= userCity %></strong></p>
        </div>
    </div>

    <!-- Smart Filter driven by JS -->
    <div class="filter-bar">
        <input type="text" id="searchInput" class="form-control" placeholder="Filter by Name or specific City..." onkeyup="filterCards()">
    </div>

    <div class="units-grid" id="storageGrid">
        <% 
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                conn = DBConfig.getConnection();
                // Showing units based on user's city first, or could just show all
                // Let's show all and highlight matched city or prioritize if asked,
                // We'll select all and use JS for quick client side, but order by city match
                String query = "SELECT * FROM storage_units ORDER BY CASE WHEN city = ? THEN 1 ELSE 2 END, id DESC";
                pstmt = conn.prepareStatement(query);
                pstmt.setString(1, userCity);
                rs = pstmt.executeQuery();

                while (rs.next()) {
                    int unitId = rs.getInt("id");
                    String title = rs.getString("title");
                    String city = rs.getString("city");
                    double capacity = rs.getDouble("capacity");
                    double price = rs.getDouble("price");
                    String status = rs.getString("status");
                    String imageUrl = rs.getString("image_url");
                    if(imageUrl == null || imageUrl.trim().isEmpty()) {
                        imageUrl = "https://images.unsplash.com/photo-1587293852726-70cdb56c2866?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80";
                    }
        %>
            <div class="card storage-card" data-city="<%= city.toLowerCase() %>" data-title="<%= title.toLowerCase() %>">
                <div class="card-img-container">
                    <img src="<%= imageUrl %>" alt="<%= title %>" class="card-img">
                    <span class="status-badge <%= status.equals("AVAILABLE") ? "status-available" : "status-full" %>">
                        <%= status %>
                    </span>
                </div>
                <div class="card-body">
                    <h3 class="card-title"><%= title %></h3>
                    <div class="card-location">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                        <%= city %> <%= city.equalsIgnoreCase(userCity) ? "(Near you)" : "" %>
                    </div>
                    
                    <div class="card-details">
                        <div class="detail-item">
                            <span class="detail-label">Capacity (Tons)</span>
                            <span class="detail-value"><%= capacity %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Price / Ton</span>
                            <span class="detail-value">&#8377;<%= price %></span>
                        </div>
                    </div>
                    
                    <% if (status.equals("AVAILABLE")) { %>
                        <a href="booking.jsp?unitId=<%= unitId %>" class="btn btn-primary" style="width: 100%;">Book Now</a>
                    <% } else { %>
                        <button class="btn btn-outline" style="width: 100%; border-color: #aaa; color: #aaa; cursor: not-allowed;" disabled>Currently Full</button>
                    <% } %>
                </div>
            </div>
        <% 
                }
            } catch (Exception e) {
                out.println("<div class='alert alert-error'>Error fetching data: " + e.getMessage() + "</div>");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        %>
    </div>
</main>

<script>
function filterCards() {
    const searchInput = document.getElementById('searchInput').value.toLowerCase();
    const cards = document.querySelectorAll('.storage-card');

    cards.forEach(card => {
        const title = card.getAttribute('data-title');
        const city = card.getAttribute('data-city');
        
        if (title.includes(searchInput) || city.includes(searchInput)) {
            card.style.display = 'flex';
        } else {
            card.style.display = 'none';
        }
    });
}
</script>

<%@ include file="components/footer.jsp" %>
