CREATE TABLE cards (
    card_id INTEGER PRIMARY KEY,
    card_text VarChar(140) NOT NULL,
    theme VarChar(30),
    num_dealt INTEGER NOT NULL DEFAULT 0,
    num_played INTEGER NOT NULL DEFAULT 0,
    num_not_played INTEGER,
    num_won_round INTEGER,
    num_thumbs_up INTEGER,
    num_thumbs_down INTEGER
    user_generated BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE users (
    facebook_id INTEGER PRIMARY KEY,
    first_name VarChar(30) NOT NULL,
    last_name VarChar(30) NOT NULL,
    gender VarChar(30),
    uc_player_name VarChar(30),
    num_games_won INTEGER,
    num_games_played INTEGER,
    num_games_hosted INTEGER,
    num_times_hosted INTEGER,
    num_times_photo_user_played INTEGER,
    email_address VarChar(30),
    num_votes_card_quality INTEGER,
    num_submissions INTEGER
);

CREATE TABLE games (
    game_id INTEGER PRIMARY KEY,
    created_time INTEGER NOT NULL,
    start_time INTEGER,
    end_time INTEGER,
    num_hands_played INTEGER,
    num_hands_to_win INTEGER,
    game_status = ENUM('pending', 'in progress', 'completed') NOT NULL,
    num_players INTEGER,
    num_cards_per_hand INTEGER NOT NULL,
    host_fb_id INTEGER NOT NULL,
    player_2_fb_id INTEGER NOT NULL,
    player_3_fb_id INTEGER NOT NULL,
    player_4_fb_id INTEGER NOT NULL,
    player_5_fb_id INTEGER NOT NULL,
    player_6_fb_id INTEGER NOT NULL,
    player_7_fb_id INTEGER NOT NULL,
    player_8_fb_id INTEGER NOT NULL,
    player_9_fb_id INTEGER NOT NULL,
    player_10_fb_id INTEGER NOT NULL
);

CREATE TABLE winning_cards (
    index INTEGER PRIMARY KEY,
    card_id INTEGER NOT NULL,
    game_id INTEGER NOT NULL
);

INSERT INTO cards (card_text) VALUES
    ('Stands out like a rasin in a bowl of buttered popcorn.'),
    ('The Real Slim Shady(tm)'),
    ('I don''t need to tell you about inappropriate love.'),
    ('My next step is to search for pictures of
        naked ladies on my office computer.'),
    ('Hiding in the closet.'),
    ('We get it, you''re gay.'),
    ('Dirty Sanchez'),
    ('Yellow Fever')
    ('Shouldn''t you be mowing somebody''s lawn?'),
    ('Conspiracy theorist'),
    ('Is that an adam''s apple?!'),
    ('If it wasn''t for hookers, I would never have met your mother.'),
    ('Are your eyes always different sizes?'),
    ('What is it?...'),
    ('La Chupacabra'),
    ('Redneck Vampire'),
    ('I like toy-tules!'),
    ('Rides the short bus.'),
    ('He''s not gay, he''s hindu.'),
    ('Leprechan without gold.'),
    ('You remind me of 2005...'),
    ('Gym, Tan, Laundry'),
    ('The Joisey Shure'),
    ('If you''re still wearing earrings, you probably peaked in highschool.'),
    ('Future Catholic Priest'),
    ('Dibs!'),
    ('The acid trip that broke the camel''s back'),,
    ('Danny DeVito'),
    ('In-cognito big tits'),
    ('Pee-Wee Herman'),
    ('The DJ that only plays Eminem and Limp Bizkit'),
    ('Girls Gone Wild'),
    ('Andy Dick'),
    ('Fred Durst'),
    ('Whitney Houston high on crack'),
    ('Snookie'),
    ('“The Situation”'),
    ('Pauly D.'),
    ('Chris Angel'),
    ('Run Forest Run!'),
    ('Marsha Marsha Marsha'),
    ('The opposite of James Bond'),
    ('Catlady'),
    ('You are soo white, if you ever flew to the middle east you would jump straigh
        off the plane and into the terrorist''s kidnapping sack.'),
    ('Steroids!'),
    ('Undefeated Double Down Challenge Winner'),
    ('You look like you dye your hair with a bottle of “Soccer Mom No. 45”'),
    ('All the best cowboys have daddy issues'),
    ('Do you even lift?');



