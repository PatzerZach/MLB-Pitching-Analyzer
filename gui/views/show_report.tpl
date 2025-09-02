% rebase('base')

<div class="effectiveness-wrapper">
  <h2 class="text-center text-light-teal">Final Project Report</h2>
  <div
    class="report-content"
    style="
      color: #1a2238;
      font-size: 18px;
      padding: 20px 60px;
      line-height: 1.7;
      max-width: 1000px;
      margin: 0 auto;
    "
  >
    <p>
      This project explores Major League Baseball (MLB) pitching performance
      using data-driven visualizations built with PostgreSQL, Bottle (Python),
      and D3.js. The goal was to transform historical pitching data into visuals
      that highlight trends, patterns, and standout performers. By combining
      normalized data, scoring formulas, and varied chart types, the site lets
      fans, analysts, and researchers explore close to a century and a half of
      MLB pitching in an interactive way.
    </p>
    <p>
      The first visualization,
      <strong>Pitching Effectiveness Over Time</strong>, calculates an annual
      effectiveness score by normalizing four stats: ERA, strikeouts, walks, and
      hits. Lower ERA, walks, and hits are inverted before applying a weighted
      formula: 0.4 × ERA + 0.3 × SO + 0.2 × BB + 0.1 × H. This produces a
      consistent 0–1 effectiveness score scale of overall pitching quality by
      year.
    </p>
    <p>
      The second visualization, <strong>Team Pitching Dominance</strong>,
      applies the same formula but instead of looking at years, we are looking
      at teams across all seasons. Normalized values are visualized as bubbles,
      sized and colored by effectiveness, allowing easy comparison of team-level
      pitching success.
    </p>
    <p>
      The third visualization, <strong>Pitchers in the Hall of Fame</strong>,
      compares Hall of Fame and non-Hall pitchers using a bar chart. It also
      lists the names of inducted pitchers, each linked to their Baseball
      Reference profile for more statistics.
    </p>
    <p>
      The fourth visualization, <strong>Runs Allowed</strong>, uses a geographic
      spike map. Each team’s total runs allowed over the years is shown as a
      spike at its city location. Teams in the same city are slightly offset,
      with spikes scaled by height and color.
    </p>
    <p>
      The fifth visualization, <strong>Games Played</strong>, uses a radial bar
      chart to show the number of games each pitcher appeared in. Stats are
      totaled across careers, and users can filter to the top 100.
    </p>
    <p>
      The sixth visualization, <strong>Strikeouts vs Walks</strong>, is a
      scatter plot mapping total career SO and BB (Base on Balls / Walks). Users
      can view all pitchers or the top 100 by SO/BB ratio.
    </p>
    <p>
      The seventh visualization, <strong>Home Runs vs ERA</strong>, uses a
      bubble chart to score pitchers by low ERA and few HRs allowed. Bubble size
      and color reflect calculated effectiveness, with a filter for the top 100.
    </p>
    <p>
      The eighth visualization, <strong>Clutch Pitching</strong>, ranks pitchers
      using a formula based on ERA, SO/BB, games finished, and home runs
      allowed. Lower scores indicate better clutch performance, shown in a
      color-graded horizontal bar chart of the top 50.
    </p>
    <p>
      The ninth visualization, <strong>Innings Pitched Over Time</strong>, uses
      a line chart to track average innings pitched per pitcher each year,
      derived from IPouts divided by 3 which equates to the number of innings
      pitched. Since IPouts is outs pitched, and there are 3 outs per inning,
      dividing IPouts by 3 gets us almost spot on to the exact innings pitched
      statistic without having that exact value in our database.
    </p>
    <p>
      The final visualization, <strong>Batters Faced</strong>, shows the top 50
      pitchers by total batters faced (BFP) using a vertical bar chart,
      highlighting workload and longevity.
    </p>
  </div>
</div>
