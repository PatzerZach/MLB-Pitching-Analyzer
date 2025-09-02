% rebase('base')

<div class="visualization-container">
  <div class="visualization-header">
    <h2 class="visualization-title">Clutch Pitching Performance Analysis</h2>
    <p class="visualization-description">
      This visualization ranks pitchers by their clutch performance metrics,
      combining ERA, strikeout-to-walk ratio, games finished, and home runs
      allowed. Lower scores indicate pitchers who performed best in
      high-pressure situations. Discover which pitchers demonstrated the most
      composure and effectiveness when the game was on the line.
    </p>
  </div>

  <div class="visualization-content">
    <div class="chart-container">
      <svg id="clutch-bar-chart" width="100%" height="100%"></svg>
    </div>
  </div>

  <div id="tooltip" class="tooltip"></div>
</div>

<style>
  .effectiveness-wrapper {
    background-color: #ffffff;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }

  .tooltip {
    position: absolute;
    background-color: #003135;
    color: #afdde5;
    padding: 8px 12px;
    font-size: 14px;
    border-radius: 8px;
    pointer-events: none;
    border: 1px solid #0fa4af;
    box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.3);
  }
</style>

<script src="https://d3js.org/d3.v7.min.js"></script>
<script>
  document.addEventListener("DOMContentLoaded", function () {
    const chartContainer = document.querySelector(".chart-container");
    const containerWidth = chartContainer.clientWidth;
    const containerHeight = chartContainer.clientHeight;

    d3.json("/api/clutch_pitching_data").then((rawData) => {
      const data = rawData.sort((a, b) => a.score - b.score); // The lower the score the better

      const svg = d3
        .select("#clutch-bar-chart")
        .attr("width", containerWidth)
        .attr("height", containerHeight);

      svg.selectAll("*").remove();

      const width = containerWidth;
      const height = containerHeight;
      const margin = { top: 40, right: 40, bottom: 40, left: 260 };

      const innerWidth = width - margin.left - margin.right;
      const innerHeight = height - margin.top - margin.bottom;

      const x = d3
        .scaleLinear()
        .domain([0, d3.max(data, (d) => d.score)])
        .range([margin.left, width - margin.right]);

      const y = d3
        .scaleBand()
        .domain(data.map((d) => d.fullName).reverse())
        .range([margin.top, height - margin.bottom])
        .padding(0.4);

      const scores = data.map((d) => d.score).sort((a, b) => a - b);
      const best = scores[0];
      const worst = scores[Math.floor(scores.length * 0.9)];

      const color = d3
        .scaleSequential(d3.interpolateBlues)
        .domain([best, worst]);

      const tooltip = d3.select("#tooltip");

      // title
      svg
        .append("text")
        .attr("x", width / 2)
        .attr("y", 20)
        .attr("text-anchor", "middle")
        .style("font-size", "18px")
        .style("font-weight", "bold")
        .style("fill", "#003135")
        .text("Top 50 Clutch Pitchers (Lower Score = Better Performance)");

      // X axis
      svg
        .append("g")
        .attr("transform", `translate(0,${margin.top})`)
        .call(d3.axisTop(x))
        .selectAll("text")
        .style("font-size", "14px");

      // Y axis
      svg
        .append("g")
        .attr("transform", `translate(${margin.left},0)`)
        .call(d3.axisLeft(y).tickSize(0))
        .selectAll("text")
        .style("font-size", "12px")
        .style("font-family", "Inter, sans-serif");

      // X axis label
      svg
        .append("text")
        .attr("x", width / 2)
        .attr("y", height - 5)
        .attr("text-anchor", "middle")
        .style("font-size", "14px")
        .style("fill", "#0FA4AF")
        .text("Clutch Performance Score");

      // bars with animation
      svg
        .selectAll("rect")
        .data(data)
        .join("rect")
        .attr("x", margin.left)
        .attr("y", (d) => y(d.fullName) + y.bandwidth() * 0.1)
        .attr("width", 0)
        .attr("height", y.bandwidth() * 0.8)
        .attr("fill", (d) => color(d.score))
        .attr("stroke", "#003135")
        .attr("stroke-width", 0.5)
        .on("mousemove", (event, d) => {
          tooltip
            .style("left", event.pageX + 10 + "px")
            .style("top", event.pageY - 30 + "px")
            .style("opacity", 1).html(`
            <strong>${d.fullName}</strong><br>
            ERA: ${d.ERA} | K/BB: ${d.KBB}<br>
            GF: ${d.GF}, HR: ${d.HR}<br>
            Score: ${d.score}
          `);
        })
        .on("mouseleave", () => tooltip.style("opacity", 0))
        .transition()
        .duration(800)
        .delay((d, i) => i * 20)
        .attr("width", (d) => x(d.score) - margin.left);

      svg
        .append("g")
        .attr("class", "grid")
        .attr("transform", `translate(0,${margin.top})`)
        .call(
          d3
            .axisTop(x)
            .tickSize(-(height - margin.top - margin.bottom))
            .tickFormat("")
        )
        .selectAll("line")
        .style("stroke", "#e0e0e0")
        .style("stroke-opacity", 0.7);

      // Add score labels on right of bars for better performers
      svg
        .selectAll(".score-label")
        .data(data.slice(0, 10))
        .join("text")
        .attr("class", "score-label")
        .attr("x", (d) => x(d.score) + 5)
        .attr("y", (d) => y(d.fullName) + y.bandwidth() / 2 + 2)
        .attr("text-anchor", "start")
        .style("font-size", "12px")
        .style("fill", "#003135")
        .style("font-weight", "bold")
        .style("opacity", 0)
        .text((d) => d.score.toFixed(2))
        .transition()
        .delay(1000)
        .duration(500)
        .style("opacity", 1);
    });
  });

  // window resize
  window.addEventListener("resize", function () {
    if (!window.lastResize || Date.now() - window.lastResize > 500) {
      window.lastResize = Date.now();

      if (
        window.lastWidth &&
        (Math.abs(window.innerWidth - window.lastWidth) > 100 ||
          Math.abs(window.innerHeight - window.lastHeight) > 100)
      ) {
        location.reload();
      }

      window.lastWidth = window.innerWidth;
      window.lastHeight = window.innerHeight;
    }
  });
</script>
