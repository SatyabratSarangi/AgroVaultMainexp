<%@ page import="java.sql.*, com.agrovault.DBConfig" %>
    <%@ include file="components/nav.jsp" %>
<%
    // logged in
    if (sessionUserId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userCity = (String) session.getAttribute("city");
%>

            <main class="container">
                <div class="header-section">
                    <div>
                        <% if ("FARMER".equals(sessionRole)) { %>
                            <h1 class="page-title">Available Cold Storage</h1>
                            <p class="text-muted">Showing units near: <strong><%= userCity %></strong></p>
                        <% } else { %>
                            <h1 class="page-title">Business Overview</h1>
                            <p class="text-muted">Welcome back, <strong><%= sessionUserName %></strong>. Here is your operational summary.</p>
                        <% } %>
                    </div>
                </div>

                <% 
                    String msg = request.getParameter("msg");
                    if (msg != null) {
                        String alertClass = "alert-success";
                        String displayMsg = "";
                        if (msg.equals("deleted")) displayMsg = "Listing deleted successfully.";
                        if (msg.equals("added")) displayMsg = "Listing added successfully.";
                        if (msg.equals("updated")) displayMsg = "Listing updated successfully.";
                        if (msg.equals("error")) { alertClass = "alert-error"; displayMsg = "An error occurred."; }
                        if (!displayMsg.isEmpty()) {
                %>
                        <div class="alert <%= alertClass %>" style="margin-bottom: 2rem;">
                            <%= displayMsg %>
                        </div>
                <%      }
                    }
                %>

                <% if ("FARMER".equals(sessionRole)) { %>
                    <!-- Smart Filter driven by JS -->
                    <div class="filter-bar">
                        <input type="text" id="searchInput" class="form-control"
                            placeholder="Filter by Name or specific City..." onkeyup="filterCards()">
                    </div>

                <div class="units-grid" id="storageGrid">
                <% 
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;

                    try {
                        conn = DBConfig.getConnection();



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
                        <div class="card storage-card" data-city="<%= city.toLowerCase() %>"
                            data-title="<%= title.toLowerCase() %>">
                            <div class="card-img-container">
                                <img src="<%= imageUrl %>" alt="<%= title %>" class="card-img">
                                <span class="status-badge <%= status.equals(" AVAILABLE") ? "status-available"
                                    : "status-full" %>">
                                    <%= status %>
                                </span>
                            </div>
                            <div class="card-body">
                                <h3 class="card-title">
                                    <%= title %>
                                </h3>
                                <div class="card-location">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
                                        fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round">
                                        <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                                        <circle cx="12" cy="10" r="3"></circle>
                                    </svg>
                                    <%= city %>
                                        <%= city.equalsIgnoreCase(userCity) ? "(Near you)" : "" %>
                                </div>

                                <div class="card-details">
                                    <div class="detail-item">
                                        <span class="detail-label">Capacity (Tons)</span>
                                        <span class="detail-value">
                                            <%= capacity %>
                                        </span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Price / Ton</span>
                                        <span class="detail-value">&#8377;<%= price %></span>
                                    </div>
                                </div>
                                <div class="reviews-section">
                                    <div class="reviews-header">
                                        <h4>User Reviews</h4>
                                        <div class="avg-rating">
                                            <%
                                                double avgRating = 0;
                                                int reviewCount = 0;
                                                try (PreparedStatement psR = conn.prepareStatement("SELECT AVG(rating), COUNT(*) FROM reviews WHERE unit_id = ?")) {
                                                    psR.setInt(1, unitId);
                                                    ResultSet rsR = psR.executeQuery();
                                                    if(rsR.next()) {
                                                        avgRating = rsR.getDouble(1);
                                                        reviewCount = rsR.getInt(2);
                                                    }
                                                } catch(Exception e) {}
                                            %>
                                            <span class="stars"><%= String.format("%.1f", avgRating) %> ★</span>
                                            <span class="count">(<%= reviewCount %>)</span>
                                        </div>
                                    </div>
                                    
                                    <div class="all-reviews">
                                        <%
                                            try (PreparedStatement psR = conn.prepareStatement("SELECT r.*, u.name FROM reviews r JOIN users u ON r.user_id = u.id WHERE r.unit_id = ? ORDER BY r.created_at DESC LIMIT 3")) {
                                                psR.setInt(1, unitId);
                                                ResultSet rsR = psR.executeQuery();
                                                boolean foundReview = false;
                                                while(rsR.next()) {
                                                    foundReview = true;
                                        %>
                                            <div class="review-item">
                                                <div class="review-header-info">
                                                    <span class="reviewer-name"><%= rsR.getString("name") %></span>
                                                    <span class="review-stars-small"><%= "★".repeat(rsR.getInt("rating")) %></span>
                                                </div>
                                                <p class="review-comment"><%= rsR.getString("comment") %></p>
                                            </div>
                                        <%
                                                }
                                                if(!foundReview) {
                                                    out.println("<p class='no-reviews'>No reviews yet. Be the first!</p>");
                                                }
                                            } catch(Exception e) {}
                                        %>
                                    </div>

                                    <% if ("FARMER".equals(sessionRole)) { %>
                                        <div class="add-review-form">
                                            <form action="add-review.jsp" method="post">
                                                <input type="hidden" name="unitId" value="<%= unitId %>">
                                                <div class="rating-input">
                                                    <input type="radio" name="rating" value="5" id="star5-<%= unitId %>" required><label for="star5-<%= unitId %>">★</label>
                                                    <input type="radio" name="rating" value="4" id="star4-<%= unitId %>"><label for="star4-<%= unitId %>">★</label>
                                                    <input type="radio" name="rating" value="3" id="star3-<%= unitId %>"><label for="star3-<%= unitId %>">★</label>
                                                    <input type="radio" name="rating" value="2" id="star2-<%= unitId %>"><label for="star2-<%= unitId %>">★</label>
                                                    <input type="radio" name="rating" value="1" id="star1-<%= unitId %>"><label for="star1-<%= unitId %>">★</label>
                                                </div>
                                                <div class="comment-input-group">
                                                    <textarea name="comment" placeholder="Leave a feedback..." required></textarea>
                                                    <button type="submit" class="btn-send">
                                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
                                                    </button>
                                                </div>
                                            </form>
                                        </div>
                                    <% } %>
                                </div>

                                <% if (status.equals("AVAILABLE")) { %>
                                    <a href="booking.jsp?unitId=<%= unitId %>" class="btn btn-primary"
                                        style="width: 100%; margin-top: 1rem;">Book Now</a>
                                    <% } else { %>
                                        <button class="btn btn-outline"
                                            style="width: 100%; border-color: #aaa; color: #aaa; cursor: not-allowed; margin-top: 1rem;"
                                            disabled>Currently Full</button>
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
                <% } else { 
                    // OWNER VIEW DATA
                    double totalRev = 0;
                    int activeUnits = 0;
                    int totalBookings = 0;

                    try (Connection conn = DBConfig.getConnection()) {
                        // Managed Units
                        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM storage_units WHERE owner_id = ?")) {
                            ps.setInt(1, sessionUserId);
                            ResultSet rsS = ps.executeQuery();
                            if(rsS.next()) activeUnits = rsS.getInt(1);
                        }
                        // Stats
                        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*), SUM(grand_total) FROM bookings b JOIN storage_units s ON b.unit_id = s.id WHERE s.owner_id = ?")) {
                            ps.setInt(1, sessionUserId);
                            ResultSet rsS = ps.executeQuery();
                            if(rsS.next()) {
                                totalBookings = rsS.getInt(1);
                                totalRev = rsS.getDouble(2);
                            }
                        }
                    } catch (Exception e) {}
                %>
                    <div class="stats-grid">
                        <div class="stat-card">
                            <span class="stat-label">Total Revenue</span>
                            <span class="stat-value">&#8377;<%= String.format("%.2f", totalRev) %></span>
                            <span class="stat-trend trend-up">Gross Profit</span>
                        </div>
                        <div class="stat-card">
                            <span class="stat-label">Total Bookings</span>
                            <span class="stat-value"><%= totalBookings %></span>
                            <span class="stat-trend trend-up">Farmer Reach</span>
                        </div>
                        <div class="stat-card">
                            <span class="stat-label">Managed Units</span>
                            <span class="stat-value"><%= activeUnits %></span>
                            <a href="manage-listings.jsp" style="font-size: 0.8rem; color: var(--primary); text-decoration: none; font-weight: 700;">Update Listings &rarr;</a>
                        </div>
                    </div>

                    <div class="header-section" style="margin-top: 4rem;">
                        <h2 style="color: var(--secondary);">My Storage Managed Units</h2>
                        <a href="manage-listings.jsp" class="btn btn-primary" style="padding: 0.6rem 2rem; border-radius: 12px;">+ Add New Unit</a>
                    </div>

                    <div class="units-grid" style="margin-top: 1.5rem;">
                        <%
                            try (Connection c2 = DBConfig.getConnection();
                                 PreparedStatement ps2 = c2.prepareStatement("SELECT * FROM storage_units WHERE owner_id = ? ORDER BY id DESC")) {
                                ps2.setInt(1, sessionUserId);
                                ResultSet rs2 = ps2.executeQuery();
                                boolean hasUnits = false;
                                while(rs2.next()) {
                                    hasUnits = true;
                                    int uId = rs2.getInt("id");
                                    String uTitle = rs2.getString("title");
                                    String uCity = rs2.getString("city");
                                    String uStatus = rs2.getString("status");
                                    String uImg = rs2.getString("image_url");
                                    if(uImg == null || uImg.trim().isEmpty()) {
                                        uImg = "https://images.unsplash.com/photo-1587293852726-70cdb56c2866?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80";
                                    }
                                    String nxtStatus = uStatus.equals("AVAILABLE") ? "FULL" : "AVAILABLE";
                        %>
                            <div class="card storage-card">
                                <div class="card-img-container">
                                    <img src="<%= uImg %>" alt="<%= uTitle %>" class="card-img">
                                    <span class="status-badge <%= uStatus.equals("AVAILABLE") ? "status-available" : "status-full" %>">
                                        <%= uStatus %>
                                    </span>
                                </div>
                                <div class="card-body">
                                    <h3 class="card-title" style="margin-bottom: 0.2rem;"><%= uTitle %></h3>
                                    <p class="text-muted" style="font-size: 0.85rem; margin-bottom: 1rem;"><%= uCity %></p>
                                    
                                    <div style="display: flex; flex-direction: column; gap: 0.5rem; margin-top: auto;">
                                        <div style="display: flex; gap: 0.5rem;">
                                            <a href="manage-listings.jsp?action=toggle&unitId=<%= uId %>&status=<%= nxtStatus %>" 
                                               class="btn btn-outline btn-mgmt" style="flex-grow: 1;">
                                               Mark <%= nxtStatus %>
                                            </a>
                                            <a href="manage-listings.jsp?editId=<%= uId %>" 
                                               class="btn btn-outline btn-mgmt" style="border-color: var(--primary); color: var(--primary);">
                                               Edit
                                            </a>
                                        </div>
                                        <button onclick="confirmDelete(<%= uId %>)" class="btn btn-mgmt btn-delete-mgmt">
                                            Delete Listing
                                        </button>
                                    </div>
                                </div>
                            </div>
                        <%
                                }
                                if(!hasUnits) {
                                    out.println("<div class='card' style='grid-column: 1/-1; padding: 4rem; text-align: center; background: #f8fafc; border: 2px dashed #cbd5e1;'>");
                                    out.println("<h3 class='text-muted'>No units listed yet.</h3>");
                                    out.println("<p>Start by adding your first storage unit to the platform.</p>");
                                    out.println("<a href='manage-listings.jsp' class='btn btn-primary' style='margin-top: 1.5rem;'>Add Your First Unit</a></div>");
                                }
                            } catch (Exception e) {}
                        %>
                    </div>

                    <div style="margin-top: 4rem; text-align: center; padding: 2rem; background: #f8fafc; border-radius: 20px;">
                        <h3 style="color: var(--secondary);">Detailed Reports</h3>
                        <p class="text-muted" style="margin-bottom: 1.5rem;">Need to see exactly who is in your units? View the full booking history.</p>
                        <a href="bookings-view.jsp" class="btn btn-outline" style="padding: 0.8rem 2rem;">Open Booking Logs</a>
                    </div>
                <% } %>
            </main>

            <script>
                function confirmDelete(id) {
                    if (confirm('Are you sure you want to PERMANENTLY delete this listing? Code: #'+id)) {
                        window.location.href = 'manage-listings.jsp?action=delete&unitId=' + id;
                    }
                }
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