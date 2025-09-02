% rebase('base.tpl')

<!-- Hero Section with Video Background -->
<section class="hero">
  <div class="hero-background">
    <video autoplay muted loop playsinline>
      <source src="/static/Baseball_Final_Small.webm" type="video/webm" />
    </video>
  </div>
  <div class="hero-overlay"></div>

  <div class="hero-content">
    <h1 class="hero-title">Mound Metrics</h1>
    <p class="hero-subtitle">Advanced MLB Pitching Analytics Platform</p>
    <div class="hero-buttons">
      <a href="#features" class="btn btn-primary">Explore Analytics</a>
      <a href="/teams" class="btn btn-outline">View Teams</a>
    </div>
  </div>

  <div class="scroll-indicator">
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      width="24"
      height="24"
    >
      <path fill="none" d="M0 0h24v24H0z" />
      <path
        d="M12 13.172l4.95-4.95 1.414 1.414L12 16 5.636 9.636 7.05 8.222z"
        fill="currentColor"
      />
    </svg>
  </div>
</section>

<!-- Features Section -->
<section id="features" class="features">
  <div class="section-title">
    <span class="section-subtitle">Data Visualizations</span>
    <h2 class="section-heading">Discover MLB Pitching Performance Insights</h2>
  </div>

  <div class="features-grid">
    <!-- Feature Card 1 -->
    <div class="feature-card">
      <img
        src="/static/images/effectiveness.jpg"
        alt="Pitching Effectiveness"
        class="feature-image"
      />
      <div class="feature-content">
        <h3 class="feature-title">Pitching Effectiveness</h3>
        <p class="feature-description">
          Track the evolution of pitching effectiveness across MLB history
          through our comprehensive time-series analysis. This visualization
          combines ERA, strikeouts, walks, and hits allowed into a single
          effectiveness metric.
        </p>
        <a href="/effectiveness" class="feature-link">
          Explore
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            width="18"
            height="18"
          >
            <path fill="none" d="M0 0h24v24H0z" />
            <path
              d="M16.172 11l-5.364-5.364 1.414-1.414L20 12l-7.778 7.778-1.414-1.414L16.172 13H4v-2z"
              fill="currentColor"
            />
          </svg>
        </a>
      </div>
    </div>

    <!-- Feature Card 2 -->
    <div class="feature-card">
      <img
        src="/static/images/team-dominance.jpg"
        alt="Team Dominance"
        class="feature-image"
      />
      <div class="feature-content">
        <h3 class="feature-title">Team Dominance</h3>
        <p class="feature-description">
          Compare pitching dominance across teams with our interactive bubble
          visualization. See which franchises have developed the most effective
          pitching staffs throughout baseball history.
        </p>
        <a href="/team_dominance" class="feature-link">
          Explore
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            width="18"
            height="18"
          >
            <path fill="none" d="M0 0h24v24H0z" />
            <path
              d="M16.172 11l-5.364-5.364 1.414-1.414L20 12l-7.778 7.778-1.414-1.414L16.172 13H4v-2z"
              fill="currentColor"
            />
          </svg>
        </a>
      </div>
    </div>

    <!-- Feature Card 3 -->
    <div class="feature-card">
      <img
        src="/static/images/hof.jpg"
        alt="Pitcher Hall of Fame"
        class="feature-image"
      />
      <div class="feature-content">
        <h3 class="feature-title">Pitcher Hall of Fame</h3>
        <p class="feature-description">
          Discover what makes a Hall of Fame pitcher with our detailed analysis
          of pitchers who have been inducted into Cooperstown. Explore the
          statistical achievements that separate the greats from the rest.
        </p>
        <a href="/pitcher_hof" class="feature-link">
          Explore
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            width="18"
            height="18"
          >
            <path fill="none" d="M0 0h24v24H0z" />
            <path
              d="M16.172 11l-5.364-5.364 1.414-1.414L20 12l-7.778 7.778-1.414-1.414L16.172 13H4v-2z"
              fill="currentColor"
            />
          </svg>
        </a>
      </div>
    </div>

    <!-- Feature Card 4 -->
    <div class="feature-card">
      <img
        src="/static/images/runs-allowed.jpg"
        alt="Runs Allowed"
        class="feature-image"
      />
      <div class="feature-content">
        <h3 class="feature-title">Runs Allowed Map</h3>
        <p class="feature-description">
          Visualize runs allowed by teams across the United States with our
          interactive spike map. Identify geographic patterns and see which
          regions have produced the most effective pitching staffs.
        </p>
        <a href="/runs_allowed" class="feature-link">
          Explore
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            width="18"
            height="18"
          >
            <path fill="none" d="M0 0h24v24H0z" />
            <path
              d="M16.172 11l-5.364-5.364 1.414-1.414L20 12l-7.778 7.778-1.414-1.414L16.172 13H4v-2z"
              fill="currentColor"
            />
          </svg>
        </a>
      </div>
    </div>

    <!-- Feature Card 5 -->
    <div class="feature-card">
      <img
        src="/static/images/games-played.jpg"
        alt="Games Played"
        class="feature-image"
      />
      <div class="feature-content">
        <h3 class="feature-title">Games Played</h3>
        <p class="feature-description">
          Explore pitcher durability and longevity through our radial chart
          visualization of games played. Discover the workhorses of baseball who
          have taken the mound most frequently throughout history.
        </p>
        <a href="/games_played" class="feature-link">
          Explore
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            width="18"
            height="18"
          >
            <path fill="none" d="M0 0h24v24H0z" />
            <path
              d="M16.172 11l-5.364-5.364 1.414-1.414L20 12l-7.778 7.778-1.414-1.414L16.172 13H4v-2z"
              fill="currentColor"
            />
          </svg>
        </a>
      </div>
    </div>

    <!-- Feature Card 6 -->
    <div class="feature-card">
      <img
        src="/static/images/strikeouts-walks.jpg"
        alt="Strikeouts vs Walks"
        class="feature-image"
      />
      <div class="feature-content">
        <h3 class="feature-title">Strikeouts vs Walks</h3>
        <p class="feature-description">
          Analyze pitcher command and dominance with our scatter plot
          visualization comparing strikeouts to walks. Identify pitchers with
          the best combination of swing-and-miss stuff and pinpoint control.
        </p>
        <a href="/walk_strikeout" class="feature-link">
          Explore
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            width="18"
            height="18"
          >
            <path fill="none" d="M0 0h24v24H0z" />
            <path
              d="M16.172 11l-5.364-5.364 1.414-1.414L20 12l-7.778 7.778-1.414-1.414L16.172 13H4v-2z"
              fill="currentColor"
            />
          </svg>
        </a>
      </div>
    </div>

    <!-- Feature Card 7 -->
    <div class="feature-card">
      <img
        src="/static/images/hr-era.jpg"
        alt="Homeruns vs ERA"
        class="feature-image"
      />
      <div class="feature-content">
        <h3 class="feature-title">Homeruns vs ERA</h3>
        <p class="feature-description">
          Investigate the relationship between home runs allowed and earned run
          average with our bubble chart visualization. Discover how giving up
          the long ball impacts a pitcher's overall effectiveness.
        </p>
        <a href="/hr_vs_era" class="feature-link">
          Explore
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            width="18"
            height="18"
          >
            <path fill="none" d="M0 0h24v24H0z" />
            <path
              d="M16.172 11l-5.364-5.364 1.414-1.414L20 12l-7.778 7.778-1.414-1.414L16.172 13H4v-2z"
              fill="currentColor"
            />
          </svg>
        </a>
      </div>
    </div>

    <!-- Feature Card 8 -->
    <div class="feature-card">
      <img
        src="/static/images/clutch.jpg"
        alt="Clutch Pitching"
        class="feature-image"
      />
      <div class="feature-content">
        <h3 class="feature-title">Clutch Pitching</h3>
        <p class="feature-description">
          Identify the most clutch pitchers in baseball history with our
          specialized metric combining ERA, strikeout-to-walk ratio, games
          finished, and home runs allowed to determine who performs best when it
          matters most.
        </p>
        <a href="/clutch_pitching" class="feature-link">
          Explore
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            width="18"
            height="18"
          >
            <path fill="none" d="M0 0h24v24H0z" />
            <path
              d="M16.172 11l-5.364-5.364 1.414-1.414L20 12l-7.778 7.778-1.414-1.414L16.172 13H4v-2z"
              fill="currentColor"
            />
          </svg>
        </a>
      </div>
    </div>

    <!-- Feature Card 9 -->
    <div class="feature-card">
      <img
        src="/static/images/innings.jpg"
        alt="Innings Pitched Trend"
        class="feature-image"
      />
      <div class="feature-content">
        <h3 class="feature-title">Innings Pitched Trend</h3>
        <p class="feature-description">
          Track how pitcher workload has evolved throughout baseball history
          with our time-series visualization of average innings pitched. See how
          the modern game has changed the way pitchers are utilized.
        </p>
        <a href="/innings_trend" class="feature-link">
          Explore
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            width="18"
            height="18"
          >
            <path fill="none" d="M0 0h24v24H0z" />
            <path
              d="M16.172 11l-5.364-5.364 1.414-1.414L20 12l-7.778 7.778-1.414-1.414L16.172 13H4v-2z"
              fill="currentColor"
            />
          </svg>
        </a>
      </div>
    </div>

    <!-- Feature Card 10 -->
    <div class="feature-card">
      <img
        src="/static/images/batters-faced.jpg"
        alt="Most Batters Faced"
        class="feature-image"
      />
      <div class="feature-content">
        <h3 class="feature-title">Most Batters Faced</h3>
        <p class="feature-description">
          Discover which pitchers have faced the most batters in baseball
          history. This visualization reveals the elite workhorses who have
          stood on the mound against thousands of hitters throughout their
          careers.
        </p>
        <a href="/batters_faced" class="feature-link">
          Explore
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            width="18"
            height="18"
          >
            <path fill="none" d="M0 0h24v24H0z" />
            <path
              d="M16.172 11l-5.364-5.364 1.414-1.414L20 12l-7.778 7.778-1.414-1.414L16.172 13H4v-2z"
              fill="currentColor"
            />
          </svg>
        </a>
      </div>
    </div>
  </div>
</section>
