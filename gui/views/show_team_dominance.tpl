% rebase('base')

<div class="visualization-container">
  <div class="visualization-header">
    <h2 class="visualization-title">Team Pitching Dominance Analysis</h2>
    <p class="visualization-description">
      This visualization compares pitching dominance across MLB teams throughout
      MLB history. An effectiveness score was created for each team, the same
      way it was done for the pitching effectiveness visualization. The larger
      and more green a bubble is, the better that team has performed.
    </p>
  </div>

  <div class="visualization-content">
    <div class="chart-container">
      <svg id="team-dominance-chart" width="100%" height="100%"></svg>
    </div>
  </div>

  <div id="tooltip" class="tooltip"></div>
</div>

<style>
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

    d3.json("/api/team_dominance").then((data) => {
      // Team name mapping
      const teamNameMap = {
        ALT: "Altoona Mountain Citys",
        ANA: "Anaheim Angels",
        ARI: "Arizona Diamondbacks",
        ATL: "Atlanta Braves",
        BAL: "Baltimore Orioles",
        BFN: "Buffalo Bisons (NL)",
        BFP: "Buffalo Bisons (PL)",
        BL1: "Baltimore Marylands",
        BL2: "Baltimore Orioles (AA)",
        BL3: "Baltimore Orioles (AA)",
        BL4: "Baltimore Canaries",
        BLA: "Baltimore Orioles (AL)",
        BLF: "Baltimore Terrapins",
        BLN: "Baltimore Orioles (NL)",
        BLU: "Baltimore Monumentals",
        BOS: "Boston Red Sox",
        BR1: "Brooklyn Atlantics",
        BR2: "Brooklyn Eckfords",
        BR3: "Brooklyn Bridegrooms",
        BR4: "Brooklyn Ward's Wonders",
        BRF: "Brooklyn Tip-Tops",
        BRP: "Brooklyn Gladiators",
        BRO: "Brooklyn Dodgers",
        BS1: "Boston Red Stockings",
        BS2: "Boston Reds (AA)",
        BSN: "Boston Braves",
        BSP: "Boston Reds (PL)",
        BSU: "Boston Reds (UA)",
        BUF: "Buffalo Blues",
        CAL: "California Angels",
        CH1: "Chicago White Stockings",
        CH2: "Chicago White Stockings",
        CHA: "Chicago White Sox",
        CHF: "Chicago Whales",
        CHN: "Chicago Cubs",
        CHP: "Chicago Pirates",
        CHU: "Chicago Browns",
        CIN: "Cincinnati Reds",
        CL1: "Cleveland Forest Citys",
        CL2: "Cleveland Blues (NL)",
        CL3: "Cleveland Spiders",
        CL4: "Cleveland Spiders",
        CL5: "Cleveland Blues (UA)",
        CL6: "Cleveland Spiders",
        CLE: "Cleveland Indians",
        CLP: "Cleveland Infants",
        CN1: "Cincinnati Reds (NL)",
        CN2: "Cincinnati Reds (AA)",
        CN3: "Cincinnati Kelly's Killers",
        CNU: "Cincinnati Outlaw Reds",
        COL: "Colorado Rockies",
        DET: "Detroit Tigers",
        DTN: "Detroit Wolverines",
        ELI: "Elizabeth Resolutes",
        FLO: "Florida Marlins",
        FW1: "Fort Wayne Kekiongas",
        HAR: "Hartford Dark Blues",
        HOU: "Houston Astros",
        HR1: "Hartford Dark Blues",
        IN1: "Indianapolis Blues",
        IN2: "Indianapolis Hoosiers (AA)",
        IN3: "Indianapolis Hoosiers (NL)",
        IND: "Indianapolis Hoosiers (FL)",
        KC1: "Kansas City Athletics",
        KC2: "Kansas City Cowboys (AA)",
        KCA: "Kansas City Royals",
        KCF: "Kansas City Packers",
        KCN: "Kansas City Cowboys (NL)",
        KCU: "Kansas City Cowboys (UA)",
        KEO: "Keokuk Westerns",
        LAA: "Los Angeles Angels",
        LAN: "Los Angeles Dodgers",
        LS1: "Louisville Grays",
        LS2: "Louisville Colonels (AA)",
        LS3: "Louisville Colonels (NL)",
        MIA: "Miami Marlins",
        MID: "Middletown Mansfields",
        MIL: "Milwaukee Brewers",
        MIN: "Minnesota Twins",
        ML1: "Milwaukee Braves",
        ML2: "Milwaukee Grays",
        ML3: "Milwaukee Brewers (AA)",
        ML4: "Milwaukee Brewers",
        MLA: "Milwaukee Brewers (AL)",
        MLU: "Milwaukee Brewers (UA)",
        MON: "Montreal Expos",
        NEW: "Newark Peppers",
        NH1: "New Haven Elm Citys",
        NY1: "New York Giants",
        NY2: "New York Mutuals",
        NY3: "New York Mutuals",
        NY4: "New York Metropolitans",
        NYA: "New York Yankees",
        NYN: "New York Mets",
        NYP: "New York Giants (PL)",
        OAK: "Oakland Athletics",
        PH1: "Philadelphia Athletics",
        PH2: "Philadelphia Centennials",
        PH3: "Philadelphia White Stockings",
        PH4: "Philadelphia Athletics (AA)",
        PHA: "Philadelphia Athletics (AL)",
        PHI: "Philadelphia Phillies",
        PHN: "Philadelphia Athletics (NL)",
        PHP: "Philadelphia Quakers",
        PHU: "Philadelphia Keystones",
        PIT: "Pittsburgh Pirates",
        PRO: "Providence Grays",
        PT1: "Pittsburgh Alleghenys",
        PTF: "Pittsburgh Rebels",
        PTP: "Pittsburgh Burghers",
        RC1: "Rockford Forest Citys",
        RC2: "Rochester Broncos",
        RIC: "Richmond Virginians",
        SDN: "San Diego Padres",
        SE1: "Seattle Pilots",
        SEA: "Seattle Mariners",
        SFN: "San Francisco Giants",
        SL1: "St. Louis Brown Stockings",
        SL2: "St. Louis Red Stockings",
        SL3: "St. Louis Brown Stockings",
        SL4: "St. Louis Browns (AA)",
        SL5: "St. Louis Maroons",
        SLA: "St. Louis Browns (AL)",
        SLF: "St. Louis Terriers",
        SLN: "St. Louis Cardinals",
        SLU: "St. Louis Maroons (UA)",
        SPU: "St. Paul White Caps",
        SR1: "Syracuse Stars",
        SR2: "Syracuse Stars",
        TBA: "Tampa Bay Rays",
        TEX: "Texas Rangers",
        TL1: "Toledo Blue Stockings",
        TL2: "Toledo Maumees",
        TOR: "Toronto Blue Jays",
        TRN: "Troy Trojans",
        TRO: "Troy Haymakers",
        WAS: "Washington Nationals",
        WIL: "Wilmington Quicksteps",
        WOR: "Worcester Ruby Legs",
        WS1: "Washington Senators",
        WS2: "Washington Senators",
        WS3: "Washington Olympics",
        WS4: "Washington Nationals",
        WS5: "Washington Blue Legs",
        WS6: "Washington Nationals",
        WS7: "Washington Nationals (UA)",
        WS8: "Washington Nationals (NL)",
        WS9: "Washington Statesmen",
        WSU: "Washington Nationals (UA)",
      };

      // Normalize the data
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

      const svg = d3
        .select("#team-dominance-chart")
        .attr("width", containerWidth)
        .attr("height", containerHeight);

      const tooltip = d3.select("#tooltip");

      svg.selectAll("*").remove();

      const simulation = d3
        .forceSimulation(data)
        .force(
          "center",
          d3.forceCenter(containerWidth / 2, containerHeight / 2)
        )
        .force("charge", d3.forceManyBody().strength(0))
        .force(
          "collision",
          d3.forceCollide().radius((d) => d.effectiveness * 30 + 3)
        )
        .force("x", d3.forceX(containerWidth / 2).strength(0.05))
        .force("y", d3.forceY(containerHeight / 2).strength(0.05))
        .on("tick", ticked);

      const node = svg
        .selectAll("circle")
        .data(data)
        .enter()
        .append("circle")
        .attr("r", (d) => d.effectiveness * 20 + 2)
        .attr("fill", (d) => d3.interpolateRdYlGn(d.effectiveness))
        .attr("stroke", "#003135")
        .attr("stroke-width", 1.5)
        .attr("opacity", 0)
        .on("mousemove", (event, d) => {
          const [x, y] = d3.pointer(event);
          const teamName = teamNameMap[d.team] || d.team;

          tooltip
            .style(
              "left",
              (x > containerWidth / 2 ? event.pageX - 160 : event.pageX + 20) +
                "px"
            )
            .style("top", event.pageY - 30 + "px")
            .style("opacity", 1).html(`
            <strong>${teamName}</strong><br>
            Effectiveness: ${d.effectiveness.toFixed(3)}<br>
            ERA: ${d.era.toFixed(2)}<br>
            Strikeouts: ${d.so.toLocaleString()}<br>
            Walks: ${d.bb.toLocaleString()}
          `);
        })
        .on("mouseleave", () => tooltip.style("opacity", 0));

      // Animate bubbles
      node
        .transition()
        .duration(1000)
        .delay((d, i) => i * 5)
        .attr("opacity", 0.8);

      // legend
      const legend = svg
        .append("g")
        .attr("transform", `translate(${containerWidth - 180}, 30)`);

      legend
        .append("text")
        .attr("x", 0)
        .attr("y", 0)
        .text("Effectiveness")
        .attr("font-size", "14px")
        .attr("font-weight", "bold");

      const legendScale = d3.scaleLinear().domain([0, 1]).range([0, 100]);

      const colorLegend = legend
        .append("g")
        .attr("transform", "translate(0, 20)");

      colorLegend
        .selectAll("rect")
        .data(d3.range(0, 1.01, 0.1))
        .enter()
        .append("rect")
        .attr("x", 0)
        .attr("y", (d) => legendScale(d))
        .attr("width", 20)
        .attr("height", 10)
        .attr("fill", (d) => d3.interpolateRdYlGn(d));

      colorLegend
        .append("text")
        .attr("x", 25)
        .attr("y", 0)
        .text("Low")
        .attr("font-size", "12px");

      colorLegend
        .append("text")
        .attr("x", 25)
        .attr("y", 100)
        .text("High")
        .attr("font-size", "12px");

      function ticked() {
        node.attr("cx", (d) => d.x).attr("cy", (d) => d.y);
      }
    });
  });

  // window resize
  window.addEventListener("resize", function () {
    const chart = document.getElementById("team-dominance-chart");
    if (chart) {
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
