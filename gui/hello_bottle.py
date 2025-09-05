# No longer need psycopg import since I am not using PostgreSQL Database any longer
# from psycopg import connect
from bottle import Bottle, template, static_file, request, SimpleTemplate
import json
import csv
import sqlite3

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
    
    def load_teams():
        with open(r"gui\static\teams.json", "r", encoding="utf-8") as file:
            return json.load(file)
        
    teams = load_teams()
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
        WHERE h."inducted" = 't'
          AND h."category" = 'Player';
    """)
    rows = cursor.fetchall()
    conn.close()

    player_name_map = load_playerid_fullname_mapping()
    print([row[0] for row in rows])

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
    
    def load_team_info():
        with open(r"gui\static\team_info.json", "r", encoding="utf-8") as file:
            return json.load(file)

    # Team Locations and Names
    team_info = load_team_info()

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