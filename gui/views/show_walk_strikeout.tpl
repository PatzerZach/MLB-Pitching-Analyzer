% rebase('base')

<div class="visualization-container">
  <div class="visualization-header">
    <h2 class="visualization-title">Strikeouts vs Walks Analysis</h2>
    <p class="visualization-description">
      This visualization explores the relationship between strikeouts and walks
      for MLB pitchers throughout history. The scatter plot reveals pitchers
      with who stand out for having an incredible strikeout to walk ratio.
      Identify pitchers with the best combination of accuracy and control.
    </p>
  </div>

  <div class="visualization-content">
    <div class="visualization-actions">
      <div class="viz-filters">
        <select id="filterSelect" class="viz-filter-select">
          <option value="all">All Pitchers</option>
          <option value="top100">Top 100 K/BB Ratio</option>
        </select>
      </div>
    </div>

    <div class="chart-container">
      <svg id="scatter-plot" width="100%" height="100%"></svg>
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

      return d3.json("/api/strikeout_walk_data");
    })
    .then((data) => {
      originalData = data.map((d) => ({
        ...d,
        ratio: d.BB === 0 ? d.SO : d.SO / d.BB,
        fullName: playerNameMap[d.playerID] || d.playerID,
      }));

      drawScatter(originalData);

      d3.select("#filterSelect").on("change", function () {
        const selected = this.value;
        if (selected === "all") {
          drawScatter(originalData);
        } else if (selected === "top100") {
          const filtered = originalData
            .slice()
            .sort((a, b) => d3.descending(a.ratio, b.ratio))
            .slice(0, 100);
          drawScatter(filtered);
        }
      });
    })
    .catch((error) => {
      console.error("Error loading strikeout/walk data:", error);
    });

  function drawScatter(data) {
    const chartContainer = document.querySelector(".chart-container");
    const containerWidth = chartContainer.clientWidth;
    const containerHeight = chartContainer.clientHeight;

    const svg = d3
      .select("#scatter-plot")
      .attr("width", containerWidth)
      .attr("height", containerHeight);

    const width = containerWidth;
    const height = containerHeight;
    const margin = { top: 40, right: 60, bottom: 70, left: 80 };

    const innerWidth = width - margin.left - margin.right;
    const innerHeight = height - margin.top - margin.bottom;

    svg.selectAll("*").remove();

    const x = d3
      .scaleLinear()
      .domain([0, d3.max(data, (d) => d.BB) * 1.1])
      .range([margin.left, width - margin.right]);

    const y = d3
      .scaleLinear()
      .domain([0, d3.max(data, (d) => d.SO) * 1.1])
      .range([height - margin.bottom, margin.top]);

    const color = d3
      .scaleSequential(d3.interpolateBlues)
      .domain([0, d3.max(data, (d) => d.SO)]);

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
      .text("Walks (BB)");

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
      .text("Strikeouts (SO)");

    // Add reference line
    const refLines = [
      { ratio: 2, color: "rgba(242, 100, 25, 0.5)", label: "2:1 K/BB" },
      { ratio: 3, color: "rgba(242, 100, 25, 0.8)", label: "3:1 K/BB" },
    ];

    refLines.forEach((line) => {
      if (line.ratio * d3.max(data, (d) => d.BB) <= d3.max(data, (d) => d.SO)) {
        // reference line
        svg
          .append("line")
          .attr("x1", margin.left)
          .attr("y1", y(margin.left * line.ratio))
          .attr(
            "x2",
            d3.max([
              x(d3.max(data, (d) => d.SO) / line.ratio),
              margin.left + 100,
            ])
          )
          .attr(
            "y2",
            y(d3.max([d3.max(data, (d) => d.SO), margin.left * line.ratio]))
          )
          .attr("stroke", line.color)
          .attr("stroke-width", 1.5)
          .attr("stroke-dasharray", "5,5");

        // label
        svg
          .append("text")
          .attr("x", margin.left + 80)
          .attr("y", y(margin.left * line.ratio * 1.1))
          .attr("fill", line.color.replace("0.5", "0.9").replace("0.8", "1"))
          .attr("font-size", "12px")
          .text(line.label);
      }
    });

    // Dots with animation
    svg
      .append("g")
      .selectAll("circle")
      .data(data)
      .join("circle")
      .attr("cx", (d) => x(d.BB))
      .attr("cy", (d) => y(d.SO))
      .attr("r", 0)
      .attr("fill", (d) => color(d.SO))
      .attr("stroke", "#003135")
      .attr("stroke-width", 0.3)
      .attr("opacity", 0)
      .on("mousemove", (event, d) => {
        tooltip
          .style("left", event.pageX + 10 + "px")
          .style("top", event.pageY - 30 + "px")
          .style("opacity", 1).html(`
            <strong>${d.fullName}</strong><br>
            Strikeouts: ${d.SO.toLocaleString()}<br>
            Walks: ${d.BB.toLocaleString()}<br>
            K/BB Ratio: ${d.ratio.toFixed(2)}
          `);
      })
      .on("mouseleave", () => tooltip.style("opacity", 0))
      .transition()
      .duration(200)
      .delay((d, i) => i * 1)
      .attr("r", 5)
      .attr("opacity", 0.8);
  }

  // window resize
  window.addEventListener("resize", function () {
    if (originalData.length > 0) {
      const selected = document.getElementById("filterSelect").value;
      let data = originalData;

      if (selected === "top100") {
        data = originalData
          .slice()
          .sort((a, b) => d3.descending(a.ratio, b.ratio))
          .slice(0, 100);
      }

      drawScatter(data);
    }
  });
</script>
