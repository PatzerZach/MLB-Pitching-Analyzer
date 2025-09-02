% rebase('base')

<div class="visualization-container">
  <div class="visualization-header">
    <h2 class="visualization-title">Games Played Radial Distribution</h2>
    <p class="visualization-description">
      This visualization explores pitcher durability and longevity through a
      radial chart of games played. Each segment represents a pitcher, with
      longer bars indicating more games played throughout their career. This
      shows the workhorses of baseball who have taken the mound most frequently
      in MLB history.
    </p>
  </div>

  <div class="visualization-content">
    <div class="visualization-actions">
      <div class="viz-filters">
        <select id="filterSelect" class="viz-filter-select">
          <option value="all">All Pitchers</option>
          <option value="top100">Top 100 Pitchers</option>
          <option value="top50">Top 50 Pitchers</option>
        </select>
      </div>
    </div>

    <div class="chart-container">
      <svg
        id="games-chart"
        width="100%"
        height="100%"
        viewBox="0 0 800 600"
        preserveAspectRatio="xMidYMid meet"
      ></svg>
    </div>
  </div>

  <div id="tooltip" class="tooltip"></div>
</div>

<style>
  .visualization-container {
    height: auto;
    min-height: 100vh;
    padding-bottom: 20px;
  }

  .chart-container {
    height: calc(100vh - 250px);
    min-height: 600px;
    margin-bottom: 20px;
  }

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

      return d3.json("/api/games_played_data");
    })
    .then((data) => {
      // Add full name to each data point
      originalData = data.map((d) => ({
        ...d,
        fullName: playerNameMap[d.playerID] || d.playerID,
      }));

      drawRadialChart(originalData);

      d3.select("#filterSelect").on("change", function () {
        const selected = this.value;
        if (selected === "all") {
          drawRadialChart(originalData);
        } else if (selected === "top100") {
          const filtered = originalData
            .slice()
            .sort((a, b) => d3.descending(a.G, b.G))
            .slice(0, 100);
          drawRadialChart(filtered);
        } else if (selected === "top50") {
          const filtered = originalData
            .slice()
            .sort((a, b) => d3.descending(a.G, b.G))
            .slice(0, 50);
          drawRadialChart(filtered);
        }
      });
    })
    .catch((error) => {
      console.error("Error loading games played data:", error);
    });

  function drawRadialChart(chartData) {
    const chartContainer = document.querySelector(".chart-container");
    const containerWidth = chartContainer.clientWidth;
    const containerHeight = chartContainer.clientHeight;

    const svg = d3.select("#games-chart");

    const width = 800;
    const height = 600;
    const innerRadius = 30;
    const outerRadius = Math.min(width, height) * 0.35;
    const centerX = width / 2;
    const centerY = height / 2;

    const tooltip = d3.select("#tooltip");

    svg.selectAll("*").remove();

    chartData = chartData
      .sort((a, b) => d3.descending(a.G, b.G))
      .slice(0, 9127);

    const minG = d3.min(chartData, (d) => d.G);
    const maxG = d3.max(chartData, (d) => d.G);

    const angleScale = d3
      .scaleBand()
      .domain(chartData.map((d) => d.playerID))
      .range([0, 2 * Math.PI])
      .padding(0.003);

    const radiusScale = d3
      .scaleSqrt()
      .domain([minG * 0.95, maxG])
      .range([innerRadius, outerRadius]);

    const colorScale = d3
      .scaleSequential(d3.interpolateBlues)
      .domain([minG, maxG]);

    const mainGroup = svg
      .append("g")
      .attr("transform", `translate(${centerX},${centerY})`);

    const gridGroup = mainGroup.append("g").attr("class", "grid-group");

    const ticks = radiusScale.ticks(4).filter((t) => t >= minG);

    gridGroup
      .selectAll("circle")
      .data(ticks)
      .join("circle")
      .attr("r", (d) => radiusScale(d))
      .attr("fill", "none")
      .attr("stroke", "#ccc")
      .attr("stroke-dasharray", "2,2")
      .attr("stroke-width", 0.8);

    gridGroup
      .selectAll("text")
      .data(ticks)
      .join("text")
      .attr("y", 5)
      .attr("x", (d) => -radiusScale(d) - 8) // Left side
      .attr("text-anchor", "end")
      .attr("fill", "#666")
      .attr("font-size", "12px")
      .text((d) => `${Math.round(d)} G`);

    const arc = d3
      .arc()
      .innerRadius(innerRadius)
      .outerRadius(innerRadius) // Start tiny for animation
      .startAngle((d) => angleScale(d.playerID))
      .endAngle((d) => angleScale(d.playerID) + angleScale.bandwidth());

    const arcs = mainGroup
      .append("g")
      .selectAll("path")
      .data(chartData)
      .join("path")
      .attr("fill", (d) => colorScale(d.G))
      .attr("stroke", "#003135")
      .attr("stroke-width", 0.2)
      .attr("d", arc)
      .on("mousemove", (event, d) => {
        tooltip
          .style("left", event.pageX + 10 + "px")
          .style("top", event.pageY - 30 + "px")
          .style("opacity", 1).html(`
            <strong>${d.fullName}</strong><br>
            Games Played: ${d.G}
          `);
      })
      .on("mouseleave", () => tooltip.style("opacity", 0));

    arcs
      .transition()
      .delay((d, i) => i * 0.05)
      .duration(800)
      .attrTween("d", function (d) {
        const interpolateOuter = d3.interpolate(innerRadius, radiusScale(d.G));
        return function (t) {
          return d3
            .arc()
            .innerRadius(innerRadius)
            .outerRadius(interpolateOuter(t))
            .startAngle(angleScale(d.playerID))
            .endAngle(angleScale(d.playerID) + angleScale.bandwidth())();
        };
      });
  }

  // window resize
  window.addEventListener("resize", function () {
    if (originalData.length > 0) {
      const selected = document.getElementById("filterSelect").value;
      let data = originalData;

      if (selected === "top100") {
        data = originalData
          .slice()
          .sort((a, b) => d3.descending(a.G, b.G))
          .slice(0, 100);
      } else if (selected === "top50") {
        data = originalData
          .slice()
          .sort((a, b) => d3.descending(a.G, b.G))
          .slice(0, 50);
      }

      drawRadialChart(data);
    }
  });
</script>
