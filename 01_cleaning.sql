-- IPL Data Cleaning (SQLite)
-- 1. Convert text 'NA' to NULL
UPDATE matches SET city            = NULL WHERE city            IN ('NA','');
UPDATE matches SET player_of_match = NULL WHERE player_of_match IN ('NA','');
UPDATE matches SET venue           = NULL WHERE venue           IN ('NA','');
UPDATE matches SET winner          = NULL WHERE winner          IN ('NA','');
UPDATE matches SET result_margin   = NULL WHERE result_margin   IN ('NA','');
UPDATE matches SET target_runs     = NULL WHERE target_runs     IN ('NA','');
UPDATE matches SET target_overs    = NULL WHERE target_overs    IN ('NA','');
UPDATE matches SET method          = NULL WHERE method          IN ('NA','');
UPDATE matches SET umpire1         = NULL WHERE umpire1         IN ('NA','');
UPDATE matches SET umpire2         = NULL WHERE umpire2         IN ('NA','');
UPDATE deliveries SET extras_type      = NULL WHERE extras_type      IN ('NA','');
UPDATE deliveries SET player_dismissed = NULL WHERE player_dismissed IN ('NA','');
UPDATE deliveries SET dismissal_kind   = NULL WHERE dismissal_kind   IN ('NA','');
UPDATE deliveries SET fielder          = NULL WHERE fielder          IN ('NA','');

-- 2. Season year (column already existed in the dataset)
UPDATE matches SET season_year = CAST(substr(date, 1, 4) AS INTEGER);

-- 3. Standardize team names
UPDATE matches SET team1 = CASE team1
    WHEN 'Delhi Daredevils' THEN 'Delhi Capitals'
    WHEN 'Kings XI Punjab' THEN 'Punjab Kings'
    WHEN 'Royal Challengers Bangalore' THEN 'Royal Challengers Bengaluru'
    WHEN 'Rising Pune Supergiants' THEN 'Rising Pune Supergiant'
    ELSE team1 END;
UPDATE matches SET team2 = CASE team2
    WHEN 'Delhi Daredevils' THEN 'Delhi Capitals'
    WHEN 'Kings XI Punjab' THEN 'Punjab Kings'
    WHEN 'Royal Challengers Bangalore' THEN 'Royal Challengers Bengaluru'
    WHEN 'Rising Pune Supergiants' THEN 'Rising Pune Supergiant'
    ELSE team2 END;
UPDATE matches SET toss_winner = CASE toss_winner
    WHEN 'Delhi Daredevils' THEN 'Delhi Capitals'
    WHEN 'Kings XI Punjab' THEN 'Punjab Kings'
    WHEN 'Royal Challengers Bangalore' THEN 'Royal Challengers Bengaluru'
    WHEN 'Rising Pune Supergiants' THEN 'Rising Pune Supergiant'
    ELSE toss_winner END;
UPDATE matches SET winner = CASE winner
    WHEN 'Delhi Daredevils' THEN 'Delhi Capitals'
    WHEN 'Kings XI Punjab' THEN 'Punjab Kings'
    WHEN 'Royal Challengers Bangalore' THEN 'Royal Challengers Bengaluru'
    WHEN 'Rising Pune Supergiants' THEN 'Rising Pune Supergiant'
    ELSE winner END;
UPDATE deliveries SET batting_team = CASE batting_team
    WHEN 'Delhi Daredevils' THEN 'Delhi Capitals'
    WHEN 'Kings XI Punjab' THEN 'Punjab Kings'
    WHEN 'Royal Challengers Bangalore' THEN 'Royal Challengers Bengaluru'
    WHEN 'Rising Pune Supergiants' THEN 'Rising Pune Supergiant'
    ELSE batting_team END;
UPDATE deliveries SET bowling_team = CASE bowling_team
    WHEN 'Delhi Daredevils' THEN 'Delhi Capitals'
    WHEN 'Kings XI Punjab' THEN 'Punjab Kings'
    WHEN 'Royal Challengers Bangalore' THEN 'Royal Challengers Bengaluru'
    WHEN 'Rising Pune Supergiants' THEN 'Rising Pune Supergiant'
    ELSE bowling_team END;

-- 4. Helper columns on deliveries
ALTER TABLE deliveries ADD COLUMN phase TEXT;
UPDATE deliveries SET phase = CASE
    WHEN "over" BETWEEN 0 AND 5  THEN 'Powerplay'
    WHEN "over" BETWEEN 6 AND 14 THEN 'Middle'
    WHEN "over" BETWEEN 15 AND 19 THEN 'Death' END;
ALTER TABLE deliveries ADD COLUMN is_legal_ball INTEGER;
UPDATE deliveries SET is_legal_ball =
    CASE WHEN extras_type IN ('wides','noballs') THEN 0 ELSE 1 END;
ALTER TABLE deliveries ADD COLUMN is_ball_faced INTEGER;
UPDATE deliveries SET is_ball_faced =
    CASE WHEN extras_type = 'wides' THEN 0 ELSE 1 END;
ALTER TABLE deliveries ADD COLUMN is_super_over INTEGER;
UPDATE deliveries SET is_super_over = CASE WHEN inning > 2 THEN 1 ELSE 0 END;

-- 5. Indexes
CREATE INDEX idx_del_match  ON deliveries(match_id);
CREATE INDEX idx_del_batter ON deliveries(batter);
CREATE INDEX idx_del_bowler ON deliveries(bowler);
CREATE INDEX idx_m_season   ON matches(season_year);

-- 6. Merge duplicate venue spellings (58 -> 36)
UPDATE matches SET venue = CASE
  WHEN venue IN ('Arun Jaitley Stadium','Arun Jaitley Stadium, Delhi','Feroz Shah Kotla')
       THEN 'Arun Jaitley Stadium, Delhi'
  WHEN venue IN ('Brabourne Stadium','Brabourne Stadium, Mumbai')
       THEN 'Brabourne Stadium, Mumbai'
  WHEN venue IN ('Dr DY Patil Sports Academy','Dr DY Patil Sports Academy, Mumbai')
       THEN 'Dr DY Patil Sports Academy, Mumbai'
  WHEN venue IN ('Dr. Y.S. Rajasekhara Reddy ACA-VDCA Cricket Stadium','Dr. Y.S. Rajasekhara Reddy ACA-VDCA Cricket Stadium, Visakhapatnam')
       THEN 'Dr. Y.S. Rajasekhara Reddy ACA-VDCA Cricket Stadium, Visakhapatnam'
  WHEN venue IN ('Eden Gardens','Eden Gardens, Kolkata')
       THEN 'Eden Gardens, Kolkata'
  WHEN venue IN ('Himachal Pradesh Cricket Association Stadium','Himachal Pradesh Cricket Association Stadium, Dharamsala')
       THEN 'Himachal Pradesh Cricket Association Stadium, Dharamsala'
  WHEN venue IN ('M Chinnaswamy Stadium','M Chinnaswamy Stadium, Bengaluru','M.Chinnaswamy Stadium')
       THEN 'M Chinnaswamy Stadium, Bengaluru'
  WHEN venue IN ('MA Chidambaram Stadium','MA Chidambaram Stadium, Chepauk','MA Chidambaram Stadium, Chepauk, Chennai')
       THEN 'MA Chidambaram Stadium, Chennai'
  WHEN venue IN ('Maharashtra Cricket Association Stadium','Maharashtra Cricket Association Stadium, Pune','Subrata Roy Sahara Stadium')
       THEN 'Maharashtra Cricket Association Stadium, Pune'
  WHEN venue IN ('Punjab Cricket Association IS Bindra Stadium','Punjab Cricket Association IS Bindra Stadium, Mohali','Punjab Cricket Association IS Bindra Stadium, Mohali, Chandigarh','Punjab Cricket Association Stadium, Mohali')
       THEN 'Punjab Cricket Association IS Bindra Stadium, Mohali'
  WHEN venue IN ('Rajiv Gandhi International Stadium','Rajiv Gandhi International Stadium, Uppal','Rajiv Gandhi International Stadium, Uppal, Hyderabad')
       THEN 'Rajiv Gandhi International Stadium, Hyderabad'
  WHEN venue IN ('Sardar Patel Stadium, Motera','Narendra Modi Stadium, Ahmedabad')
       THEN 'Narendra Modi Stadium, Ahmedabad'
  WHEN venue IN ('Sawai Mansingh Stadium','Sawai Mansingh Stadium, Jaipur')
       THEN 'Sawai Mansingh Stadium, Jaipur'
  WHEN venue IN ('Wankhede Stadium','Wankhede Stadium, Mumbai')
       THEN 'Wankhede Stadium, Mumbai'
  WHEN venue IN ('Sheikh Zayed Stadium','Zayed Cricket Stadium, Abu Dhabi')
       THEN 'Sheikh Zayed Stadium, Abu Dhabi'
  ELSE venue END;