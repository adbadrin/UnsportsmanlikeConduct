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
    game_status VarChar(20) NOT NULL,
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
    card_index INTEGER PRIMARY KEY,
    card_id INTEGER NOT NULL,
    game_id INTEGER NOT NULL
);

INSERT INTO cards (card_text) VALUES ('Stands out like a raisin in a bowl of buttered popcorn.');
INSERT INTO cards (card_text) VALUES ('The Real Slim Shady(tm)');
INSERT INTO cards (card_text) VALUES ('I don''t need to tell you about inappropriate love.');
INSERT INTO cards (card_text) VALUES ('My next step is to search for pictures of naked ladies on my office computer.');
INSERT INTO cards (card_text) VALUES ('Hiding in the closet.');
INSERT INTO cards (card_text) VALUES ('We get it; you''re gay.'),
INSERT INTO cards (card_text) VALUES ('Dirty Sanchez');
INSERT INTO cards (card_text) VALUES ('Yellow Fever')
INSERT INTO cards (card_text) VALUES ('Shouldn''t you be mowing somebody''s lawn?');
INSERT INTO cards (card_text) VALUES ('Conspiracy theorist');
INSERT INTO cards (card_text) VALUES ('Is that an adam''s apple?!');
INSERT INTO cards (card_text) VALUES ('If it wasn''t for hookers; I would never have met your mother.'),
INSERT INTO cards (card_text) VALUES ('Are your eyes always different sizes?');
INSERT INTO cards (card_text) VALUES ('What is it?...');
INSERT INTO cards (card_text) VALUES ('La Chupacabra');
INSERT INTO cards (card_text) VALUES ('Redneck Vampire');
INSERT INTO cards (card_text) VALUES ('I like toy-tules!');
INSERT INTO cards (card_text) VALUES ('Rides the short bus.');
INSERT INTO cards (card_text) VALUES ('He''s not gay; he''s hindu.'),
INSERT INTO cards (card_text) VALUES ('Leprechan without gold.');
INSERT INTO cards (card_text) VALUES ('You remind me of 2005...');
INSERT INTO cards (card_text) VALUES ('Gym; Tan, Laundry'),
INSERT INTO cards (card_text) VALUES ('The Joisey Shure');
INSERT INTO cards (card_text) VALUES ('If you''re still wearing earrings; you probably peaked in highschool.'),
INSERT INTO cards (card_text) VALUES ('Future Catholic Priest');
INSERT INTO cards (card_text) VALUES ('Dibs!');
INSERT INTO cards (card_text) VALUES ('The acid trip that broke the camel''s back');,
INSERT INTO cards (card_text) VALUES ('Danny DeVito');
INSERT INTO cards (card_text) VALUES ('In-cognito big tits');
INSERT INTO cards (card_text) VALUES ('Pee-Wee Herman');
INSERT INTO cards (card_text) VALUES ('The DJ that only plays Eminem and Limp Bizkit');
INSERT INTO cards (card_text) VALUES ('Girls Gone Wild');
INSERT INTO cards (card_text) VALUES ('Andy Dick');
INSERT INTO cards (card_text) VALUES ('Fred Durst');
INSERT INTO cards (card_text) VALUES ('Whitney Houston high on crack');
INSERT INTO cards (card_text) VALUES ('Snookie');
INSERT INTO cards (card_text) VALUES ('“The Situation”');
INSERT INTO cards (card_text) VALUES ('Pauly D.');
INSERT INTO cards (card_text) VALUES ('Chris Angel');
INSERT INTO cards (card_text) VALUES ('Run Forest Run!');
INSERT INTO cards (card_text) VALUES ('Marsha Marsha Marsha');
INSERT INTO cards (card_text) VALUES ('The opposite of James Bond');
INSERT INTO cards (card_text) VALUES ('Catlady');
INSERT INTO cards (card_text) VALUES ('You are soo white; if you ever flew to the middle east you would jump straight
    off the plane and into the terrorist''s kidnapping sack.');
INSERT INTO cards (card_text) VALUES ('Steroids!');
INSERT INTO cards (card_text) VALUES ('Undefeated Double Down Challenge Winner');
INSERT INTO cards (card_text) VALUES ('You look like you dye your hair with a bottle of “Soccer Mom No. 45”');
INSERT INTO cards (card_text) VALUES ('All the best cowboys have daddy issues');
INSERT INTO cards (card_text) VALUES ('Do you even lift?');



