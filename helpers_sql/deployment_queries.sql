-- =======================================================================
-- FINAL PRODUCTION DEPLOYMENT SCRIPT
-- EXECUTE AFTER RUNNING `rake db:migrate`
-- =======================================================================

BEGIN;

-- -----------------------------------------------------------------------
-- 1. DATA CLEANUP & NORMALIZATION (AGENDA ITEMS)
-- -----------------------------------------------------------------------

-- Ensure all icons are updated (Redundant safety for migration 20251105)
UPDATE agenda_items 
SET icon_name = 'Star' 
WHERE icon_name = 'Lightbulb';

-- Remove legacy item that is no longer relevant
DELETE FROM agenda_items 
WHERE title = 'Cutting Corner Hurts';

-- -----------------------------------------------------------------------
-- 2. SEEDING MANTRAS
-- -----------------------------------------------------------------------

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

INSERT INTO mantras (text, created_at, updated_at)
SELECT 'Better Me + Better You = Better Us', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM mantras WHERE text = 'Better Me + Better You = Better Us');

-- -----------------------------------------------------------------------
-- 3. INITIALIZING SYSTEM MANTRA
-- -----------------------------------------------------------------------

-- Ensure the dashboard has a "Mantra of the week" to display
INSERT INTO agenda_items (title, icon_name, is_system_mantra, mantra_id, due_date, type, created_at, updated_at)
SELECT 
  'Mantra of the week: ' || text,
  'Star',
  true,
  id,
  '2026-01-01', -- Set far in future
  'mantra',
  NOW(),
  NOW()
FROM mantras
WHERE text = 'Every interaction is an opportunity to grow'
AND NOT EXISTS (SELECT 1 FROM agenda_items WHERE is_system_mantra = true);

-- -----------------------------------------------------------------------
-- 4. GAMIFICATION REFACTOR (DESTRUCTIVE RESET)
-- -----------------------------------------------------------------------

-- Wipe old quest data to support new QuestMiddleware logic
-- Order is important due to Foreign Key constraints
DELETE FROM user_quests;
DELETE FROM quest_resets;
DELETE FROM quests;

-- Reset Leaderboards to 0 (Fresh Start)
UPDATE leaderboards SET points = 0;

-- -----------------------------------------------------------------------
-- 5. SEEDING NEW QUESTS
-- -----------------------------------------------------------------------

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
  604800, -- 1 week in seconds
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
  86400, -- 1 day in seconds
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

-- -----------------------------------------------------------------------
-- 6. BACKFILLING USER QUESTS
-- -----------------------------------------------------------------------

-- Create empty progress records for ALL existing users for ALL new quests
-- This ensures users can immediately start earning points without errors
INSERT INTO user_quests (user_id, quest_id, completed, created_at, updated_at)
SELECT u.id, q.id, false, NOW(), NOW()
FROM users u
CROSS JOIN quests q
ON CONFLICT (user_id, quest_id) DO NOTHING;

COMMIT;