-- Fix migration conflict for notes table that already exists
-- This migration handles the case where tables might already exist

-- Check and create types only if they don't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE public.user_role AS ENUM ('admin', 'premium', 'basic');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'note_type') THEN
        CREATE TYPE public.note_type AS ENUM ('text', 'audio', 'image', 'mixed');
    END IF;
END $$;

-- Create user_profiles table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'basic'::public.user_role,
    avatar_url TEXT,
    preferences JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create categories table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    color TEXT DEFAULT '#3B82F6',
    icon TEXT DEFAULT 'folder',
    is_system_category BOOLEAN DEFAULT false,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Handle notes table - check if it exists and create/modify as needed
DO $$
BEGIN
    -- Check if notes table exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'notes') THEN
        -- Create notes table if it doesn't exist
        CREATE TABLE public.notes (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            type public.note_type DEFAULT 'text'::public.note_type,
            user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
            category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
            thumbnail_url TEXT,
            audio_url TEXT,
            has_audio BOOLEAN DEFAULT false,
            duration TEXT,
            tags TEXT[] DEFAULT ARRAY[]::TEXT[],
            is_favorite BOOLEAN DEFAULT false,
            created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
        );
    ELSE
        -- Table exists, check and add missing columns if needed
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'notes' AND column_name = 'type') THEN
            ALTER TABLE public.notes ADD COLUMN type public.note_type DEFAULT 'text'::public.note_type;
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'notes' AND column_name = 'thumbnail_url') THEN
            ALTER TABLE public.notes ADD COLUMN thumbnail_url TEXT;
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'notes' AND column_name = 'audio_url') THEN
            ALTER TABLE public.notes ADD COLUMN audio_url TEXT;
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'notes' AND column_name = 'has_audio') THEN
            ALTER TABLE public.notes ADD COLUMN has_audio BOOLEAN DEFAULT false;
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'notes' AND column_name = 'duration') THEN
            ALTER TABLE public.notes ADD COLUMN duration TEXT;
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'notes' AND column_name = 'tags') THEN
            ALTER TABLE public.notes ADD COLUMN tags TEXT[] DEFAULT ARRAY[]::TEXT[];
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'notes' AND column_name = 'is_favorite') THEN
            ALTER TABLE public.notes ADD COLUMN is_favorite BOOLEAN DEFAULT false;
        END IF;
    END IF;
END $$;

-- Create weekly_summaries table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.weekly_summaries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    week_start DATE NOT NULL,
    week_end DATE NOT NULL,
    insights TEXT NOT NULL,
    key_takeaways TEXT[] DEFAULT ARRAY[]::TEXT[],
    tasks_identified TEXT[] DEFAULT ARRAY[]::TEXT[],
    study_questions TEXT[] DEFAULT ARRAY[]::TEXT[],
    total_notes INTEGER DEFAULT 0,
    category_breakdown JSONB DEFAULT '{}'::jsonb,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    is_generated BOOLEAN DEFAULT false,
    generated_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX IF NOT EXISTS idx_categories_user_id ON public.categories(user_id);
CREATE INDEX IF NOT EXISTS idx_notes_user_id ON public.notes(user_id);
CREATE INDEX IF NOT EXISTS idx_notes_category_id ON public.notes(category_id);
CREATE INDEX IF NOT EXISTS idx_notes_created_at ON public.notes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_weekly_summaries_user_id ON public.weekly_summaries(user_id);
CREATE INDEX IF NOT EXISTS idx_weekly_summaries_week_start ON public.weekly_summaries(week_start);

-- Enable RLS if not already enabled
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'user_profiles' AND relrowsecurity = true) THEN
        ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'categories' AND relrowsecurity = true) THEN
        ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notes' AND relrowsecurity = true) THEN
        ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'weekly_summaries' AND relrowsecurity = true) THEN
        ALTER TABLE public.weekly_summaries ENABLE ROW LEVEL SECURITY;
    END IF;
END $$;

-- Helper functions for RLS policies (create or replace to handle existing functions)
CREATE OR REPLACE FUNCTION public.is_profile_owner(profile_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = profile_id AND up.id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.is_category_owner(category_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.categories c
    WHERE c.id = category_id AND c.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.is_note_owner(note_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.notes n
    WHERE n.id = note_id AND n.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.is_summary_owner(summary_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.weekly_summaries ws
    WHERE ws.id = summary_id AND ws.user_id = auth.uid()
)
$$;

-- Function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'basic'::public.user_role)
    );
    
    -- Create default categories
    INSERT INTO public.categories (name, color, icon, is_system_category, user_id)
    VALUES
        ('General', '#3B82F6', 'folder', true, NEW.id),
        ('Study', '#10B981', 'book', true, NEW.id),
        ('Work', '#F59E0B', 'work', true, NEW.id),
        ('Personal', '#EF4444', 'person', true, NEW.id);
    
    RETURN NEW;
END;
$$;

-- Create trigger for new user creation (drop and recreate to handle existing trigger)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Create triggers for updated_at (drop and recreate to handle existing triggers)
DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON public.user_profiles;
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_categories_updated_at ON public.categories;
CREATE TRIGGER update_categories_updated_at
    BEFORE UPDATE ON public.categories
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_notes_updated_at ON public.notes;
CREATE TRIGGER update_notes_updated_at
    BEFORE UPDATE ON public.notes
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_weekly_summaries_updated_at ON public.weekly_summaries;
CREATE TRIGGER update_weekly_summaries_updated_at
    BEFORE UPDATE ON public.weekly_summaries
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Create or replace RLS policies
DROP POLICY IF EXISTS "users_own_profile" ON public.user_profiles;
CREATE POLICY "users_own_profile" ON public.user_profiles FOR ALL
USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "users_own_categories" ON public.categories;
CREATE POLICY "users_own_categories" ON public.categories FOR ALL
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "users_own_notes" ON public.notes;
CREATE POLICY "users_own_notes" ON public.notes FOR ALL
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "users_own_summaries" ON public.weekly_summaries;
CREATE POLICY "users_own_summaries" ON public.weekly_summaries FOR ALL
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Function to cleanup test data
CREATE OR REPLACE FUNCTION public.cleanup_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    auth_user_ids_to_delete UUID[];
BEGIN
    -- Get auth user IDs first
    SELECT ARRAY_AGG(id) INTO auth_user_ids_to_delete
    FROM auth.users
    WHERE email LIKE '%@lectry.ai';
    
    -- Delete in dependency order (children first, then auth.users last)
    DELETE FROM public.weekly_summaries WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.notes WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.categories WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.user_profiles WHERE id = ANY(auth_user_ids_to_delete);
    
    -- Delete auth.users last (after all references are removed)
    DELETE FROM auth.users WHERE id = ANY(auth_user_ids_to_delete);
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;