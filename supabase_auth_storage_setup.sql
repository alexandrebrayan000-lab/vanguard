-- =============================================================================
-- supabase_auth_storage_setup.sql
-- SECOND SCRIPT TO RUN — execute AFTER supabase_setup.sql
--
-- This script:
--   1. Adds a user_id column to the `usuarios` table linked to auth.users
--   2. Updates RLS policies on `usuarios` for backward-compatible access control
--   3. Creates a public 'fotos' storage bucket with open read/write policies
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. Add user_id column to usuarios (references Supabase Auth users)
-- -----------------------------------------------------------------------------

ALTER TABLE public.usuarios
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;


-- -----------------------------------------------------------------------------
-- 2. Update RLS policies on usuarios
--
--    Strategy: keep policies permissive (USING true) so the existing app logic
--    continues to work while auth token is used for identity at the app layer.
-- -----------------------------------------------------------------------------

-- Remove old policies (if they exist from the first script)
DROP POLICY IF EXISTS "usuarios_select" ON public.usuarios;
DROP POLICY IF EXISTS "usuarios_insert" ON public.usuarios;
DROP POLICY IF EXISTS "usuarios_update" ON public.usuarios;

-- Allow anyone (anon + authenticated) to read rows
CREATE POLICY "usuarios_select"
  ON public.usuarios
  FOR SELECT
  USING (true);

-- Allow anon to insert (used during cadastro / sign-up flow)
CREATE POLICY "usuarios_insert"
  ON public.usuarios
  FOR INSERT
  WITH CHECK (true);

-- Allow authenticated users to update any row
-- (row-level identity enforced at the application layer via auth token)
CREATE POLICY "usuarios_update"
  ON public.usuarios
  FOR UPDATE
  USING (true)
  WITH CHECK (true);


-- -----------------------------------------------------------------------------
-- 3. Create the 'fotos' storage bucket and its access policies
-- -----------------------------------------------------------------------------

-- Create the bucket (public = true makes objects accessible via public URL)
INSERT INTO storage.buckets (id, name, public)
VALUES ('fotos', 'fotos', true)
ON CONFLICT (id) DO NOTHING;

-- Allow anyone to upload photos
CREATE POLICY "fotos_insert"
  ON storage.objects
  FOR INSERT
  WITH CHECK (bucket_id = 'fotos');

-- Allow anyone to read/view photos
CREATE POLICY "fotos_select"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'fotos');

-- Allow anyone to update photo objects
CREATE POLICY "fotos_update"
  ON storage.objects
  FOR UPDATE
  USING (bucket_id = 'fotos');

-- Allow anyone to delete photo objects
CREATE POLICY "fotos_delete"
  ON storage.objects
  FOR DELETE
  USING (bucket_id = 'fotos');
