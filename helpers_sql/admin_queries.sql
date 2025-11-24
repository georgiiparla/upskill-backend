-- Admin SQL Templates
-- Use these queries to manage the application directly from the database.
-- Replace placeholders like <PLACEHOLDER> with actual values.

-- ==========================================
-- 1. USER MANAGEMENT
-- ==========================================

-- Find a user by email
SELECT * FROM users WHERE email = '<USER_EMAIL>';

-- Find a user by username
SELECT * FROM users WHERE username = '<USERNAME>';

-- Update user email
UPDATE users 
SET email = '<NEW_EMAIL>', updated_at = NOW() 
WHERE email = '<OLD_EMAIL>';

-- Reset user password (requires generating a bcrypt hash externally, or just setting a known hash)
-- CAUTION: You need a valid bcrypt hash for the new password.
-- UPDATE users SET password_digest = '<BCRYPT_HASH>', updated_at = NOW() WHERE email = '<USER_EMAIL>';

-- Check user activity (last viewed streams/quests)
SELECT username, email, last_viewed_activity_stream, last_viewed_quests 
FROM users 
WHERE email = '<USER_EMAIL>';

-- List all users with their quest completion counts
SELECT u.username, COUNT(uq.id) as completed_quests
FROM users u
LEFT JOIN user_quests uq ON u.id = uq.user_id AND uq.completed = true
GROUP BY u.id
ORDER BY completed_quests DESC;


-- ==========================================
-- 2. CONTENT MANAGEMENT: AGENDA ITEMS
-- ==========================================

-- List all agenda items
SELECT id, title, type, due_date, icon_name, is_system_mantra 
FROM agenda_items 
ORDER BY created_at DESC;

-- Create a new standard agenda item (Article/Video/etc)
-- Types: 'article', 'video', 'podcast', 'book', 'course', 'other'
INSERT INTO agenda_items (title, type, category, due_date, icon_name, link, created_at, updated_at)
VALUES (
  '<TITLE>', 
  '<TYPE>', 
  '<CATEGORY>', 
  '<DUE_DATE_YYYY_MM_DD>', 
  'Star', -- Default icon
  '<LINK_URL>', 
  NOW(), 
  NOW()
);

-- Update an agenda item's due date
UPDATE agenda_items 
SET due_date = '<NEW_DATE>', updated_at = NOW() 
WHERE id = <ITEM_ID>;

-- Delete an agenda item
DELETE FROM agenda_items WHERE id = <ITEM_ID>;

-- Force update the "Mantra of the week" item
-- This updates the existing system mantra item to a new mantra.
UPDATE agenda_items
SET 
  title = 'Mantra of the week: ' || (SELECT text FROM mantras WHERE id = <NEW_MANTRA_ID>),
  mantra_id = <NEW_MANTRA_ID>,
  updated_at = NOW()
WHERE is_system_mantra = true;


-- ==========================================
-- 3. CONTENT MANAGEMENT: MANTRAS
-- ==========================================

-- List all mantras
SELECT * FROM mantras ORDER BY created_at DESC;

-- Add a new mantra
INSERT INTO mantras (text, created_at, updated_at)
VALUES ('<MANTRA_TEXT>', NOW(), NOW());

-- Delete a mantra (CAUTION: Check if used in agenda_items first)
-- DELETE FROM mantras WHERE id = <MANTRA_ID>;


-- ==========================================
-- 4. GAMIFICATION & QUESTS
-- ==========================================

-- List all quests
SELECT id, title, points, quest_type, trigger_endpoint, reset_interval_seconds 
FROM quests 
ORDER BY title;

-- Check user progress on a specific quest
SELECT u.username, q.title, uq.completed, uq.last_triggered_at
FROM user_quests uq
JOIN users u ON uq.user_id = u.id
JOIN quests q ON uq.quest_id = q.id
WHERE u.email = '<USER_EMAIL>' AND q.title = '<QUEST_TITLE>';

-- Manually complete a quest for a user
-- 1. Get User ID and Quest ID first
-- 2. Insert or Update
INSERT INTO user_quests (user_id, quest_id, completed, first_awarded_at, created_at, updated_at)
VALUES (
  (SELECT id FROM users WHERE email = '<USER_EMAIL>'),
  (SELECT id FROM quests WHERE title = '<QUEST_TITLE>'),
  true,
  NOW(),
  NOW(),
  NOW()
)
ON CONFLICT (user_id, quest_id) 
DO UPDATE SET completed = true, updated_at = NOW();


-- ==========================================
-- 5. SYSTEM & TROUBLESHOOTING
-- ==========================================

-- Check system settings
SELECT * FROM system_settings;

-- Update a system setting
INSERT INTO system_settings (key, value, created_at, updated_at)
VALUES ('<KEY>', '<VALUE>', NOW(), NOW())
ON CONFLICT (key) DO UPDATE SET value = '<VALUE>', updated_at = NOW();

-- Check recent activity stream events
SELECT u.username, a.event_type, a.created_at
FROM activity_streams a
JOIN users u ON a.actor_id = u.id
ORDER BY a.created_at DESC
LIMIT 20;
