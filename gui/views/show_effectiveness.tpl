% rebase('base.tpl')

<div class="visualization-container">
  <div class="visualization-header">
    <h2 class="visualization-title">Pitching Effectiveness Over Time</h2>
    <p class="visualization-description">
      This visualization tracks how pitcher effectiveness has evolved throughout
      MLB history. To get the effectiveness score from each year, we normalize
      each of the following stats: ERA, strikeouts, walks, and hits by taking
      each value - min and then dividing it by the max - min. We then invert the
      ERA, walk, and hit stats by taking 1 - the normalized value, because lower
      ERA, walks, and hits contribute to better effectiveness scores.
    </p>
  </div>

  <div class="visualization-content">
    <div class="chart-container" id="effectiveness-chart-container">
      <svg id="effectiveness-chart" width="100%" height="100%"></svg>
    </div>
  </div>

  <div id="tooltip" class="tooltip">
    <div class="tooltip-title">Year: <span id="tooltip-year"></span></div>
    <div class="tooltip-value">
      <span class="tooltip-label">Effectiveness:</span>
      <span id="tooltip-effectiveness"></span>
    </div>
  </div>
</div>

<script src="https://d3js.org/d3.v7.min.js"></script>
<script>
  document.addEventListener("DOMContentLoaded", function () {
    const chartContainer = document.getElementById(
      "effectiveness-chart-container"
    );
    const containerWidth = chartContainer.clientWidth;
    const containerHeight = chartContainer.clientHeight;

    const svg = d3
      .select("#effectiveness-chart")
      .attr("width", containerWidth)
      .attr("height", containerHeight);
    const margin = { top: 40, right: 60, bottom: 60, left: 70 };
    const width = containerWidth - margin.left - margin.right;
    const height = containerHeight - margin.top - margin.bottom;

    const g = svg
      .append("g")
      .attr("transform", `translate(${margin.left},${margin.top})`);

    d3.json("/api/effectiveness").then((data) => {
      // Calculate effectiveness for each data point
      const stats = ["era", "so", "bb", "h"];
      const extents = {};
      stats.forEach((stat) => {
        extents[stat] = d3.extent(data, (d) => d[stat]);
      });

      data.forEach((d) => {
        d.norm_era =
          1 - (d.era - extents.era[0]) / (extents.era[1] - extents.era[0]);
        d.norm_so = (d.so - extents.so[0]) / (extents.so[1] - extents.so[0]);
        d.norm_bb =
          1 - (d.bb - extents.bb[0]) / (extents.bb[1] - extents.bb[0]);
        d.norm_h = 1 - (d.h - extents.h[0]) / (extents.h[1] - extents.h[0]);
        d.effectiveness =
          0.4 * d.norm_era + 0.3 * d.norm_so + 0.2 * d.norm_bb + 0.1 * d.norm_h;
      });

      // Set up scales
      const x = d3
        .scaleLinear()
        .domain(d3.extent(data, (d) => d.year))
        .range([0, width]);

      const y = d3.scaleLinear().domain([0, 1]).range([height, 0]);

      const line = d3
        .line()
        .x((d) => x(d.year))
        .y((d) => y(d.effectiveness))
        .curve(d3.curveMonotoneX);

      // X axis
      g.append("g")
        .attr("class", "axis axis--x")
        .attr("transform", `translate(0,${height})`)
        .call(d3.axisBottom(x).tickFormat(d3.format("d")))
        .selectAll("text")
        .style("font-size", "12px");

      // Y axis
      g.append("g")
        .attr("class", "axis axis--y")
        .call(d3.axisLeft(y))
        .selectAll("text")
        .style("font-size", "12px");

      // X axis label
      g.append("text")
        .attr("class", "axis-title")
        .attr("x", width / 2)
        .attr("y", height + 40)
        .attr("text-anchor", "middle")
        .style("font-size", "14px")
        .text("Year");

      // Y axis label
      g.append("text")
        .attr("class", "axis-title")
        .attr("transform", "rotate(-90)")
        .attr("y", -40)
        .attr("x", -height / 2)
        .attr("text-anchor", "middle")
        .style("font-size", "14px")
        .text("Effectiveness Score (0-1)");

      // Draw the path
      const path = g
        .append("path")
        .datum(data)
        .attr("fill", "none")
        .attr("stroke", "#00AFB9")
        .attr("stroke-width", 3)
        .attr("d", line);

      // Animate the path
      const pathLength = path.node().getTotalLength();
      path
        .attr("stroke-dasharray", pathLength)
        .attr("stroke-dashoffset", pathLength)
        .transition()
        .duration(2000)
        .attr("stroke-dashoffset", 0);

      // Add a gradient beneath the line
      const gradient = g
        .append("linearGradient")
        .attr("id", "area-gradient")
        .attr("gradientUnits", "userSpaceOnUse")
        .attr("x1", 0)
        .attr("y1", y(0))
        .attr("x2", 0)
        .attr("y2", y(1));

      gradient
        .append("stop")
        .attr("offset", "0%")
        .attr("stop-color", "#00AFB9")
        .attr("stop-opacity", 0.1);

      gradient
        .append("stop")
        .attr("offset", "100%")
        .attr("stop-color", "#00AFB9")
        .attr("stop-opacity", 0.4);

      // Add the area beneath the line
      const area = d3
        .area()
        .x((d) => x(d.year))
        .y0(height)
        .y1((d) => y(d.effectiveness))
        .curve(d3.curveMonotoneX);

      g.append("path")
        .datum(data)
        .attr("fill", "url(#area-gradient)")
        .attr("d", area)
        .style("opacity", 0)
        .transition()
        .duration(2000)
        .style("opacity", 1);

      // Add a circle for hover effects
      const focusCircle = g
        .append("circle")
        .attr("r", 8)
        .attr("fill", "#F26419")
        .attr("stroke", "#fff")
        .attr("stroke-width", 2)
        .style("opacity", 0);

      // Set up tooltip
      const tooltip = d3.select("#tooltip");

      // Add mouse event handler for the chart
      svg
        .append("rect")
        .attr("width", width)
        .attr("height", height)
        .attr("transform", `translate(${margin.left},${margin.top})`)
        .attr("fill", "none")
        .attr("pointer-events", "all")
        .on("mousemove", function (event) {
          const [mx, my] = d3.pointer(event);
          const bisect = d3.bisector((d) => d.year).left;
          const x0 = x.invert(mx);
          const i = bisect(data, x0, 1);

          if (i > 0 && i < data.length) {
            const d0 = data[i - 1];
            const d1 = data[i];
            const d = x0 - d0.year > d1.year - x0 ? d1 : d0;

            focusCircle
              .attr("cx", x(d.year))
              .attr("cy", y(d.effectiveness))
              .style("opacity", 1);

            const xPos = x(d.year) + margin.left;
            const yPos = y(d.effectiveness) + margin.top;

            document.getElementById("tooltip-year").textContent = d.year;
            document.getElementById("tooltip-effectiveness").textContent =
              d.effectiveness.toFixed(3);

            tooltip
              .style("left", event.pageX + 10 + "px")
              .style("top", event.pageY - 30 + "px")
              .style("opacity", 1);
          }
        })
        .on("mouseleave", function () {
          focusCircle.style("opacity", 0);
          tooltip.style("opacity", 0);
        });
    });

    // window resize
    window.addEventListener("resize", function () {
      const newWidth = chartContainer.clientWidth;
      const newHeight = chartContainer.clientHeight;

      svg.attr("width", newWidth).attr("height", newHeight);

      if (
        Math.abs(newWidth - containerWidth) > 50 ||
        Math.abs(newHeight - containerHeight) > 50
      ) {
        location.reload();
      }
    });
  });
</script>
