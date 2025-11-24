-- Deployment Queries for Supabase
-- Run these queries in the Supabase SQL Editor after running the migrations.

-- ==========================================
-- 1. AGENDA ITEMS & MANTRAS
-- ==========================================

-- Data Migration: Change 'Lightbulb' icon to 'Star' in agenda_items
UPDATE agenda_items 
SET icon_name = 'Star' 
WHERE icon_name = 'Lightbulb';

-- Managerial: Remove the specific legacy agenda item
DELETE FROM agenda_items 
WHERE title = 'Cutting Corner Hurts';

-- Seed Data: Mantras
INSERT INTO mantras (text, created_at, updated_at)
SELECT 'Every interaction is an opportunity to grow', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM mantras WHERE text = 'Every interaction is an opportunity to grow');

INSERT INTO mantras (text, created_at, updated_at)
SELECT 'Feedback is a gift, not a criticism', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM mantras WHERE text = 'Feedback is a gift, not a criticism');

INSERT INTO mantras (text, created_at, updated_at)
SELECT 'Progress over perfection', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM mantras WHERE text = 'Progress over perfection');

INSERT INTO mantras (text, created_at, updated_at)
SELECT 'Listen first, speak second', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM mantras WHERE text = 'Listen first, speak second');

INSERT INTO mantras (text, created_at, updated_at)
SELECT 'Consistency builds mastery', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM mantras WHERE text = 'Consistency builds mastery');

-- Seed Data: Initial System Mantra Agenda Item
INSERT INTO agenda_items (title, icon_name, is_system_mantra, mantra_id, due_date, type, created_at, updated_at)
SELECT 
  'Mantra of the week: ' || text,
  'Star',
  true,
  id,
  '2025-01-01',
  'mantra',
  NOW(),
  NOW()
FROM mantras
WHERE text = 'Every interaction is an opportunity to grow'
AND NOT EXISTS (SELECT 1 FROM agenda_items WHERE is_system_mantra = true);


-- ==========================================
-- 2. QUESTS & GAMIFICATION
-- ==========================================

-- CLEAR OLD DATA
-- We must delete in this order to satisfy Foreign Key constraints:
-- 1. user_quests (depends on quests and users)
-- 2. quest_resets (depends on quests)
-- 3. quests (parent table)

DELETE FROM user_quests;
DELETE FROM quest_resets;
DELETE FROM quests;

-- RESET LEADERBOARDS
-- Since we wiped user progress, we should reset points to 0 to stay consistent.
UPDATE leaderboards SET points = 0;

-- INSERT NEW QUESTS
-- Based on lib/tasks/quests.rake
INSERT INTO quests (title, description, points, explicit, trigger_endpoint, quest_type, reset_interval_seconds, created_at, updated_at) VALUES
(
  'Presentation Feedback', 
  'Request feedback on a presentation.', 
  25, 
  false, 
  'FeedbackRequestsController#create', 
  'always', 
  NULL, 
  NOW(), 
  NOW()
),
(
  'Submit Feedback', 
  'Provide feedback to a peer.', 
  5, 
  false, 
  'FeedbackSubmissionsController#create', 
  'always', 
  NULL, 
  NOW(), 
  NOW()
),
(
  'Update Agenda', 
  'Update your weekly agenda.', 
  5, 
  true, 
  'AgendaItemsController#update', 
  'interval-based', 
  604800, -- 1 week
  NOW(), 
  NOW()
),
(
  'Feedback Received', 
  'Receive a like on your feedback.', 
  2, 
  false, 
  'FeedbackSubmissionsController#like_received', 
  'always', 
  NULL, 
  NOW(), 
  NOW()
),
(
  'Daily Login', 
  'Log in to the platform.', 
  1, 
  true, 
  'AuthController#google_callback', 
  'interval-based', 
  86400, -- 1 day
  NOW(), 
  NOW()
),
(
  'Like Feedback', 
  'Like a peer''s feedback.', 
  1, 
  false, 
  'FeedbackSubmissionsController#like', 
  'always', 
  NULL, 
  NOW(), 
  NOW()
);

-- BACKFILL USER QUESTS
-- Existing users need to have UserQuest records for the new quests to track progress.
-- We perform a CROSS JOIN to create a record for every user-quest combination.
INSERT INTO user_quests (user_id, quest_id, completed, created_at, updated_at)
SELECT u.id, q.id, false, NOW(), NOW()
FROM users u
CROSS JOIN quests q
ON CONFLICT (user_id, quest_id) DO NOTHING;