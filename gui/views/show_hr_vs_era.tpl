% rebase('base')

<div class="visualization-container">
  <div class="visualization-header">
    <h2 class="visualization-title">Home Runs vs ERA Analysis</h2>
    <p class="visualization-description">
      This visualization explores the relationship between home runs allowed and
      earned run average (ERA). The bubble chart reveals how giving up home run
      ball impacts a pitcher's overall effectiveness. Larger bubbles represent
      pitchers with better performance relative to home runs allowed and ERA.
    </p>
  </div>

  <div class="visualization-content">
    <div class="visualization-actions">
      <div class="viz-filters">
        <select id="filterSelect" class="viz-filter-select">
          <option value="all">All Pitchers</option>
          <option value="top100">Top 100 (Best Score)</option>
        </select>
      </div>
    </div>

    <div class="chart-container">
      <svg id="bubble-chart" width="100%" height="100%"></svg>
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

  .header-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
  }

  .filter-dropdown select {
    padding: 8px 12px;
    border-radius: 8px;
    font-size: 16px;
    border: 1px solid #0fa4af;
    background-color: #f8f9fa;
    color: #003135;
    cursor: pointer;
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
  let originalData = [];
  let playerNameMap = {};

  d3.json("/api/batters_faced")
    .then((playerData) => {
      playerNameMap = playerData.reduce((map, player) => {
        map[player.playerID] = player.fullName;
        return map;
      }, {});

      return d3.json("/api/hr_vs_era_data");
    })
    .then((data) => {
      originalData = data
        .map((d) => ({
          ...d,
          HR: +d.HR,
          ERA: +d.ERA,
          IP: +d.IP,
          score: d.IP > 0 && d.ERA > 0 ? (d.HR / d.IP) * d.ERA : Infinity,
          fullName: playerNameMap[d.playerID] || d.playerID,
        }))
        .filter((d) => isFinite(d.score) && d.score > 0 && d.IP > 0);

      drawBubbles(originalData);

      d3.select("#filterSelect").on("change", function () {
        const selected = this.value;
        if (selected === "all") {
          drawBubbles(originalData);
        } else if (selected === "top100") {
          const filtered = originalData
            .filter((d) => isFinite(d.score) && d.score > 0)
            .sort((a, b) => a.score - b.score)
            .slice(0, 100);
          drawBubbles(filtered);
        }
      });
    });

  function drawBubbles(data) {
    const chartContainer = document.querySelector(".chart-container");
    const width = chartContainer.clientWidth;
    const height = chartContainer.clientHeight;

    const svg = d3
      .select("#bubble-chart")
      .attr("width", width)
      .attr("height", height);

    svg.selectAll("*").remove();

    const margin = { top: 40, right: 60, bottom: 70, left: 80 };
    const innerWidth = width - margin.left - margin.right;
    const innerHeight = height - margin.top - margin.bottom;

    const x = d3
      .scaleLinear()
      .domain([0, d3.max(data, (d) => d.HR) * 1.1])
      .range([margin.left, width - margin.right]);

    const y = d3
      .scaleLinear()
      .domain([0, d3.max(data, (d) => d.ERA) * 1.1])
      .range([height - margin.bottom, margin.top]);

    const scoreExtent = data.map((d) => d.score).sort((a, b) => a - b);

    const scoreMin = scoreExtent[0];
    const scoreMax = scoreExtent[Math.floor(scoreExtent.length * 0.9)];

    const r = d3.scaleSqrt().domain([scoreMin, scoreMax]).range([25, 3]);

    const color = d3
      .scaleSequential(d3.interpolateBlues)
      .domain([scoreMax, scoreMin]);

    const tooltip = d3.select("#tooltip");

    // X Axis
    svg
      .append("g")
      .attr("transform", `translate(0,${height - margin.bottom})`)
      .call(d3.axisBottom(x))
      .append("text")
      .attr("x", width / 2)
      .attr("y", 50)
      .attr("fill", "#0FA4AF")
      .attr("font-size", "16px")
      .attr("text-anchor", "middle")
      .text("Home Runs Allowed");

    // Y Axis
    svg
      .append("g")
      .attr("transform", `translate(${margin.left},0)`)
      .call(d3.axisLeft(y))
      .append("text")
      .attr("x", -height / 2)
      .attr("y", -50)
      .attr("transform", "rotate(-90)")
      .attr("fill", "#0FA4AF")
      .attr("font-size", "16px")
      .attr("text-anchor", "middle")
      .text("ERA");

    // Bubbles with animation
    const bubbles = svg
      .append("g")
      .selectAll("circle")
      .data(data)
      .join("circle")
      .attr("cx", (d) => x(d.HR))
      .attr("cy", (d) => y(d.ERA))
      .attr("r", 0) // Start with radius 0 for animation
      .attr("fill", (d) => color(d.score))
      .attr("stroke", "#003135")
      .attr("stroke-width", 0.3)
      .attr("opacity", 0)
      .on("mousemove", (event, d) => {
        tooltip
          .style("left", event.pageX + 10 + "px")
          .style("top", event.pageY - 30 + "px")
          .style("opacity", 1).html(`<strong>${d.fullName}</strong><br>
               HR Allowed: ${d.HR}<br>
               ERA: ${d.ERA.toFixed(2)}<br>
               IP: ${d.IP.toFixed(1)}<br>
               Score: ${d.score.toFixed(4)}`);
      })
      .on("mouseleave", () => tooltip.style("opacity", 0));

    // Animate the bubbles
    bubbles
      .transition()
      .duration(300)
      .delay((d, i) => i * 1)
      .attr("r", (d) => r(d.score))
      .attr("opacity", 0.8);
  }

  // window resize
  window.addEventListener("resize", function () {
    const chartContainer = document.querySelector(".chart-container");
    if (chartContainer && originalData.length > 0) {
      drawBubbles(
        document.getElementById("filterSelect").value === "all"
          ? originalData
          : originalData
              .filter((d) => isFinite(d.score) && d.score > 0)
              .sort((a, b) => a.score - b.score)
              .slice(0, 100)
      );
    }
  });
</script>
