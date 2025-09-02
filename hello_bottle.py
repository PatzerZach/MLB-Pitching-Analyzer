from psycopg import connect
from bottle import Bottle, template, static_file, request, SimpleTemplate, TEMPLATE_PATH
import json
import csv
import sqlite3
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "data", "MLB_Pitching_Data.db")

app = Bottle()

# This allows request to be used in all templates without having to use it specifically
SimpleTemplate.defaults['request'] = request

@app.route('/static/<filepath:path>')
def serve_static(filepath):
    return static_file(filepath, root='./static')

@app.route('/')
def home():
    return template('show_home')

@app.route('/home')
def return_home():
    return template('show_home')

# Connect to db function
def connect_db():
    conn = sqlite3.connect(r"data\MLB_Pitching_Data.db")
    conn.row_factory = sqlite3.Row
    return conn

# This function loads the file that contains the playerID to full name mapping for each pitcher
def load_playerid_fullname_mapping():
    mapping = {}
    with open('static/playeridmap.csv', newline='', encoding='utf-8') as csvfile:
        reader = csv.reader(csvfile)
        next(reader)  # Skip header
        for row in reader:
            if len(row) >= 2:
                nameID = row[0].strip()
                fullName = row[1].strip()
                mapping[nameID] = fullName
    return mapping


@app.route('/teams')
def teams_list():
    teams = [
        {"id": "ALT", "name": "Altoona Mountain Citys", "logo": "/static/logos/placeholder.png"},
        {"id": "ANA", "name": "Anaheim Angels", "logo": "/static/logos/placeholder.png"},
        {"id": "ARI", "name": "Arizona Diamondbacks", "logo": "/static/logos/placeholder.png"},
        {"id": "ATL", "name": "Atlanta Braves", "logo": "/static/logos/placeholder.png"},
        {"id": "BAL", "name": "Baltimore Orioles", "logo": "/static/logos/placeholder.png"},
        {"id": "BFN", "name": "Buffalo Bisons (NL)", "logo": "/static/logos/placeholder.png"},
        {"id": "BFP", "name": "Buffalo Bisons (PL)", "logo": "/static/logos/placeholder.png"},
        {"id": "BL1", "name": "Baltimore Marylands", "logo": "/static/logos/placeholder.png"},
        {"id": "BL2", "name": "Baltimore Orioles (AA)", "logo": "/static/logos/placeholder.png"},
        {"id": "BL3", "name": "Baltimore Orioles (AA)", "logo": "/static/logos/placeholder.png"},
        {"id": "BL4", "name": "Baltimore Canaries", "logo": "/static/logos/placeholder.png"},
        {"id": "BLA", "name": "Baltimore Orioles (AL)", "logo": "/static/logos/placeholder.png"},
        {"id": "BLF", "name": "Baltimore Terrapins", "logo": "/static/logos/placeholder.png"},
        {"id": "BLN", "name": "Baltimore Orioles (NL)", "logo": "/static/logos/placeholder.png"},
        {"id": "BLU", "name": "Baltimore Monumentals", "logo": "/static/logos/placeholder.png"},
        {"id": "BOS", "name": "Boston Red Sox", "logo": "/static/logos/placeholder.png"},
        {"id": "BR1", "name": "Brooklyn Atlantics", "logo": "/static/logos/placeholder.png"},
        {"id": "BR2", "name": "Brooklyn Eckfords", "logo": "/static/logos/placeholder.png"},
        {"id": "BR3", "name": "Brooklyn Bridegrooms", "logo": "/static/logos/placeholder.png"},
        {"id": "BR4", "name": "Brooklyn Ward's Wonders", "logo": "/static/logos/placeholder.png"},
        {"id": "BRF", "name": "Brooklyn Tip-Tops", "logo": "/static/logos/placeholder.png"},
        {"id": "BRP", "name": "Brooklyn Gladiators", "logo": "/static/logos/placeholder.png"},
        {"id": "BRO", "name": "Brooklyn Dodgers", "logo": "/static/logos/placeholder.png"},
        {"id": "BS1", "name": "Boston Red Stockings", "logo": "/static/logos/placeholder.png"},
        {"id": "BS2", "name": "Boston Reds (AA)", "logo": "/static/logos/placeholder.png"},
        {"id": "BSN", "name": "Boston Braves", "logo": "/static/logos/placeholder.png"},
        {"id": "BSP", "name": "Boston Reds (PL)", "logo": "/static/logos/placeholder.png"},
        {"id": "BSU", "name": "Boston Reds (UA)", "logo": "/static/logos/placeholder.png"},
        {"id": "BUF", "name": "Buffalo Blues", "logo": "/static/logos/placeholder.png"},
        {"id": "CAL", "name": "California Angels", "logo": "/static/logos/placeholder.png"},
        {"id": "CH1", "name": "Chicago White Stockings", "logo": "/static/logos/placeholder.png"},
        {"id": "CH2", "name": "Chicago White Stockings", "logo": "/static/logos/placeholder.png"},
        {"id": "CHA", "name": "Chicago White Sox", "logo": "/static/logos/placeholder.png"},
        {"id": "CHF", "name": "Chicago Whales", "logo": "/static/logos/placeholder.png"},
        {"id": "CHN", "name": "Chicago Cubs", "logo": "/static/logos/placeholder.png"},
        {"id": "CHP", "name": "Chicago Pirates", "logo": "/static/logos/placeholder.png"},
        {"id": "CHU", "name": "Chicago Browns", "logo": "/static/logos/placeholder.png"},
        {"id": "CIN", "name": "Cincinnati Reds", "logo": "/static/logos/placeholder.png"},
        {"id": "CL1", "name": "Cleveland Forest Citys", "logo": "/static/logos/placeholder.png"},
        {"id": "CL2", "name": "Cleveland Blues (NL)", "logo": "/static/logos/placeholder.png"},
        {"id": "CL3", "name": "Cleveland Spiders", "logo": "/static/logos/placeholder.png"},
        {"id": "CL4", "name": "Cleveland Spiders", "logo": "/static/logos/placeholder.png"},
        {"id": "CL5", "name": "Cleveland Blues (UA)", "logo": "/static/logos/placeholder.png"},
        {"id": "CL6", "name": "Cleveland Spiders", "logo": "/static/logos/placeholder.png"},
        {"id": "CLE", "name": "Cleveland Indians", "logo": "/static/logos/placeholder.png"},
        {"id": "CLP", "name": "Cleveland Infants", "logo": "/static/logos/placeholder.png"},
        {"id": "CN1", "name": "Cincinnati Reds (NL)", "logo": "/static/logos/placeholder.png"},
        {"id": "CN2", "name": "Cincinnati Reds (AA)", "logo": "/static/logos/placeholder.png"},
        {"id": "CN3", "name": "Cincinnati Kelly's Killers", "logo": "/static/logos/placeholder.png"},
        {"id": "CNU", "name": "Cincinnati Outlaw Reds", "logo": "/static/logos/placeholder.png"},
        {"id": "COL", "name": "Colorado Rockies", "logo": "/static/logos/placeholder.png"},
        {"id": "DET", "name": "Detroit Tigers", "logo": "/static/logos/placeholder.png"},
        {"id": "DTN", "name": "Detroit Wolverines", "logo": "/static/logos/placeholder.png"},
        {"id": "ELI", "name": "Elizabeth Resolutes", "logo": "/static/logos/placeholder.png"},
        {"id": "FLO", "name": "Florida Marlins", "logo": "/static/logos/placeholder.png"},
        {"id": "FW1", "name": "Fort Wayne Kekiongas", "logo": "/static/logos/placeholder.png"},
        {"id": "HAR", "name": "Hartford Dark Blues", "logo": "/static/logos/placeholder.png"},
        {"id": "HOU", "name": "Houston Astros", "logo": "/static/logos/placeholder.png"},
        {"id": "HR1", "name": "Hartford Dark Blues", "logo": "/static/logos/placeholder.png"},
        {"id": "IN1", "name": "Indianapolis Blues", "logo": "/static/logos/placeholder.png"},
        {"id": "IN2", "name": "Indianapolis Hoosiers (AA)", "logo": "/static/logos/placeholder.png"},
        {"id": "IN3", "name": "Indianapolis Hoosiers (NL)", "logo": "/static/logos/placeholder.png"},
        {"id": "IND", "name": "Indianapolis Hoosiers (FL)", "logo": "/static/logos/placeholder.png"},
        {"id": "KC1", "name": "Kansas City Athletics", "logo": "/static/logos/placeholder.png"},
        {"id": "KC2", "name": "Kansas City Cowboys (AA)", "logo": "/static/logos/placeholder.png"},
        {"id": "KCA", "name": "Kansas City Royals", "logo": "/static/logos/placeholder.png"},
        {"id": "KCF", "name": "Kansas City Packers", "logo": "/static/logos/placeholder.png"},
        {"id": "KCN", "name": "Kansas City Cowboys (NL)", "logo": "/static/logos/placeholder.png"},
        {"id": "KCU", "name": "Kansas City Cowboys (UA)", "logo": "/static/logos/placeholder.png"},
        {"id": "KEO", "name": "Keokuk Westerns", "logo": "/static/logos/placeholder.png"},
        {"id": "LAA", "name": "Los Angeles Angels", "logo": "/static/logos/placeholder.png"},
        {"id": "LAN", "name": "Los Angeles Dodgers", "logo": "/static/logos/placeholder.png"},
        {"id": "LS1", "name": "Louisville Grays", "logo": "/static/logos/placeholder.png"},
        {"id": "LS2", "name": "Louisville Colonels (AA)", "logo": "/static/logos/placeholder.png"},
        {"id": "LS3", "name": "Louisville Colonels (NL)", "logo": "/static/logos/placeholder.png"},
        {"id": "MIA", "name": "Miami Marlins", "logo": "/static/logos/placeholder.png"},
        {"id": "MID", "name": "Middletown Mansfields", "logo": "/static/logos/placeholder.png"},
        {"id": "MIL", "name": "Milwaukee Brewers", "logo": "/static/logos/placeholder.png"},
        {"id": "MIN", "name": "Minnesota Twins", "logo": "/static/logos/placeholder.png"},
        {"id": "ML1", "name": "Milwaukee Braves", "logo": "/static/logos/placeholder.png"},
        {"id": "ML2", "name": "Milwaukee Grays", "logo": "/static/logos/placeholder.png"},
        {"id": "ML3", "name": "Milwaukee Brewers (AA)", "logo": "/static/logos/placeholder.png"},
        {"id": "ML4", "name": "Milwaukee Brewers", "logo": "/static/logos/placeholder.png"},
        {"id": "MLA", "name": "Milwaukee Brewers (AL)", "logo": "/static/logos/placeholder.png"},
        {"id": "MLU", "name": "Milwaukee Brewers (UA)", "logo": "/static/logos/placeholder.png"},
        {"id": "MON", "name": "Montreal Expos", "logo": "/static/logos/placeholder.png"},
        {"id": "NEW", "name": "Newark Peppers", "logo": "/static/logos/placeholder.png"},
        {"id": "NH1", "name": "New Haven Elm Citys", "logo": "/static/logos/placeholder.png"},
        {"id": "NY1", "name": "New York Giants", "logo": "/static/logos/placeholder.png"},
        {"id": "NY2", "name": "New York Mutuals", "logo": "/static/logos/placeholder.png"},
        {"id": "NY3", "name": "New York Mutuals", "logo": "/static/logos/placeholder.png"},
        {"id": "NY4", "name": "New York Metropolitans", "logo": "/static/logos/placeholder.png"},
        {"id": "NYA", "name": "New York Yankees", "logo": "/static/logos/placeholder.png"},
        {"id": "NYN", "name": "New York Mets", "logo": "/static/logos/placeholder.png"},
        {"id": "NYP", "name": "New York Giants (PL)", "logo": "/static/logos/placeholder.png"},
        {"id": "OAK", "name": "Oakland Athletics", "logo": "/static/logos/placeholder.png"},
        {"id": "PH1", "name": "Philadelphia Athletics", "logo": "/static/logos/placeholder.png"},
        {"id": "PH2", "name": "Philadelphia Centennials", "logo": "/static/logos/placeholder.png"},
        {"id": "PH3", "name": "Philadelphia White Stockings", "logo": "/static/logos/placeholder.png"},
        {"id": "PH4", "name": "Philadelphia Athletics (AA)", "logo": "/static/logos/placeholder.png"},
        {"id": "PHA", "name": "Philadelphia Athletics (AL)", "logo": "/static/logos/placeholder.png"},
        {"id": "PHI", "name": "Philadelphia Phillies", "logo": "/static/logos/placeholder.png"},
        {"id": "PHN", "name": "Philadelphia Athletics (NL)", "logo": "/static/logos/placeholder.png"},
        {"id": "PHP", "name": "Philadelphia Quakers", "logo": "/static/logos/placeholder.png"},
        {"id": "PHU", "name": "Philadelphia Keystones", "logo": "/static/logos/placeholder.png"},
        {"id": "PIT", "name": "Pittsburgh Pirates", "logo": "/static/logos/placeholder.png"},
        {"id": "PRO", "name": "Providence Grays", "logo": "/static/logos/placeholder.png"},
        {"id": "PT1", "name": "Pittsburgh Alleghenys", "logo": "/static/logos/placeholder.png"},
        {"id": "PTF", "name": "Pittsburgh Rebels", "logo": "/static/logos/placeholder.png"},
        {"id": "PTP", "name": "Pittsburgh Burghers", "logo": "/static/logos/placeholder.png"},
        {"id": "RC1", "name": "Rockford Forest Citys", "logo": "/static/logos/placeholder.png"},
        {"id": "RC2", "name": "Rochester Broncos", "logo": "/static/logos/placeholder.png"},
        {"id": "RIC", "name": "Richmond Virginians", "logo": "/static/logos/placeholder.png"},
        {"id": "SDN", "name": "San Diego Padres", "logo": "/static/logos/placeholder.png"},
        {"id": "SE1", "name": "Seattle Pilots", "logo": "/static/logos/placeholder.png"},
        {"id": "SEA", "name": "Seattle Mariners", "logo": "/static/logos/placeholder.png"},
        {"id": "SFN", "name": "San Francisco Giants", "logo": "/static/logos/placeholder.png"},
        {"id": "SL1", "name": "St. Louis Brown Stockings", "logo": "/static/logos/placeholder.png"},
        {"id": "SL2", "name": "St. Louis Red Stockings", "logo": "/static/logos/placeholder.png"},
        {"id": "SL3", "name": "St. Louis Brown Stockings", "logo": "/static/logos/placeholder.png"},
        {"id": "SL4", "name": "St. Louis Browns (AA)", "logo": "/static/logos/placeholder.png"},
        {"id": "SL5", "name": "St. Louis Maroons", "logo": "/static/logos/placeholder.png"},
        {"id": "SLA", "name": "St. Louis Browns (AL)", "logo": "/static/logos/placeholder.png"},
        {"id": "SLF", "name": "St. Louis Terriers", "logo": "/static/logos/placeholder.png"},
        {"id": "SLN", "name": "St. Louis Cardinals", "logo": "/static/logos/placeholder.png"},
        {"id": "SLU", "name": "St. Louis Maroons (UA)", "logo": "/static/logos/placeholder.png"},
        {"id": "SPU", "name": "St. Paul White Caps", "logo": "/static/logos/placeholder.png"},
        {"id": "SR1", "name": "Syracuse Stars", "logo": "/static/logos/placeholder.png"},
        {"id": "SR2", "name": "Syracuse Stars", "logo": "/static/logos/placeholder.png"},
        {"id": "TBA", "name": "Tampa Bay Rays", "logo": "/static/logos/placeholder.png"},
        {"id": "TEX", "name": "Texas Rangers", "logo": "/static/logos/placeholder.png"},
        {"id": "TL1", "name": "Toledo Blue Stockings", "logo": "/static/logos/placeholder.png"},
        {"id": "TL2", "name": "Toledo Maumees", "logo": "/static/logos/placeholder.png"},
        {"id": "TOR", "name": "Toronto Blue Jays", "logo": "/static/logos/placeholder.png"},
        {"id": "TRN", "name": "Troy Trojans", "logo": "/static/logos/placeholder.png"},
        {"id": "TRO", "name": "Troy Haymakers", "logo": "/static/logos/placeholder.png"},
        {"id": "WAS", "name": "Washington Nationals", "logo": "/static/logos/placeholder.png"},
        {"id": "WIL", "name": "Wilmington Quicksteps", "logo": "/static/logos/placeholder.png"},
        {"id": "WOR", "name": "Worcester Ruby Legs", "logo": "/static/logos/placeholder.png"},
        {"id": "WS1", "name": "Washington Senators", "logo": "/static/logos/placeholder.png"},
        {"id": "WS2", "name": "Washington Senators", "logo": "/static/logos/placeholder.png"},
        {"id": "WS3", "name": "Washington Olympics", "logo": "/static/logos/placeholder.png"},
        {"id": "WS4", "name": "Washington Nationals", "logo": "/static/logos/placeholder.png"},
        {"id": "WS5", "name": "Washington Blue Legs", "logo": "/static/logos/placeholder.png"},
        {"id": "WS6", "name": "Washington Nationals", "logo": "/static/logos/placeholder.png"},
        {"id": "WS7", "name": "Washington Nationals (UA)", "logo": "/static/logos/placeholder.png"},
        {"id": "WS8", "name": "Washington Nationals (NL)", "logo": "/static/logos/placeholder.png"},
        {"id": "WS9", "name": "Washington Statesmen", "logo": "/static/logos/placeholder.png"},
        {"id": "WSU", "name": "Washington Nationals (UA)", "logo": "/static/logos/placeholder.png"},
    ]
    return template('show_teams', teams=teams)

# This function is used to get the data for the effectiveness page
@app.route('/api/effectiveness')
def get_effectiveness_data():
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT
            "yearID",
            AVG("ERA") AS avg_era,
            SUM("SO") AS total_strikeouts,
            SUM("BB") AS total_walks,
            SUM("H") AS total_hits_allowed
        FROM 
            pitching
        WHERE
            "ERA" IS NOT NULL
            AND "SO" IS NOT NULL
            AND "BB" IS NOT NULL
            AND "H" IS NOT NULL
        GROUP BY
            "yearID"
        ORDER BY
            "yearID" ASC;
    """)
    rows = cursor.fetchall()
    conn.close()

    return json.dumps([
        {
            "year": int(row[0]),
            "era": float(row[1]),
            "so": int(row[2]),
            "bb": int(row[3]),
            "h": int(row[4])
        } for row in rows
    ])

# This function is used to display the effectiveness page  
@app.route('/effectiveness')
def show_effectiveness():
    return template('show_effectiveness')

# This function is used to get the data for the team dominance page
@app.route('/api/team_dominance')
def get_team_dominance_data():
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT 
            "teamID",
            AVG("ERA") AS avg_era,
            SUM("SO") AS total_strikeouts,
            SUM("BB") AS total_walks,
            SUM("H") AS total_hits_allowed
        FROM 
            pitching
        WHERE
            "ERA" IS NOT NULL
            AND "SO" IS NOT NULL
            AND "BB" IS NOT NULL
            AND "H" IS NOT NULL
        GROUP BY 
            "teamID"
        ORDER BY 
            "teamID" ASC;
    """)
    rows = cursor.fetchall()
    conn.close()

    return json.dumps([
        {
            "team": row[0],
            "era": float(row[1]),
            "so": int(row[2]),
            "bb": int(row[3]),
            "h": int(row[4])
        } for row in rows
    ])

# This function is used to display the team dominance page
@app.route('/team_dominance')
def show_team_dominance():
    return template('show_team_dominance')

# This function is used to get the data for the pitcher Hall of Fame stats
@app.route('/api/pitcher_hof_stats')
def get_pitcher_hof_stats():
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT
            COUNT(DISTINCT p."playerID") AS total_pitchers,
            COUNT(DISTINCT CASE WHEN h."inducted" = true THEN p."playerID" END) AS hof_pitchers,
            COUNT(DISTINCT CASE WHEN h."inducted" IS DISTINCT FROM true THEN p."playerID" END) AS non_hof_pitchers
        FROM
            pitching p
        LEFT JOIN
            hallOfFame h ON p."playerID" = h."playerID";
    """)

    result = cursor.fetchone()
    conn.close()

    return json.dumps({
        "total": result[0],
        "hof": result[1],
        "non_hof": result[2]
    })

    
# This function is used to get the data for the list of hall of fame pitchers
@app.route('/api/hof_pitchers_list')
def get_hof_pitchers_list():
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT DISTINCT p."playerID"
        FROM pitching p
        JOIN hallOfFame h ON p."playerID" = h."playerID"
        WHERE h."inducted" = true
          AND h."category" = 'Player';
    """)
    rows = cursor.fetchall()
    conn.close()

    player_name_map = load_playerid_fullname_mapping()

    return json.dumps([
        {
            "playerID": row[0],
            "fullName": player_name_map.get(row[0], row[0])
        }
        for row in rows
    ])

# This function is used to display the pitcher Hall of Fame page
@app.route('/pitcher_hof')
def show_pitcher_hof():
    return template('show_pitcher_hof')

# This function is used to get the data for the runs allowed page
@app.route('/api/runs_allowed_spike_data')
def get_runs_allowed_spike_data():
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT
            p."teamID",
            SUM(p."R") AS total_runs_allowed
        FROM
            pitching p
        WHERE p."R" IS NOT NULL
        GROUP BY
            p."teamID";
    """)

    rows = cursor.fetchall()
    conn.close()

    # Team locations and names
    team_info = {
        "ALT": {"name": "Altoona Mountain Citys", "cityState": "Altoona, PA", "lat": 40.5187, "lon": -78.3947},
        "ANA": {"name": "Anaheim Angels", "cityState": "Anaheim, CA", "lat": 33.8353, "lon": -117.9145},
        "ARI": {"name": "Arizona Diamondbacks", "cityState": "Phoenix, AZ", "lat": 33.4484, "lon": -112.0740},
        "ATL": {"name": "Atlanta Braves", "cityState": "Atlanta, GA", "lat": 33.7490, "lon": -84.3880},
        "BAL": {"name": "Baltimore Orioles", "cityState": "Baltimore, MD", "lat": 39.2904, "lon": -76.6122},
        "BFN": {"name": "Buffalo Bisons (NL)", "cityState": "Buffalo, NY", "lat": 42.8864, "lon": -78.8784},
        "BFP": {"name": "Buffalo Bisons (PL)", "cityState": "Buffalo, NY", "lat": 42.8864, "lon": -78.8784},
        "BL1": {"name": "Baltimore Marylands", "cityState": "Baltimore, MD", "lat": 39.2904, "lon": -76.6122},
        "BL2": {"name": "Baltimore Orioles (AA)", "cityState": "Baltimore, MD", "lat": 39.2904, "lon": -76.6122},
        "BL3": {"name": "Baltimore Orioles (AA)", "cityState": "Baltimore, MD", "lat": 39.2904, "lon": -76.6122},
        "BL4": {"name": "Baltimore Canaries", "cityState": "Baltimore, MD", "lat": 39.2904, "lon": -76.6122},
        "BLA": {"name": "Baltimore Orioles (AL)", "cityState": "Baltimore, MD", "lat": 39.2904, "lon": -76.6122},
        "BLF": {"name": "Baltimore Terrapins", "cityState": "Baltimore, MD", "lat": 39.2904, "lon": -76.6122},
        "BLN": {"name": "Baltimore Orioles (NL)", "cityState": "Baltimore, MD", "lat": 39.2904, "lon": -76.6122},
        "BLU": {"name": "Baltimore Monumentals", "cityState": "Baltimore, MD", "lat": 39.2904, "lon": -76.6122},
        "BOS": {"name": "Boston Red Sox", "cityState": "Boston, MA", "lat": 42.3601, "lon": -71.0589},
        "BR1": {"name": "Brooklyn Atlantics", "cityState": "Brooklyn, NY", "lat": 40.6782, "lon": -73.9442},
        "BR2": {"name": "Brooklyn Eckfords", "cityState": "Brooklyn, NY", "lat": 40.6782, "lon": -73.9442},
        "BR3": {"name": "Brooklyn Bridegrooms", "cityState": "Brooklyn, NY", "lat": 40.6782, "lon": -73.9442},
        "BR4": {"name": "Brooklyn Ward's Wonders", "cityState": "Brooklyn, NY", "lat": 40.6782, "lon": -73.9442},
        "BRF": {"name": "Brooklyn Tip-Tops", "cityState": "Brooklyn, NY", "lat": 40.6782, "lon": -73.9442},
        "BRP": {"name": "Brooklyn Gladiators", "cityState": "Brooklyn, NY", "lat": 40.6782, "lon": -73.9442},
        "BRO": {"name": "Brooklyn Dodgers", "cityState": "Brooklyn, NY", "lat": 40.6782, "lon": -73.9442},
        "BS1": {"name": "Boston Red Stockings", "cityState": "Boston, MA", "lat": 42.3601, "lon": -71.0589},
        "BS2": {"name": "Boston Reds (AA)", "cityState": "Boston, MA", "lat": 42.3601, "lon": -71.0589},
        "BSN": {"name": "Boston Braves", "cityState": "Boston, MA", "lat": 42.3601, "lon": -71.0589},
        "BSP": {"name": "Boston Reds (PL)", "cityState": "Boston, MA", "lat": 42.3601, "lon": -71.0589},
        "BSU": {"name": "Boston Reds (UA)", "cityState": "Boston, MA", "lat": 42.3601, "lon": -71.0589},
        "BUF": {"name": "Buffalo Blues", "cityState": "Buffalo, NY", "lat": 42.8864, "lon": -78.8784},
        "CAL": {"name": "California Angels", "cityState": "Anaheim, CA", "lat": 33.8353, "lon": -117.9145},
        "CH1": {"name": "Chicago White Stockings", "cityState": "Chicago, IL", "lat": 41.8781, "lon": -87.6298},
        "CH2": {"name": "Chicago White Stockings", "cityState": "Chicago, IL", "lat": 41.8781, "lon": -87.6298},
        "CHA": {"name": "Chicago White Sox", "cityState": "Chicago, IL", "lat": 41.8781, "lon": -87.6298},
        "CHF": {"name": "Chicago Whales", "cityState": "Chicago, IL", "lat": 41.8781, "lon": -87.6298},
        "CHN": {"name": "Chicago Cubs", "cityState": "Chicago, IL", "lat": 41.8781, "lon": -87.6298},
        "CHP": {"name": "Chicago Pirates", "cityState": "Chicago, IL", "lat": 41.8781, "lon": -87.6298},
        "CHU": {"name": "Chicago Browns", "cityState": "Chicago, IL", "lat": 41.8781, "lon": -87.6298},
        "CIN": {"name": "Cincinnati Reds", "cityState": "Cincinnati, OH", "lat": 39.1031, "lon": -84.5120},
        "CL1": {"name": "Cleveland Forest Citys", "cityState": "Cleveland, OH", "lat": 41.4993, "lon": -81.6944},
        "CL2": {"name": "Cleveland Blues (NL)", "cityState": "Cleveland, OH", "lat": 41.4993, "lon": -81.6944},
        "CL3": {"name": "Cleveland Spiders", "cityState": "Cleveland, OH", "lat": 41.4993, "lon": -81.6944},
        "CL4": {"name": "Cleveland Spiders", "cityState": "Cleveland, OH", "lat": 41.4993, "lon": -81.6944},
        "CL5": {"name": "Cleveland Blues (UA)", "cityState": "Cleveland, OH", "lat": 41.4993, "lon": -81.6944},
        "CL6": {"name": "Cleveland Spiders", "cityState": "Cleveland, OH", "lat": 41.4993, "lon": -81.6944},
        "CLE": {"name": "Cleveland Indians", "cityState": "Cleveland, OH", "lat": 41.4993, "lon": -81.6944},
        "CLP": {"name": "Cleveland Infants", "cityState": "Cleveland, OH", "lat": 41.4993, "lon": -81.6944},
        "CN1": {"name": "Cincinnati Reds (NL)", "cityState": "Cincinnati, OH", "lat": 39.1031, "lon": -84.5120},
        "CN2": {"name": "Cincinnati Reds (AA)", "cityState": "Cincinnati, OH", "lat": 39.1031, "lon": -84.5120},
        "CN3": {"name": "Cincinnati Kelly's Killers", "cityState": "Cincinnati, OH", "lat": 39.1031, "lon": -84.5120},
        "CNU": {"name": "Cincinnati Outlaw Reds", "cityState": "Cincinnati, OH", "lat": 39.1031, "lon": -84.5120},
        "COL": {"name": "Colorado Rockies", "cityState": "Denver, CO", "lat": 39.7392, "lon": -104.9903},
        "DET": {"name": "Detroit Tigers", "cityState": "Detroit, MI", "lat": 42.3314, "lon": -83.0458},
        "DTN": {"name": "Detroit Wolverines", "cityState": "Detroit, MI", "lat": 42.3314, "lon": -83.0458},
        "ELI": {"name": "Elizabeth Resolutes", "cityState": "Elizabeth, NJ", "lat": 40.6634, "lon": -74.2157},
        "FLO": {"name": "Florida Marlins", "cityState": "Miami, FL", "lat": 25.7617, "lon": -80.1918},
        "FW1": {"name": "Fort Wayne Kekiongas", "cityState": "Fort Wayne, IN", "lat": 41.0793, "lon": -85.1394},
        "HAR": {"name": "Hartford Dark Blues", "cityState": "Hartford, CT", "lat": 41.7658, "lon": -72.6751},
        "HOU": {"name": "Houston Astros", "cityState": "Houston, TX", "lat": 29.7604, "lon": -95.3698},
        "HR1": {"name": "Hartford Dark Blues", "cityState": "Hartford, CT", "lat": 41.7658, "lon": -72.6751},
        "IN1": {"name": "Indianapolis Blues", "cityState": "Indianapolis, IN", "lat": 39.7684, "lon": -86.1581},
        "IN2": {"name": "Indianapolis Hoosiers (AA)", "cityState": "Indianapolis, IN", "lat": 39.7684, "lon": -86.1581},
        "IN3": {"name": "Indianapolis Hoosiers (NL)", "cityState": "Indianapolis, IN", "lat": 39.7684, "lon": -86.1581},
        "IND": {"name": "Indianapolis Hoosiers (FL)", "cityState": "Indianapolis, IN", "lat": 39.7684, "lon": -86.1581},
        "KC1": {"name": "Kansas City Athletics", "cityState": "Kansas City, MO", "lat": 39.0997, "lon": -94.5786},
        "KC2": {"name": "Kansas City Cowboys (AA)", "cityState": "Kansas City, MO", "lat": 39.0997, "lon": -94.5786},
        "KCA": {"name": "Kansas City Royals", "cityState": "Kansas City, MO", "lat": 39.0997, "lon": -94.5786},
        "KCF": {"name": "Kansas City Packers", "cityState": "Kansas City, MO", "lat": 39.0997, "lon": -94.5786},
        "KCN": {"name": "Kansas City Cowboys (NL)", "cityState": "Kansas City, MO", "lat": 39.0997, "lon": -94.5786},
        "KCU": {"name": "Kansas City Cowboys (UA)", "cityState": "Kansas City, MO", "lat": 39.0997, "lon": -94.5786},
        "KEO": {"name": "Keokuk Westerns", "cityState": "Keokuk, IA", "lat": 40.3973, "lon": -91.3846},
        "LAA": {"name": "Los Angeles Angels", "cityState": "Anaheim, CA", "lat": 33.8353, "lon": -117.9145},
        "LAN": {"name": "Los Angeles Dodgers", "cityState": "Los Angeles, CA", "lat": 34.0522, "lon": -118.2437},
        "LS1": {"name": "Louisville Grays", "cityState": "Louisville, KY", "lat": 38.2527, "lon": -85.7585},
        "LS2": {"name": "Louisville Colonels (AA)", "cityState": "Louisville, KY", "lat": 38.2527, "lon": -85.7585},
        "LS3": {"name": "Louisville Colonels (NL)", "cityState": "Louisville, KY", "lat": 38.2527, "lon": -85.7585},
        "MIA": {"name": "Miami Marlins", "cityState": "Miami, FL", "lat": 25.7617, "lon": -80.1918},
        "MID": {"name": "Middletown Mansfields", "cityState": "Middletown, CT", "lat": 41.6259, "lon": -72.6504},
        "MIL": {"name": "Milwaukee Brewers", "cityState": "Milwaukee, WI", "lat": 43.0389, "lon": -87.9065},
        "MIN": {"name": "Minnesota Twins", "cityState": "Minneapolis, MN", "lat": 44.9778, "lon": -93.2650},
        "ML1": {"name": "Milwaukee Braves", "cityState": "Milwaukee, WI", "lat": 43.0389, "lon": -87.9065},
        "ML2": {"name": "Milwaukee Grays", "cityState": "Milwaukee, WI", "lat": 43.0389, "lon": -87.9065},
        "ML3": {"name": "Milwaukee Brewers (AA)", "cityState": "Milwaukee, WI", "lat": 43.0389, "lon": -87.9065},
        "ML4": {"name": "Milwaukee Brewers", "cityState": "Milwaukee, WI", "lat": 43.0389, "lon": -87.9065},
        "MLA": {"name": "Milwaukee Brewers (AL)", "cityState": "Milwaukee, WI", "lat": 43.0389, "lon": -87.9065},
        "MLU": {"name": "Milwaukee Brewers (UA)", "cityState": "Milwaukee, WI", "lat": 43.0389, "lon": -87.9065},
        "MON": {"name": "Montreal Expos", "cityState": "Montreal, QC, Canada", "lat": 45.5017, "lon": -73.5673},
        "NEW": {"name": "Newark Peppers", "cityState": "Newark, NJ", "lat": 40.7357, "lon": -74.1724},
        "NH1": {"name": "New Haven Elm Citys", "cityState": "New Haven, CT", "lat": 41.3083, "lon": -72.9279},
        "NY1": {"name": "New York Giants", "cityState": "New York, NY", "lat": 40.7128, "lon": -74.0060},
        "NY2": {"name": "New York Mutuals", "cityState": "New York, NY", "lat": 40.7128, "lon": -74.0060},
        "NY3": {"name": "New York Mutuals", "cityState": "New York, NY", "lat": 40.7128, "lon": -74.0060},
        "NY4": {"name": "New York Metropolitans", "cityState": "New York, NY", "lat": 40.7128, "lon": -74.0060},
        "NYA": {"name": "New York Yankees", "cityState": "Bronx, NY", "lat": 40.8370, "lon": -73.8654},
        "NYN": {"name": "New York Mets", "cityState": "Flushing, NY", "lat": 40.7590, "lon": -73.8300},
        "NYP": {"name": "New York Giants (PL)", "cityState": "New York, NY", "lat": 40.7128, "lon": -74.0060},
        "OAK": {"name": "Oakland Athletics", "cityState": "West Sacramento, CA", "lat": 38.5804, "lon": -121.5133},
        "PH1": {"name": "Philadelphia Athletics", "cityState": "Philadelphia, PA", "lat": 39.9526, "lon": -75.1652},
        "PH2": {"name": "Philadelphia Centennials", "cityState": "Philadelphia, PA", "lat": 39.9526, "lon": -75.1652},
        "PH3": {"name": "Philadelphia White Stockings", "cityState": "Philadelphia, PA", "lat": 39.9526, "lon": -75.1652},
        "PH4": {"name": "Philadelphia Athletics (AA)", "cityState": "Philadelphia, PA", "lat": 39.9526, "lon": -75.1652},
        "PHA": {"name": "Philadelphia Athletics (AL)", "cityState": "Philadelphia, PA", "lat": 39.9526, "lon": -75.1652},
        "PHI": {"name": "Philadelphia Phillies", "cityState": "Philadelphia, PA", "lat": 39.9526, "lon": -75.1652},
        "PHN": {"name": "Philadelphia Athletics (NL)", "cityState": "Philadelphia, PA", "lat": 39.9526, "lon": -75.1652},
        "PHP": {"name": "Philadelphia Quakers", "cityState": "Philadelphia, PA", "lat": 39.9526, "lon": -75.1652},
        "PHU": {"name": "Philadelphia Keystones", "cityState": "Philadelphia, PA", "lat": 39.9526, "lon": -75.1652},
        "PIT": {"name": "Pittsburgh Pirates", "cityState": "Pittsburgh, PA", "lat": 40.4406, "lon": -79.9959},
        "PRO": {"name": "Providence Grays", "cityState": "Providence, RI", "lat": 41.8240, "lon": -71.4128},
        "PT1": {"name": "Pittsburgh Alleghenys", "cityState": "Pittsburgh, PA", "lat": 40.4406, "lon": -79.9959},
        "PTF": {"name": "Pittsburgh Rebels", "cityState": "Pittsburgh, PA", "lat": 40.4406, "lon": -79.9959},
        "PTP": {"name": "Pittsburgh Burghers", "cityState": "Pittsburgh, PA", "lat": 40.4406, "lon": -79.9959},
        "RC1": {"name": "Rockford Forest Citys", "cityState": "Rockford, IL", "lat": 42.2711, "lon": -89.0940},
        "RC2": {"name": "Rochester Broncos", "cityState": "Rochester, NY", "lat": 43.1566, "lon": -77.6088},
        "RIC": {"name": "Richmond Virginians", "cityState": "Richmond, VA", "lat": 37.5407, "lon": -77.4360},
        "SDN": {"name": "San Diego Padres", "cityState": "San Diego, CA", "lat": 32.7157, "lon": -117.1611},
        "SE1": {"name": "Seattle Pilots", "cityState": "Seattle, WA", "lat": 47.6062, "lon": -122.3321},
        "SEA": {"name": "Seattle Mariners", "cityState": "Seattle, WA", "lat": 47.6062, "lon": -122.3321},
        "SFN": {"name": "San Francisco Giants", "cityState": "San Francisco, CA", "lat": 37.7749, "lon": -122.4194},
        "SL1": {"name": "St. Louis Brown Stockings", "cityState": "St. Louis, MO", "lat": 38.6270, "lon": -90.1994},
        "SL2": {"name": "St. Louis Red Stockings", "cityState": "St. Louis, MO", "lat": 38.6270, "lon": -90.1994},
        "SL3": {"name": "St. Louis Brown Stockings", "cityState": "St. Louis, MO", "lat": 38.6270, "lon": -90.1994},
        "SL4": {"name": "St. Louis Browns (AA)", "cityState": "St. Louis, MO", "lat": 38.6270, "lon": -90.1994},
        "SL5": {"name": "St. Louis Maroons", "cityState": "St. Louis, MO", "lat": 38.6270, "lon": -90.1994},
        "SLA": {"name": "St. Louis Browns (AL)", "cityState": "St. Louis, MO", "lat": 38.6270, "lon": -90.1994},
        "SLF": {"name": "St. Louis Terriers", "cityState": "St. Louis, MO", "lat": 38.6270, "lon": -90.1994},
        "SLN": {"name": "St. Louis Cardinals", "cityState": "St. Louis, MO", "lat": 38.6270, "lon": -90.1994},
        "SLU": {"name": "St. Louis Maroons (UA)", "cityState": "St. Louis, MO", "lat": 38.6270, "lon": -90.1994},
        "SPU": {"name": "St. Paul White Caps", "cityState": "St. Paul, MN", "lat": 44.9537, "lon": -93.0900},
        "SR1": {"name": "Syracuse Stars", "cityState": "Syracuse, NY", "lat": 43.0481, "lon": -76.1474},
        "SR2": {"name": "Syracuse Stars", "cityState": "Syracuse, NY", "lat": 43.0481, "lon": -76.1474},
        "TBA": {"name": "Tampa Bay Rays", "cityState": "St. Petersburg, FL", "lat": 27.7676, "lon": -82.6403},
        "TEX": {"name": "Texas Rangers", "cityState": "Arlington, TX", "lat": 32.7357, "lon": -97.1081},
        "TL1": {"name": "Toledo Blue Stockings", "cityState": "Toledo, OH", "lat": 41.6528, "lon": -83.5379},
        "TL2": {"name": "Toledo Maumees", "cityState": "Toledo, OH", "lat": 41.6528, "lon": -83.5379},
        "TOR": {"name": "Toronto Blue Jays", "cityState": "Toronto, ON, Canada", "lat": 43.6532, "lon": -79.3832},
        "TRN": {"name": "Troy Trojans", "cityState": "Troy, NY", "lat": 42.7284, "lon": -73.6918},
        "TRO": {"name": "Troy Haymakers", "cityState": "Troy, NY", "lat": 42.7284, "lon": -73.6918},
        "WAS": {"name": "Washington Nationals", "cityState": "Washington, DC", "lat": 38.8951, "lon": -77.0364},
        "WIL": {"name": "Wilmington Quicksteps", "cityState": "Wilmington, DE", "lat": 39.7447, "lon": -75.5483},
        "WOR": {"name": "Worcester Ruby Legs", "cityState": "Worcester, MA", "lat": 42.2626, "lon": -71.8023},
        "WS1": {"name": "Washington Senators", "cityState": "Washington, DC", "lat": 38.8951, "lon": -77.0364},
        "WS2": {"name": "Washington Senators", "cityState": "Washington, DC", "lat": 38.8951, "lon": -77.0364},
        "WS3": {"name": "Washington Olympics", "cityState": "Washington, DC", "lat": 38.8951, "lon": -77.0364},
        "WS4": {"name": "Washington Nationals", "cityState": "Washington, DC", "lat": 38.8951, "lon": -77.0364},
        "WS5": {"name": "Washington Blue Legs", "cityState": "Washington, DC", "lat": 38.8951, "lon": -77.0364},
        "WS6": {"name": "Washington Nationals", "cityState": "Washington, DC", "lat": 38.8951, "lon": -77.0364},
        "WS7": {"name": "Washington Nationals (UA)", "cityState": "Washington, DC", "lat": 38.8951, "lon": -77.0364},
        "WS8": {"name": "Washington Nationals (NL)", "cityState": "Washington, DC", "lat": 38.8951, "lon": -77.0364},
        "WS9": {"name": "Washington Statesmen", "cityState": "Washington, DC", "lat": 38.8951, "lon": -77.0364},
        "WSU": {"name": "Washington Nationals (UA)", "cityState": "Washington, DC", "lat": 38.8951, "lon": -77.0364}
    }

    result = []
    for row in rows:
        teamID = row[0]
        total_runs_allowed = row[1]
        if teamID in team_info:
            info = team_info[teamID]
            result.append({
                "teamID": teamID,
                "teamName": info["name"],
                "cityState": info["cityState"],
                "lat": info["lat"],
                "lon": info["lon"],
                "totalRunsAllowed": int(total_runs_allowed)
            })

    return json.dumps(result)

# This function is used to display the runs allowed page
@app.route('/runs_allowed')
def show_runs_allowed():
    return template('show_runs_allowed')

# This function is used to get the data for the games played page
@app.route('/api/games_played_data')
def get_games_played_data():
    conn = connect_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT "playerID", 
               SUM("G") AS total_games
        FROM pitching
        WHERE "G" IS NOT NULL
        GROUP BY "playerID";
    """)

    rows = cursor.fetchall()
    conn.close()

    data = [{"playerID": row[0], "G": int(row[1])} for row in rows]
    return json.dumps(data)

# This function is used to display the games played page
@app.route('/games_played')
def show_games_played():
    return template('show_games_played')

# This function is used to get the data for the strikeout vs walk page
@app.route('/api/strikeout_walk_data')
def get_strikeout_walk_data():
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT "playerID",
               SUM("SO") AS total_so,
               SUM("BB") AS total_bb
        FROM pitching
        WHERE "SO" IS NOT NULL AND "BB" IS NOT NULL
        GROUP BY "playerID";
    """)

    rows = cursor.fetchall()
    conn.close()

    data = [{"playerID": row[0], "SO": int(row[1]), "BB": int(row[2])} for row in rows]
    return json.dumps(data)


# This function is used to display the strikeout vs walk page
@app.route('/walk_strikeout')
def show_walk_strikeout():
    return template('show_walk_strikeout')

# This function is used to get the data for the home run vs era page
@app.route('/api/hr_vs_era_data')
def get_hr_vs_era_data():
    conn = connect_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT 
            p."playerID",
            SUM(p."HR") AS total_hr,
            SUM(p."IPouts") AS total_outs,
            AVG(p."ERA") AS avg_era
        FROM 
            pitching p
        WHERE 
            p."HR" IS NOT NULL AND p."ERA" IS NOT NULL AND p."IPouts" IS NOT NULL
        GROUP BY 
            p."playerID";
    """)

    rows = cursor.fetchall()
    conn.close()

    result = []
    for row in rows:
        playerID = row[0]
        hr = float(row[1])
        ipouts = float(row[2])
        era = float(row[3])
        ip = ipouts / 3.0  # This converts outs to innings

        result.append({
            "playerID": playerID,
            "HR": hr,
            "ERA": era,
            "IP": ip
        })

    return json.dumps(result)

# This function is used to display the home run vs era page
@app.route('/hr_vs_era')
def show_hr_vs_era():
    return template('show_hr_vs_era')

# This function is used to get the data for the clutch pitching page
@app.route('/api/clutch_pitching_data')
def get_clutch_pitching_data():
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT 
            p."playerID",
            AVG(p."ERA") AS avg_era,
            SUM(p."SO") AS total_so,
            SUM(p."BB") AS total_bb,
            SUM(p."HR") AS total_hr,
            SUM(p."GF") AS total_gf
        FROM 
            pitching p
        WHERE 
            p."GF" > 10
        GROUP BY 
            p."playerID"
    """)
    rows = cursor.fetchall()
    conn.close()

    name_map = load_playerid_fullname_mapping()

    result = []
    for row in rows:
        playerID = row[0]
        ERA = float(row[1])
        SO = int(row[2])
        BB = int(row[3])
        HR = int(row[4])
        GF = int(row[5])

        if BB == 0:
            KBB = SO
        else:
            KBB = SO / BB

        score = (0.4 * ERA) + (0.3 * KBB) + (0.2 * GF) - (0.1 * HR)
        fullName = name_map.get(playerID, playerID)

        result.append({
            "playerID": playerID,
            "fullName": fullName,
            "ERA": round(ERA, 2),
            "SO": SO,
            "BB": BB,
            "HR": HR,
            "GF": GF,
            "KBB": round(KBB, 2),
            "score": round(score, 2)
        })

    top_50 = sorted(result, key=lambda x: x["score"])[:50]
    return json.dumps(top_50)

# This function is used to display the clutch pitching page
@app.route('/clutch_pitching')
def show_clutch_pitching():
    return template('show_clutch_pitching')

# This function is used to get the data for the innings trend page
@app.route('/api/innings_trend')
def get_innings_trend_data():
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT 
            "yearID", 
            AVG("IPouts") / 3.0 AS avg_innings_per_pitcher
        FROM 
            pitching
        WHERE 
            "IPouts" IS NOT NULL
        GROUP BY 
            "yearID"
        ORDER BY 
            "yearID" ASC;
    """)
    
    rows = cursor.fetchall()
    conn.close()
    
    return json.dumps([
        {
            "year": int(row[0]),
            "innings": round(float(row[1]), 2)
        }
        for row in rows
    ])

# This function is used to display the innings trend page
@app.route('/innings_trend')
def show_innings_trend():
    return template('show_innings_trend')

# This function is used to get the data for the batters faced page
@app.route('/api/batters_faced')
def get_batters_faced_data():
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT 
            "playerID",
            SUM("BFP") AS total_bfp
        FROM 
            pitching
        WHERE "BFP" IS NOT NULL
        GROUP BY "playerID"
        ORDER BY total_bfp DESC;
    """)
    rows = cursor.fetchall()
    conn.close()

    player_name_map = load_playerid_fullname_mapping()

    return json.dumps([
        {
            "playerID": row[0],
            "fullName": player_name_map.get(row[0], row[0]),
            "BFP": int(row[1])
        }
        for row in rows
    ])

# This function is used to display the batters faced page
@app.route('/batters_faced')
def show_batters_faced():
    return template('show_batters_faced')

# This function is used to display the report page
@app.route('/report')
def show_report():
    return template('show_report')


if __name__ == '__main__':
    app.run(host = '127.0.0.1', port = 8080, reloader = True)