% rebase('base')

<div class="visualization-container">
  <div class="visualization-header">
    <h2 class="visualization-title">Most Batters Faced by MLB Pitchers</h2>
    <p class="visualization-description">
      This visualization ranks the top 50 MLB pitchers based on the total number
      of batters they've faced during their careers. It highlights the elite
      workhorses of baseball history who have demonstrated exceptional longevity
      and durability on the mound. The height of each bar directly correlates to
      the number of batters faced.
    </p>
  </div>

  <div class="visualization-content">
    <div class="chart-container">
      <svg id="bfp-bar-chart" width="100%" height="100%"></svg>
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

    d3.json("/api/batters_faced").then((data) => {
      const top50 = data.slice(0, 50);

      const svg = d3
        .select("#bfp-bar-chart")
        .attr("width", containerWidth)
        .attr("height", containerHeight);

      const width = containerWidth;
      const height = containerHeight;
      const margin = { top: 60, right: 30, bottom: 150, left: 80 };

      const innerWidth = width - margin.left - margin.right;
      const innerHeight = height - margin.top - margin.bottom;

      const x = d3
        .scaleBand()
        .domain(top50.map((d) => d.fullName))
        .range([margin.left, width - margin.right])
        .padding(0.2);

      const y = d3
        .scaleLinear()
        .domain([0, d3.max(top50, (d) => d.BFP)])
        .range([height - margin.bottom, margin.top]);

      const color = d3
        .scaleSequential(d3.interpolateBlues)
        .domain([0, d3.max(top50, (d) => d.BFP)]);

      const tooltip = d3.select("#tooltip");

      // X axis
      svg
        .append("g")
        .attr("transform", `translate(0, ${height - margin.bottom})`)
        .call(d3.axisBottom(x))
        .selectAll("text")
        .attr("transform", "rotate(-60)")
        .style("text-anchor", "end")
        .style("font-size", "11px");

      // Y axis
      svg
        .append("g")
        .attr("transform", `translate(${margin.left}, 0)`)
        .call(d3.axisLeft(y).ticks(10))
        .selectAll("text")
        .style("font-size", "13px");

      // Y axis label
      svg
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", margin.left / 3)
        .attr("x", -(height / 2))
        .attr("text-anchor", "middle")
        .style("font-size", "14px")
        .attr("fill", "#0FA4AF")
        .text("Batters Faced");

      // bars with animation
      svg
        .selectAll("rect")
        .data(top50)
        .enter()
        .append("rect")
        .attr("x", (d) => x(d.fullName))
        .attr("y", height - margin.bottom)
        .attr("width", x.bandwidth())
        .attr("height", 0)
        .attr("fill", (d) => color(d.BFP))
        .on("mousemove", (event, d) => {
          tooltip
            .style("left", event.pageX + 10 + "px")
            .style("top", event.pageY - 30 + "px")
            .style("opacity", 1)
            .html(
              `<strong>${
                d.fullName
              }</strong><br>Batters Faced: ${d.BFP.toLocaleString()}`
            );
        })
        .on("mouseleave", () => tooltip.style("opacity", 0))
        .transition()
        .duration(1000)
        .delay((d, i) => i * 20)
        .attr("y", (d) => y(d.BFP))
        .attr("height", (d) => height - margin.bottom - y(d.BFP));
    });
  });

  // window resize
  window.addEventListener("resize", function () {
    if (!window.lastResize || Date.now() - window.lastResize > 500) {
      window.lastResize = Date.now();

      const chartContainer = document.querySelector(".chart-container");
      if (chartContainer) {
        const svg = d3.select("#bfp-bar-chart");
        svg.selectAll("*").remove();
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
    }
  });
</script>
