% rebase('base')

<div class="visualization-container">
  <div class="visualization-header">
    <h2 class="visualization-title">Innings Pitched Historical Trends</h2>
    <p class="visualization-description">
      This visualization tracks how innings a pitcher has pitched has evolved
      throughout baseball history through average innings pitched. The chart
      reveals significant shifts in pitcher usage patterns across different eras
      of the game. This shows how modern baseball has dramatically changed the
      way pitchers are utilized compared to earlier decades.
    </p>
  </div>

  <div class="visualization-content">
    <div class="chart-container">
      <svg id="innings-line" width="100%" height="100%"></svg>
    </div>
  </div>

  <div id="tooltip" class="tooltip"></div>
</div>

<script src="https://d3js.org/d3.v7.min.js"></script>

<script>
  document.addEventListener("DOMContentLoaded", function () {
    const chartContainer = document.querySelector(".chart-container");
    const containerWidth = chartContainer.clientWidth;
    const containerHeight = chartContainer.clientHeight;

    d3.json("/api/innings_trend").then((data) => {
      const svg = d3
        .select("#innings-line")
        .attr("width", containerWidth)
        .attr("height", containerHeight);

      const width = containerWidth;
      const height = containerHeight;
      const margin = { top: 50, right: 40, bottom: 50, left: 80 };

      svg.selectAll("*").remove();

      const x = d3
        .scaleLinear()
        .domain(d3.extent(data, (d) => d.year))
        .range([margin.left, width - margin.right]);

      const y = d3
        .scaleLinear()
        .domain([0, d3.max(data, (d) => d.innings) * 1.1])
        .range([height - margin.bottom, margin.top]);

      const line = d3
        .line()
        .x((d) => x(d.year))
        .y((d) => y(d.innings))
        .curve(d3.curveMonotoneX);

      // X axis
      svg
        .append("g")
        .attr("transform", `translate(0, ${height - margin.bottom})`)
        .call(d3.axisBottom(x).tickFormat(d3.format("d")))
        .append("text")
        .attr("x", width / 2)
        .attr("y", 40)
        .attr("fill", "#0FA4AF")
        .style("text-anchor", "middle")
        .style("font-size", "16px")
        .text("Year");

      // Y axis
      svg
        .append("g")
        .attr("transform", `translate(${margin.left}, 0)`)
        .call(d3.axisLeft(y))
        .append("text")
        .attr("x", -height / 2)
        .attr("y", -50)
        .attr("transform", "rotate(-90)")
        .attr("fill", "#0FA4AF")
        .style("text-anchor", "middle")
        .style("font-size", "16px")
        .text("Avg Innings Pitched per Pitcher");

      // gridlines
      svg
        .append("g")
        .attr("class", "grid")
        .attr("transform", `translate(0,${height - margin.bottom})`)
        .call(
          d3
            .axisBottom(x)
            .tickSize(-(height - margin.top - margin.bottom))
            .tickFormat("")
            .tickValues(d3.range(1880, 2020, 20))
        )
        .selectAll("line")
        .style("stroke", "#e0e0e0")
        .style("stroke-opacity", 0.7);

      // horizontal gridlines
      svg
        .append("g")
        .attr("class", "grid")
        .attr("transform", `translate(${margin.left},0)`)
        .call(
          d3
            .axisLeft(y)
            .tickSize(-(width - margin.left - margin.right))
            .tickFormat("")
        )
        .selectAll("line")
        .style("stroke", "#e0e0e0")
        .style("stroke-opacity", 0.7);

      // line path with animation
      const path = svg
        .append("path")
        .datum(data)
        .attr("class", "line")
        .attr("fill", "none")
        .attr("stroke", "#00AFB9")
        .attr("stroke-width", 3)
        .attr("d", line);

      // Animate the line
      const pathLength = path.node().getTotalLength();
      path
        .attr("stroke-dasharray", pathLength)
        .attr("stroke-dashoffset", pathLength)
        .transition()
        .duration(2000)
        .attr("stroke-dashoffset", 0);

      // area beneath the line
      const area = d3
        .area()
        .x((d) => x(d.year))
        .y0(height - margin.bottom)
        .y1((d) => y(d.innings))
        .curve(d3.curveMonotoneX);

      svg
        .append("path")
        .datum(data)
        .attr("fill", "url(#area-gradient)")
        .attr("d", area)
        .attr("opacity", 0)
        .transition()
        .delay(500)
        .duration(1000)
        .attr("opacity", 0.3);

      // gradient for the area
      const gradient = svg
        .append("defs")
        .append("linearGradient")
        .attr("id", "area-gradient")
        .attr("x1", "0%")
        .attr("y1", "0%")
        .attr("x2", "0%")
        .attr("y2", "100%");

      gradient
        .append("stop")
        .attr("offset", "0%")
        .attr("stop-color", "#00AFB9")
        .attr("stop-opacity", 0.8);

      gradient
        .append("stop")
        .attr("offset", "100%")
        .attr("stop-color", "#00AFB9")
        .attr("stop-opacity", 0.1);

      // Tooltip handling
      const tooltip = d3.select("#tooltip");

      // Create an overlay for better tooltip area
      const focus = svg.append("g").style("display", "none");

      // Add circle to show the point
      focus
        .append("circle")
        .attr("r", 5)
        .attr("fill", "#F26419")
        .attr("stroke", "#FFF")
        .attr("stroke-width", 2);

      // Create a rect for mouse tracking
      svg
        .append("rect")
        .attr("width", width - margin.left - margin.right)
        .attr("height", height - margin.top - margin.bottom)
        .style("fill", "none")
        .style("pointer-events", "all")
        .attr("transform", `translate(${margin.left},${margin.top})`)
        .on("mouseover", () => focus.style("display", null))
        .on("mouseout", () => {
          focus.style("display", "none");
          tooltip.style("opacity", 0);
        })
        .on("mousemove", mousemove);

      function mousemove(event) {
        const bisect = d3.bisector((d) => d.year).left;
        const xPos = d3.pointer(event)[0];
        const x0 = x.invert(xPos);
        const i = bisect(data, x0, 1);

        if (i >= data.length) return;

        const d0 = data[i - 1];
        const d1 = data[i];
        const d = x0 - d0.year > d1.year - x0 ? d1 : d0;

        focus.attr("transform", `translate(${x(d.year)},${y(d.innings)})`);

        tooltip
          .style("opacity", 1)
          .style("left", event.pageX + 10 + "px")
          .style("top", event.pageY - 30 + "px")
          .html(
            `<strong>${d.year}</strong><br>Average Innings: ${d.innings.toFixed(
              1
            )}`
          );
      }
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
