% rebase('base')

<div class="visualization-container">
  <div class="visualization-header">
    <h2 class="visualization-title">MLB Pitchers in the Hall of Fame</h2>
    <p class="visualization-description">
      This visualization analyzes the distribution of MLB pitchers who have been
      inducted into the Baseball Hall of Fame in Cooperstown, NY. This also
      shows the proportion of pitchers who have achieved baseball's highest
      honor and view the complete list of Hall of Fame pitchers throughout
      history.
    </p>
  </div>

  <div class="visualization-content">
    <div class="chart-container">
      <div class="hof-flex-container">
        <div class="hof-stats-container" id="hof-counts"></div>

        <div class="hof-chart-wrapper">
          <svg id="hof-chart"></svg>
        </div>

        <div class="hof-pitchers-list" id="hof-pitchers-list"></div>
      </div>
    </div>
  </div>

  <div id="tooltip" class="tooltip"></div>
</div>

<style>
  .hof-flex-container {
    display: flex;
    flex-direction: column;
    width: 100%;
    padding: 20px;
    padding-bottom: 30px;
  }

  .hof-stats-container {
    color: var(--light);
    font-size: 1.2rem;
    margin-bottom: 20px;
    padding: 15px;
    background-color: var(--primary);
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }

  .hof-chart-wrapper {
    width: 100%;
    height: 350px;
    margin-bottom: 30px;
  }

  #hof-chart {
    width: 100%;
    height: 100%;
  }

  .hof-pitchers-list {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    padding: 20px;
    background-color: var(--primary);
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    max-height: 400px;
    overflow-y: auto;
  }

  .hof-pitcher {
    width: 25%;
    padding: 5px 10px;
    text-align: left;
    box-sizing: border-box;
  }

  .hof-pitcher a {
    color: var(--light);
    text-decoration: none;
    transition: color 0.2s;
    display: block;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .hof-pitcher a:hover {
    color: var(--accent);
    text-decoration: underline;
  }

  @media (max-width: 768px) {
    .hof-pitcher {
      width: 50%;
    }
  }

  .visualization-container {
    height: auto;
    min-height: 100vh;
    padding-bottom: 20px;
  }
</style>

<script src="https://d3js.org/d3.v7.min.js"></script>

<script>
  document.addEventListener("DOMContentLoaded", function () {
    d3.json("/api/pitcher_hof_stats").then((data) => {
      data.hof = 94;
      data.non_hof = 9033;
      const totalPitchers = 9127;
      const hofPercentage = ((data.hof / totalPitchers) * 100).toFixed(2);

      const dataset = [
        { label: "Hall of Fame Pitchers", value: data.hof },
        { label: "Non-HoF Pitchers", value: data.non_hof },
      ];

      d3.select("#hof-counts").html(`
        <strong>MLB Pitchers in the Hall of Fame</strong><br>
        Total Unique Pitchers: <strong>${totalPitchers.toLocaleString()}</strong><br>
        In Hall of Fame: <strong>${data.hof.toLocaleString()} (${hofPercentage}%)</strong><br>
        Not in Hall of Fame: <strong>${data.non_hof.toLocaleString()}</strong>
      `);

      const chartContainer = document.querySelector(".hof-chart-wrapper");
      const containerWidth = chartContainer.clientWidth;
      const containerHeight = chartContainer.clientHeight;

      const svg = d3
        .select("#hof-chart")
        .attr("width", containerWidth)
        .attr("height", containerHeight);

      svg.selectAll("*").remove();

      // margins to prevent overlap
      const margin = { top: 20, right: 30, bottom: 50, left: 80 };
      const width = containerWidth;
      const height = containerHeight;
      const innerWidth = width - margin.left - margin.right;
      const innerHeight = height - margin.top - margin.bottom;

      const x = d3
        .scaleBand()
        .domain(dataset.map((d) => d.label))
        .range([margin.left, width - margin.right])
        .padding(0.4);

      const y = d3
        .scaleLinear()
        .domain([0, d3.max(dataset, (d) => d.value)])
        .nice()
        .range([height - margin.bottom, margin.top]);

      // X axis
      svg
        .append("g")
        .attr("transform", `translate(0,${height - margin.bottom})`)
        .call(d3.axisBottom(x))
        .selectAll("text")
        .style("font-size", "14px")
        .style("font-weight", "bold");

      // Y axis
      svg
        .append("g")
        .attr("transform", `translate(${margin.left},0)`)
        .call(d3.axisLeft(y).tickFormat(d3.format(",d")))
        .selectAll("text")
        .style("font-size", "14px");

      // Y axis label
      svg
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", margin.left / 4)
        .attr("x", -(height / 2))
        .attr("text-anchor", "middle")
        .style("font-size", "14px")
        .attr("fill", "#0FA4AF")
        .text("Number of Pitchers");

      // bars with animation
      svg
        .selectAll(".bar")
        .data(dataset)
        .enter()
        .append("rect")
        .attr("class", "bar")
        .attr("x", (d) => x(d.label))
        .attr("y", height - margin.bottom)
        .attr("width", x.bandwidth())
        .attr("height", 0)
        .attr("fill", (d) => (d.label.includes("Non") ? "#964734" : "#0FA4AF"))
        .transition()
        .duration(1000)
        .attr("y", (d) => y(d.value))
        .attr("height", (d) => y(0) - y(d.value));

      // value labels
      svg
        .selectAll(".bar-label")
        .data(dataset)
        .enter()
        .append("text")
        .attr("class", "bar-label")
        .attr("x", (d) => x(d.label) + x.bandwidth() / 2)
        .attr("y", (d) => y(d.value) - 10)
        .attr("text-anchor", "middle")
        .attr("fill", "#003135")
        .style("font-weight", "bold")
        .style("font-size", "14px")
        .style("opacity", 0)
        .text((d) => d3.format(",")(d.value))
        .transition()
        .delay(800)
        .duration(400)
        .style("opacity", 1);

      // percentage label
      svg
        .append("text")
        .attr("x", x(dataset[0].label) + x.bandwidth() / 2)
        .attr("y", y(dataset[0].value) - 30)
        .attr("text-anchor", "middle")
        .attr("fill", "#0FA4AF")
        .style("font-weight", "bold")
        .style("font-size", "14px")
        .style("opacity", 0)
        .text(`${hofPercentage}%`)
        .transition()
        .delay(1200)
        .duration(400)
        .style("opacity", 1);
    });

    // Load Hall of Fame pitchers list
    d3.json("/api/hof_pitchers_list").then((pitchers) => {
      const listContainer = d3.select("#hof-pitchers-list");
      listContainer.html("");

      listContainer
        .append("h3")
        .style("margin-bottom", "15px")
        .style("color", "var(--light)")
        .text("Hall of Fame Pitchers");

      const pitchersContainer = listContainer
        .append("div")
        .style("display", "flex")
        .style("flex-wrap", "wrap")
        .style("width", "100%");

      pitchers.sort((a, b) => a.fullName.localeCompare(b.fullName));

      pitchers.forEach((d) => {
        pitchersContainer.append("div").attr("class", "hof-pitcher").html(`
          <a href="https://www.baseball-reference.com/players/${d.playerID[0]}/${d.playerID}.shtml" 
             target="_blank" title="${d.fullName}">
             ${d.fullName}
          </a>
        `);
      });
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
