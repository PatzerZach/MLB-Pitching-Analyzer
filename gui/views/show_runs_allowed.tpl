% rebase('base')

<div class="visualization-container">
  <div class="visualization-header">
    <h2 class="visualization-title">Runs Allowed Geographic Distribution</h2>
    <p class="visualization-description">
      This visualization maps the geographic distribution of runs allowed by MLB
      teams throughout history. The height of each spike represents the total
      runs allowed by teams in that location. This shows patterns across
      different cities and regions to see which locations have produced the most
      effective pitching staffs.
    </p>
  </div>

  <div class="visualization-content">
    <div class="chart-container">
      <div class="map-flex-wrapper">
        <svg
          id="spike-map"
          width="100%"
          height="100%"
          viewBox="0 0 1300 800"
        ></svg>

        <div id="legend-container">
          <h3>Top 5 Teams (Runs Allowed)</h3>
          <ul id="legend-list"></ul>
        </div>
      </div>
    </div>
  </div>

  <div id="tooltip" class="tooltip"></div>
</div>

<style>
  .map-flex-wrapper {
    display: flex;
    align-items: start;
    width: 100%;
    height: 100%;
    padding-bottom: 20px;
  }

  #legend-container {
    padding: 20px;
    background-color: rgba(255, 255, 255, 0.9);
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    margin-left: 20px;
    min-width: 250px;
  }

  #legend-container h3 {
    color: var(--secondary);
    font-size: 1.3rem;
    margin-bottom: 15px;
  }

  #legend-list {
    list-style: none;
    padding-left: 0;
    font-size: 1.1rem;
    line-height: 1.8;
  }

  .state {
    transition: fill 0.2s;
  }

  .state:hover {
    fill: #bbb;
  }

  .visualization-container {
    height: auto;
    min-height: 100vh;
    padding-bottom: 20px;
  }

  .chart-container {
    height: calc(100vh - 250px);
    min-height: 600px;
  }
</style>

<script src="https://d3js.org/d3.v7.min.js"></script>
<script src="https://d3js.org/topojson.v3.min.js"></script>

<script>
  Promise.all([
    d3.json("/api/runs_allowed_spike_data"),
    d3.json("https://cdn.jsdelivr.net/npm/us-atlas@3/states-10m.json"),
  ])
    .then(([teamData, usMap]) => {
      const chartContainer = document.querySelector(".chart-container");
      const containerWidth = chartContainer.clientWidth;
      const containerHeight = chartContainer.clientHeight;

      const svg = d3
        .select("#spike-map")
        .attr("width", containerWidth)
        .attr("height", containerHeight);

      const width = containerWidth;
      const height = containerHeight;

      function spike(length, width = 7) {
        return `M${-width / 2},0L0,${-length}L${width / 2},0Z`;
      }

      const states = topojson.feature(usMap, usMap.objects.states);
      const nation = topojson.feature(usMap, usMap.objects.nation);

      const projection = d3
        .geoAlbersUsa()
        .fitSize([width * 0.6, height * 0.8], states);

      const path = d3.geoPath().projection(projection);

      svg.selectAll("*").remove();

      const mapGroup = svg.append("g");

      // nation outline
      mapGroup
        .append("path")
        .datum(nation)
        .attr("fill", "none")
        .attr("stroke", "#000")
        .attr("stroke-width", 1)
        .attr("d", path);

      // states
      mapGroup
        .selectAll(".state")
        .data(states.features)
        .enter()
        .append("path")
        .attr("class", "state")
        .attr("fill", "#d3d3d3")
        .attr("stroke", "#ffffff")
        .attr("stroke-width", 0.5)
        .attr("d", path);

      const maxRuns = d3.max(teamData, (d) => d.totalRunsAllowed);

      const heightScale = d3.scaleSqrt().domain([0, maxRuns]).range([0, 120]);

      const colorScale = d3
        .scaleSequential(d3.interpolateBlues)
        .domain([0, maxRuns]);

      const groupedByCity = d3.group(teamData, (d) => d.cityState);

      const tooltip = d3.select("#tooltip");

      const spikeGroup = svg.append("g");

      groupedByCity.forEach((teams, cityState) => {
        const baseCoords = projection([teams[0].lon, teams[0].lat]);
        if (!baseCoords) return;

        teams.forEach((team, index) => {
          const angle = (index / teams.length) * 2 * Math.PI;
          const radius = 10;
          const x = baseCoords[0] + radius * Math.cos(angle);
          const y = baseCoords[1] + radius * Math.sin(angle);

          const spikePath = spike(1);

          const spikeElement = spikeGroup
            .append("path")
            .attr("transform", `translate(${x},${y})`)
            .attr("fill", colorScale(team.totalRunsAllowed))
            .attr("stroke", "#003135")
            .attr("stroke-width", 0.5)
            .attr("d", spikePath)
            .on("mousemove", (event) => {
              tooltip
                .style("left", event.pageX + 10 + "px")
                .style("top", event.pageY - 30 + "px")
                .style("opacity", 1).html(`
              <strong>${team.teamName}</strong><br>
              ${team.cityState}<br>
              Runs Allowed: ${team.totalRunsAllowed}
            `);
            })
            .on("mouseleave", () => tooltip.style("opacity", 0));

          // Animate the spikes
          spikeElement
            .transition()
            .duration(2000)
            .delay(index * 50)
            .attr("d", spike(heightScale(team.totalRunsAllowed)));
        });
      });

      const top5Teams = teamData
        .slice()
        .sort((a, b) => d3.descending(a.totalRunsAllowed, b.totalRunsAllowed))
        .slice(0, 5);

      const legendList = d3.select("#legend-list");

      top5Teams.forEach((team, index) => {
        legendList
          .append("li")
          .html(
            `<span style="color:${colorScale(
              team.totalRunsAllowed
            )}">■</span> ${index + 1}. ${team.teamName} - ${
              team.totalRunsAllowed
            }`
          );
      });
    })
    .catch((error) => {
      console.error("Error loading map or data:", error);
    });

  // window resize
  window.addEventListener("resize", function () {
    if (
      window.innerWidth !== window.lastWidth ||
      window.innerHeight !== window.lastHeight
    ) {
      window.lastWidth = window.innerWidth;
      window.lastHeight = window.innerHeight;

      if (
        Math.abs(window.innerWidth - window.lastReloadWidth) > 100 ||
        Math.abs(window.innerHeight - window.lastReloadHeight) > 100
      ) {
        window.lastReloadWidth = window.innerWidth;
        window.lastReloadHeight = window.innerHeight;
        location.reload();
      }
    }
  });
</script>
