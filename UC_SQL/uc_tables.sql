CREATE TABLE card (
    card_id INTEGER PRIMARY KEY,
    card_text VarChar(140) NOT NULL,
    theme VarChar(30),
    num_dealt INTEGER NOT NULL,
    num_played INTEGER NOT NULL,
    num_not_played INTEGER,
    num_won_round INTEGER,
    num_thumbs_up INTEGER,
    num_thumbs_down INTEGER
    user_generated BOOLEAN NOT NULL
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
)

