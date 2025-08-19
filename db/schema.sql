-- Drop tables if they exist to ensure a clean slate
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS quests;
DROP TABLE IF EXISTS feedback_history;
DROP TABLE IF EXISTS leaderboard;
DROP TABLE IF EXISTS agenda_items;
DROP TABLE IF EXISTS activity_stream;
DROP TABLE IF EXISTS meetings;

-- Create the users table for authentication
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password_digest TEXT NOT NULL
);

-- Create the quests table
CREATE TABLE quests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    points INTEGER,
    progress INTEGER,
    completed INTEGER DEFAULT 0 -- Using 0 for false, 1 for true
);

-- Create the feedback_history table
CREATE TABLE feedback_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER, -- Link to the user who submitted it
    subject TEXT,
    content TEXT,
    created_at TEXT, -- Storing date as text in YYYY-MM-DD format
    sentiment TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create the leaderboard table
CREATE TABLE leaderboard (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    points INTEGER,
    badges TEXT -- Storing badges as a comma-separated string
);

-- Create agenda_items table for the dashboard
CREATE TABLE agenda_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT, -- 'article' or 'meeting'
    title TEXT,
    category TEXT,
    due_date TEXT
);

-- Create activity_stream table for the dashboard
CREATE TABLE activity_stream (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_name TEXT,
    action TEXT,
    created_at TEXT
);

-- Create meetings table for the dashboard
CREATE TABLE meetings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    meeting_date TEXT,
    status TEXT -- 'Upcoming' or 'Complete'
);