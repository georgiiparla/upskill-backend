-- =======================================================================
-- REFACTORED DEPLOYMENT SCRIPT
-- Purpose: Full reset of gamification and agenda items.
-- Dependencies: User 'alex@example.com' must exist (from seeds/manual creation).
-- Safety: Uses transactions. Operations are ordered to satisfy Foreign Keys.
-- =======================================================================

BEGIN;

-- -----------------------------------------------------------------------
-- 1. CLEANUP (DESTRUCTIVE)
-- -----------------------------------------------------------------------

-- 1a. Clean Activity Streams related to Agenda Items
-- Since ActivityStream is polymorphic, we must clean these up before deleting 
-- the parent AgendaItems to avoid orphaned records.
DELETE FROM activity_streams 
WHERE target_type = 'AgendaItem';

-- 1b. Delete ALL Agenda Items
-- This clears both system mantras and user-created items.
-- Must be done before deleting mantras due to FK constraint (mantra_id).
DELETE FROM agenda_items;

-- 1c. Clear Mantras
DELETE FROM mantras;

-- 1d. Reset Gamification Data
-- Order is critical: UserQuests (Child) -> QuestResets (Child) -> Quests (Parent).
DELETE FROM user_quests;
DELETE FROM quest_resets;
DELETE FROM quests;

-- 1e. Reset Leaderboards
-- We reset points to 0 rather than deleting rows to keep user associations alive.
UPDATE leaderboards SET points = 0;


-- -----------------------------------------------------------------------
-- 2. SEEDING MANTRAS (EXACT SPECIFICATION)
-- -----------------------------------------------------------------------
-- Inserting in specific order to maintain the cycle sequence.

INSERT INTO mantras (text, created_at, updated_at) VALUES
('Better Me + Better You = Better Us', NOW(), NOW()),
('When Furious, Get Curious', NOW(), NOW()),
('You Are Part Of A Tribe; Never Walk Alone', NOW(), NOW()),
('Serve Before Being Served', NOW(), NOW()),
('Stop Starting, Start Finishing', NOW(), NOW()),
('Listen To Understand', NOW(), NOW()),
('One Small Step at a Time', NOW(), NOW()),
('Be Quick But Don''t Hurry', NOW(), NOW()),
('Leave It Better', NOW(), NOW()),
('Be The Driver or Navigator, Not A Passenger', NOW(), NOW()),
('Feedback Is The Breakfast of Champions', NOW(), NOW()),
('Facts Instead Assumptions', NOW(), NOW()),
('Stop The Line', NOW(), NOW()),
('Cutting Corners Hurts', NOW(), NOW());


-- -----------------------------------------------------------------------
-- 3. SEEDING QUESTS (MATCHING APP LOGIC)
-- -----------------------------------------------------------------------
-- Quest Types: 'always' (no limit) vs 'interval-based' (resets daily/weekly).
-- Trigger endpoints must match strings in app/middleware/quest_middleware.rb.

INSERT INTO quests (
  title, description, points, explicit, trigger_endpoint, 
  quest_type, reset_interval_seconds, created_at, updated_at
) VALUES
(
  'Presentation Feedback', 
  'Prepare and deliver your offline presentation/feedback request', 
  25, false, 'FeedbackRequestsController#create', 
  'always', NULL, NOW(), NOW()
),
(
  'Write feedback', 
  'Submit thoughtful feedback on a request', 
  5, false, 'FeedbackSubmissionsController#create', 
  'always', NULL, NOW(), NOW()
),
(
  'Weekly agenda update', 
  'Update the weekly agenda for this week', 
  5, true, 'AgendaItemsController#update', 
  'interval-based', 604800, -- 1 week
  NOW(), NOW()
),
(
  'Receive a like on your feedback', 
  'Earn points when someone likes your feedback', 
  2, false, 'FeedbackSubmissionsController#like_received', 
  'always', NULL, NOW(), NOW()
),
(
  'Daily check-in', 
  'Log in each day to stay connected', 
  1, true, 'AuthController#google_callback', 
  'interval-based', 86400, -- 1 day
  NOW(), NOW()
),
(
  'Like a teammate''s feedback', 
  'Like feedback written by someone else', 
  1, false, 'FeedbackSubmissionsController#like', 
  'always', NULL, NOW(), NOW()
);


-- -----------------------------------------------------------------------
-- 4. SEEDING NEW AGENDA ITEMS
-- -----------------------------------------------------------------------

-- 4a. Create manual Agenda Items owned by 'alex@example.com'
-- We use INSERT INTO ... SELECT to dynamically find Alex's ID.
-- If Alex does not exist, these items simply won't be created (safe failure).

INSERT INTO agenda_items (
  title, type, category, due_date, icon_name, editor_id, link, created_at, updated_at
)
SELECT 
  'The Art of Giving Constructive Feedback', 
  'article', 
  'Communication', 
  '2025-08-18', 
  'FileText', 
  id, -- Dynamic ID from users table
  'https://hbr.org/2018/05/the-right-way-to-respond-to-negative-feedback', 
  NOW(), 
  NOW()
FROM users 
WHERE email = 'alex@example.com';

INSERT INTO agenda_items (
  title, type, category, due_date, icon_name, editor_id, link, created_at, updated_at
)
SELECT 
  'Leading Without Authority', 
  'article', 
  'Leadership', 
  '2025-08-20', 
  'BookOpen', 
  id, -- Dynamic ID from users table
  NULL, 
  NOW(), 
  NOW()
FROM users 
WHERE email = 'alex@example.com';

-- 4b. Initialize "Mantra of the Week" (System Item)
-- Uses the first mantra from the list ('Better Me...').
-- Sets is_system_mantra=true and icon='Star'.
-- Editor is explicitly NULL as this is a system-generated item.

INSERT INTO agenda_items (
  title, icon_name, is_system_mantra, mantra_id, due_date, type, created_at, updated_at
)
SELECT 
  'Mantra of the week: ' || text,
  'Star',
  true,
  id,
  '2026-01-01', -- Set far in future to keep it active
  'mantra',
  NOW(),
  NOW()
FROM mantras
WHERE text = 'Better Me + Better You = Better Us'
LIMIT 1;


-- -----------------------------------------------------------------------
-- 5. BACKFILL USER QUESTS
-- -----------------------------------------------------------------------
-- Ensures every user (including Alex) has an entry for every new quest.
-- Allows users to start earning points immediately without errors.

INSERT INTO user_quests (user_id, quest_id, completed, created_at, updated_at)
SELECT u.id, q.id, false, NOW(), NOW()
FROM users u
CROSS JOIN quests q
ON CONFLICT (user_id, quest_id) DO NOTHING;

-- 6. Initialize Activity Stream markers
-- Ensures the "New" badge logic works correctly for all users.
UPDATE users 
SET last_viewed_activity_stream = NOW() 
WHERE last_viewed_activity_stream IS NULL;

COMMIT;