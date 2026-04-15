<%@ page import="java.sql.*" %>
<%@ include file="components/nav.jsp" %>

<main class="container">
    <div class="header-section text-center" style="display: block; margin-top: 3rem;">
        <h1 class="page-title">How can we help?</h1>
        <p class="text-muted" style="font-size: 1.1rem;">We're here to ensure your AgroVault experience is smooth and profitable.</p>
    </div>

    <div class="form-card" style="margin-top: 3rem; max-width: 600px;">
        <h3 style="margin-bottom: 1.5rem;">Send us a message</h3>
        <form onsubmit="event.preventDefault(); alert('We have received your message! A representative will contact you shortly.');">
            <div class="form-group">
                <label class="form-label">Subject</label>
                <input type="text" class="form-control" placeholder="What do you need help with?" required>
            </div>
            <div class="form-group">
                <label class="form-label">Message</label>
                <textarea rows="5" class="form-control" placeholder="Describe your issue..." required></textarea>
            </div>
            <button type="submit" class="btn btn-primary" style="width: 100%;">Submit Inquiry</button>
        </form>
    </div>
</main>

<%@ include file="components/footer.jsp" %>
