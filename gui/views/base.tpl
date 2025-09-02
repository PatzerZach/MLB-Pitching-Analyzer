<!DOCTYPE html>
<html lang="en">
  <head>
    <title>Mound Metrics | MLB Pitching Analyzer</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link
      rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
    />
    <link
      rel="stylesheet"
      href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css"
    />
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link
      href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Poppins:wght@300;400;500;600;700&display=swap"
      rel="stylesheet"
    />
    <link rel="icon" type="image/x-icon" href="/static/favicon.ico" />
    <link rel="stylesheet" href="/static/styles.css" />
  </head>
  <body
    class="{{'home-page' if request.path == '/' or request.path == '/home' else ''}}"
  >
    <div class="app-container">
      <!-- Header -->
      <header>
        <a href="/home" class="brand">
          <span class="brand-logo">⚾</span>
          <h1 class="brand-name">Mound Metrics</h1>
        </a>

        <nav class="main-nav">
          <ul class="nav-list">
            <li class="nav-item">
              <a href="/home" class="nav-link">Home</a>
            </li>
            <li class="nav-item">
              <a href="/report" class="nav-link">Report</a>
            </li>
            <li class="nav-item">
              <a href="/teams" class="nav-link">Teams</a>
            </li>
            <li class="nav-item">
              <a href="#" class="nav-link" id="visualizations-toggle"
                >Visualizations</a
              >
            </li>
          </ul>
          <button id="search-toggle" class="search-toggle">
            <i class="fas fa-search"></i>
          </button>
        </nav>
      </header>

      <!-- Search Container -->
      <div class="search-container">
        <input
          type="text"
          class="search-input"
          placeholder="Search visualizations..."
        />
        <button class="search-close">
          <i class="fas fa-times"></i>
        </button>
      </div>

      <!-- Sidebar Toggle -->
      <button class="sidebar-toggle" id="sidebar-toggle">
        <i class="fas fa-bars"></i>
      </button>

      <!-- Sidebar -->
      <aside class="sidebar" id="sidebar">
        <div class="sidebar-header">
          <h3 class="sidebar-title">Data Visualizations</h3>
        </div>

        <ul class="sidebar-menu">
          <li class="sidebar-item">
            <a href="/effectiveness" class="sidebar-link">
              <i class="fas fa-chart-line sidebar-icon"></i>
              Pitching Effectiveness
            </a>
          </li>
          <li class="sidebar-item">
            <a href="/team_dominance" class="sidebar-link">
              <i class="fas fa-trophy sidebar-icon"></i>
              Team Dominance
            </a>
          </li>
          <li class="sidebar-item">
            <a href="/pitcher_hof" class="sidebar-link">
              <i class="fas fa-medal sidebar-icon"></i>
              Pitcher Hall of Fame
            </a>
          </li>
          <li class="sidebar-item">
            <a href="/runs_allowed" class="sidebar-link">
              <i class="fas fa-map-marker-alt sidebar-icon"></i>
              Runs Allowed
            </a>
          </li>
          <li class="sidebar-item">
            <a href="/games_played" class="sidebar-link">
              <i class="fas fa-baseball-ball sidebar-icon"></i>
              Games Played
            </a>
          </li>
          <li class="sidebar-item">
            <a href="/walk_strikeout" class="sidebar-link">
              <i class="fas fa-grip-lines-vertical sidebar-icon"></i>
              Strikeouts vs Walks
            </a>
          </li>
          <li class="sidebar-item">
            <a href="/hr_vs_era" class="sidebar-link">
              <i class="fas fa-chart-pie sidebar-icon"></i>
              Homeruns vs ERA
            </a>
          </li>
          <li class="sidebar-item">
            <a href="/clutch_pitching" class="sidebar-link">
              <i class="fas fa-star sidebar-icon"></i>
              Clutch Pitching
            </a>
          </li>
          <li class="sidebar-item">
            <a href="/innings_trend" class="sidebar-link">
              <i class="fas fa-chart-area sidebar-icon"></i>
              Innings Pitched Trend
            </a>
          </li>
          <li class="sidebar-item">
            <a href="/batters_faced" class="sidebar-link">
              <i class="fas fa-users sidebar-icon"></i>
              Most Batters Faced
            </a>
          </li>
        </ul>
      </aside>

      <!-- Main Content -->
      <main class="main-container">
        {{ !base }}
      </main>

      <!-- Footer -->
      <footer>
        <div class="footer-content">
          <div class="footer-brand">
            <div class="footer-logo">Mound Metrics</div>
            <p class="footer-description">
              Advanced analytics for MLB pitching performance, providing
              data-driven insights for baseball enthusiasts and professionals.
            </p>
            <div class="footer-social">
              <a href="#" class="social-link"><i class="fab fa-twitter"></i></a>
              <a href="https://github.com/PatzerZach" class="social-link"
                ><i class="fab fa-github"></i
              ></a>
              <a href="https://www.linkedin.com/in/zpatzer" class="social-link"
                ><i class="fab fa-linkedin"></i
              ></a>
            </div>
          </div>

          <div class="footer-nav">
            <h4 class="footer-heading">Visualizations</h4>
            <ul class="footer-links">
              <li>
                <a href="/effectiveness" class="footer-link"
                  >Pitching Effectiveness</a
                >
              </li>
              <li>
                <a href="/team_dominance" class="footer-link">Team Dominance</a>
              </li>
              <li>
                <a href="/pitcher_hof" class="footer-link"
                  >Pitcher Hall of Fame</a
                >
              </li>
              <li>
                <a href="/runs_allowed" class="footer-link">Runs Allowed</a>
              </li>
              <li>
                <a href="/games_played" class="footer-link">Games Played</a>
              </li>
            </ul>
          </div>

          <div class="footer-nav">
            <h4 class="footer-heading"></h4>
            <ul class="footer-links">
              <li>
                <a href="" class="footer-link"></a>
              </li>
              <li>
                <a href="" class="footer-link"></a>
              </li>
              <li>
                <a href="/walk_strikeout" class="footer-link"
                  >Strikeouts vs Walks</a
                >
              </li>
              <li>
                <a href="/hr_vs_era" class="footer-link">Homeruns vs ERA</a>
              </li>
              <li>
                <a href="/clutch_pitching" class="footer-link"
                  >Clutch Pitching</a
                >
              </li>
              <li>
                <a href="/innings_trend" class="footer-link">Innings Pitched</a>
              </li>
              <li>
                <a href="/batters_faced" class="footer-link">Batters Faced</a>
              </li>
            </ul>
          </div>

          <div class="footer-nav">
            <h4 class="footer-heading">Resources</h4>
            <ul class="footer-links">
              <li>
                <a
                  href="https://www.baseball-reference.com/"
                  class="footer-link"
                  >Extra Pitching Statistics</a
                >
              </li>
              <li>
                <a href="https://www.mlb.com/stats/2015" class="footer-link"
                  >MLB Resources</a
                >
              </li>
              <li><a href="#" class="footer-link">About Our Data</a></li>
              <li>
                <a
                  href="https://www.youtube.com/watch?v=xvFZjo5PgG0"
                  class="footer-link"
                  >Contact</a
                >
              </li>
            </ul>
          </div>
        </div>

        <div class="footer-copyright">
          &copy; 2025 Mound Metrics. Powered by Bottle, D3.js, and PostgreSQL.
        </div>
      </footer>
    </div>

    <script>
      document.addEventListener("DOMContentLoaded", function () {
        // Header scroll effect
        const header = document.querySelector("header");
        window.addEventListener("scroll", function () {
          if (window.scrollY > 50) {
            header.classList.add("scrolled");
          } else {
            header.classList.remove("scrolled");
          }
        });

        // Search functionality
        const searchToggle = document.getElementById("search-toggle");
        const searchContainer = document.querySelector(".search-container");
        const searchClose = document.querySelector(".search-close");
        const searchInput = document.querySelector(".search-input");

        searchToggle.addEventListener("click", function () {
          searchContainer.classList.add("active");
          searchInput.focus();
        });

        searchClose.addEventListener("click", function () {
          searchContainer.classList.remove("active");
        });

        // Sidebar toggle
        const sidebarToggle = document.getElementById("sidebar-toggle");
        const sidebar = document.getElementById("sidebar");
        const visualizationsToggle = document.getElementById(
          "visualizations-toggle"
        );

        sidebarToggle.addEventListener("click", function () {
          sidebar.classList.toggle("active");
        });

        visualizationsToggle.addEventListener("click", function (e) {
          e.preventDefault();
          sidebar.classList.toggle("active");
        });

        // Add the active class to the current sidebar link
        const currentLocation = window.location.pathname;
        const sidebarLinks = document.querySelectorAll(".sidebar-link");

        sidebarLinks.forEach((link) => {
          const linkPath = link.getAttribute("href");
          if (currentLocation === linkPath) {
            link.classList.add("active");
          }
        });

        // Search functionality
        const searchInputField = document.querySelector(".search-input");

        searchInputField.addEventListener("keyup", function (e) {
          const searchTerm = e.target.value.toLowerCase();
          const sidebarItems = document.querySelectorAll(".sidebar-item");

          sidebarItems.forEach((item) => {
            const text = item.textContent.toLowerCase();
            if (text.includes(searchTerm)) {
              item.style.display = "";
            } else {
              item.style.display = "none";
            }
          });

          // If Enter is pressed, navigate to the first visible link
          if (e.key === "Enter") {
            const firstVisibleLink = document.querySelector(
              '.sidebar-item:not([style*="display: none"]) .sidebar-link'
            );
            if (firstVisibleLink) {
              window.location.href = firstVisibleLink.getAttribute("href");
            }
          }
        });

        // Scroll animations for feature cards on home page
        const observerOptions = {
          root: null,
          rootMargin: "0px",
          threshold: 0.1,
        };

        const observer = new IntersectionObserver((entries, observer) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              entry.target.classList.add("animated");
              observer.unobserve(entry.target);
            }
          });
        }, observerOptions);

        const animateElements = document.querySelectorAll(".feature-card");
        animateElements.forEach((el) => observer.observe(el));
      });
    </script>
  </body>
</html>
