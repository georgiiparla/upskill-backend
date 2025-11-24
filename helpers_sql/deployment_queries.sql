-- Deployment Queries for Supabase
-- Run these queries in the Supabase SQL Editor after running the migrations.

-- 1. Data Migration: Change 'Lightbulb' icon to 'Star' in agenda_items
-- This ensures the remaining agenda items have the correct icon for the new UI.
UPDATE agenda_items 
SET icon_name = 'Star' 
WHERE icon_name = 'Lightbulb';

-- 2. Managerial: Remove the specific legacy agenda item
-- User wants to replace "Cutting Corner Hurts" with the new system mantra.
DELETE FROM agenda_items 
WHERE title = 'Cutting Corner Hurts';

-- 3. Seed Data: Mantras
-- Populating the new 'mantras' table.
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

-- 4. Seed Data: Initial System Mantra Agenda Item
-- This inserts the new "Mantra of the week" item.
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
