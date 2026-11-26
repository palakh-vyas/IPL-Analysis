-- Query 1.1: Win % per team
WITH team_matches AS (
    SELECT id, team1 AS team, winner FROM matches
    UNION ALL
    SELECT id, team2 AS team, winner FROM matches
)
SELECT team,
       SUM(CASE WHEN winner IS NOT NULL THEN 1 ELSE 0 END) AS matches_decided,
       SUM(CASE WHEN winner = team THEN 1 ELSE 0 END) AS wins,
       ROUND(100.0 * SUM(CASE WHEN winner = team THEN 1 ELSE 0 END)
             / NULLIF(SUM(CASE WHEN winner IS NOT NULL THEN 1 ELSE 0 END), 0), 2) AS win_pct
FROM team_matches
GROUP BY team
ORDER BY win_pct DESC;

-- Query 2.1: Toss impact
WITH toss_matches AS (
    SELECT toss_decision,
           CASE WHEN toss_winner = winner THEN 1 ELSE 0 END AS toss_winner_won
    FROM matches
    WHERE winner IS NOT NULL AND toss_winner IS NOT NULL
)
SELECT 'All matches' AS toss_decision, COUNT(*) AS matches,
       SUM(toss_winner_won) AS toss_winner_wins,
       ROUND(100.0 * SUM(toss_winner_won) / COUNT(*), 2) AS toss_win_pct
FROM toss_matches
UNION ALL
SELECT toss_decision, COUNT(*), SUM(toss_winner_won),
       ROUND(100.0 * SUM(toss_winner_won) / COUNT(*), 2)
FROM toss_matches GROUP BY toss_decision;

-- Query 3.2: Bat first vs chase (batting order from ball-by-ball data)
WITH first_bat AS (
    SELECT DISTINCT match_id, batting_team AS bat_first_team
    FROM deliveries WHERE inning = 1
)
SELECT
    COUNT(*) AS decided_matches,
    SUM(CASE WHEN m.winner = f.bat_first_team THEN 1 ELSE 0 END) AS bat_first_wins,
    SUM(CASE WHEN m.winner <> f.bat_first_team THEN 1 ELSE 0 END) AS chase_wins,
    ROUND(100.0 * SUM(CASE WHEN m.winner = f.bat_first_team THEN 1 ELSE 0 END) / COUNT(*), 2) AS bat_first_win_pct,
    ROUND(100.0 * SUM(CASE WHEN m.winner <> f.bat_first_team THEN 1 ELSE 0 END) / COUNT(*), 2) AS chase_win_pct
FROM matches m
JOIN first_bat f ON f.match_id = m.id
WHERE m.winner IS NOT NULL AND m.result IN ('runs', 'wickets');

-- Query 3.3: Bat first vs chase by season, with 3-season moving average
WITH first_bat AS (
    SELECT DISTINCT match_id, batting_team AS bat_first_team
    FROM deliveries WHERE inning = 1
),
season_stats AS (
    SELECT m.season_year,
           COUNT(*) AS decided_matches,
           ROUND(100.0 * SUM(CASE WHEN m.winner = f.bat_first_team THEN 1 ELSE 0 END) / COUNT(*), 2) AS bat_first_win_pct,
           ROUND(100.0 * SUM(CASE WHEN m.winner <> f.bat_first_team THEN 1 ELSE 0 END) / COUNT(*), 2) AS chase_win_pct
    FROM matches m
    JOIN first_bat f ON f.match_id = m.id
    WHERE m.winner IS NOT NULL AND m.result IN ('runs', 'wickets')
    GROUP BY m.season_year
)
SELECT season_year, decided_matches, bat_first_win_pct, chase_win_pct,
       ROUND(AVG(chase_win_pct) OVER (
           ORDER BY season_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS chase_win_pct_3yr_avg
FROM season_stats
ORDER BY season_year;

-- Query 3.4: Sensitivity check excluding DLS matches
WITH first_bat AS (
    SELECT DISTINCT match_id, batting_team AS bat_first_team
    FROM deliveries WHERE inning = 1
)
SELECT COUNT(*) AS matches_without_dls,
       ROUND(100.0 * SUM(CASE WHEN m.winner = f.bat_first_team THEN 1 ELSE 0 END) / COUNT(*), 2) AS bat_first_win_pct,
       ROUND(100.0 * SUM(CASE WHEN m.winner <> f.bat_first_team THEN 1 ELSE 0 END) / COUNT(*), 2) AS chase_win_pct
FROM matches m
JOIN first_bat f ON f.match_id = m.id
WHERE m.winner IS NOT NULL AND m.result IN ('runs', 'wickets') AND m.method IS NULL;