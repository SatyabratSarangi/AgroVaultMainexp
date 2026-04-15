<%@ page import="java.sql.*" %>
<%@ include file="components/nav.jsp" %>

<style>
    .hero {
        position: relative;
        padding: 6rem 2rem;
        background: url('https://images.unsplash.com/photo-1595841696677-6489ffa3f66c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80') center/cover;
        border-radius: 24px;
        margin-top: 2rem;
        text-align: center;
        color: white;
        overflow: hidden;
    }
    
    .hero::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0; bottom: 0;
        background: rgba(0, 0, 0, 0.5);
        z-index: 1;
    }

    .hero-content {
        position: relative;
        z-index: 2;
        max-width: 800px;
        margin: 0 auto;
    }

    .hero h1 {
        font-size: 3.5rem;
        font-weight: 700;
        margin-bottom: 1rem;
        line-height: 1.2;
    }

    .hero p {
        font-size: 1.2rem;
        margin-bottom: 2rem;
        opacity: 0.9;
    }
    
    .features-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 2rem;
        margin-top: 4rem;
        margin-bottom: 4rem;
    }
    
    .feature-card {
        padding: 2rem;
        background: white;
        border-radius: 16px;
        text-align: center;
        box-shadow: 0 10px 30px rgba(0,0,0,0.05);
        transition: transform 0.3s;
    }
    
    .feature-card:hover {
        transform: translateY(-5px);
    }
    
    .feature-icon {
        width: 60px;
        height: 60px;
        background: rgba(46, 204, 113, 0.1);
        color: var(--primary);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 1.5rem;
    }
</style>

<main class="container">
    <div class="hero">
        <div class="hero-content">
            <h1>Connecting Farmers with Cold Storage Instantly</h1>
            <p>AgroVault eliminates the middleman, ensuring your harvest stays fresh while maximizing your profits through direct access to local storage facilities.</p>
            <% if (sessionUserId == null) { %>
                <a href="register.jsp" class="btn btn-primary" style="font-size: 1.2rem; padding: 1rem 2rem;">Join AgroVault Today</a>
            <% } else { %>
                <a href="<%= "FARMER".equals(sessionRole) ? "dashboard.jsp" : "manage-listings.jsp" %>" class="btn btn-primary" style="font-size: 1.2rem; padding: 1rem 2rem;">Go to Dashboard</a>
            <% } %>
        </div>
    </div>

    <div class="features-grid">
        <div class="feature-card">
            <div class="feature-icon">
                <svg width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
            </div>
            <h3 style="margin-bottom: 1rem;">Location Based</h3>
            <p class="text-muted">Smart filtering shows available storage units right in your city, saving transportation costs.</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon">
                <svg width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"></polyline></svg>
            </div>
            <h3 style="margin-bottom: 1rem;">Direct Booking</h3>
            <p class="text-muted">No agents. No hidden fees. Book the exact capacity you need with just one click.</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon">
                <svg width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
            </div>
            <h3 style="margin-bottom: 1rem;">Transparent Pricing</h3>
            <p class="text-muted">Compare rates from multiple storage owners instantly to get the best value for your crop.</p>
        </div>
    </div>
</main>

<%@ include file="components/footer.jsp" %>
