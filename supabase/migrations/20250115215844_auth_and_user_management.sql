-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create custom types
CREATE TYPE public.user_role AS ENUM ('admin', 'premium', 'basic');
CREATE TYPE public.note_type AS ENUM ('text', 'audio', 'image', 'mixed');

-- Create user_profiles table (intermediary for auth.users)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'basic'::public.user_role,
    avatar_url TEXT,
    preferences JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create categories table
CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    color TEXT DEFAULT '#3B82F6',
    icon TEXT DEFAULT 'folder',
    is_system_category BOOLEAN DEFAULT false,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create notes table
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

-- Create weekly_summaries table
CREATE TABLE public.weekly_summaries (
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

-- Create indexes for performance
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_categories_user_id ON public.categories(user_id);
CREATE INDEX idx_notes_user_id ON public.notes(user_id);
CREATE INDEX idx_notes_category_id ON public.notes(category_id);
CREATE INDEX idx_notes_created_at ON public.notes(created_at DESC);
CREATE INDEX idx_weekly_summaries_user_id ON public.weekly_summaries(user_id);
CREATE INDEX idx_weekly_summaries_week_start ON public.weekly_summaries(week_start);

-- Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weekly_summaries ENABLE ROW LEVEL SECURITY;

-- Helper functions for RLS policies
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

-- Create trigger for new user creation
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

-- Create triggers for updated_at
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_categories_updated_at
    BEFORE UPDATE ON public.categories
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_notes_updated_at
    BEFORE UPDATE ON public.notes
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_weekly_summaries_updated_at
    BEFORE UPDATE ON public.weekly_summaries
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- RLS Policies
CREATE POLICY "users_own_profile" ON public.user_profiles FOR ALL
USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

CREATE POLICY "users_own_categories" ON public.categories FOR ALL
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_own_notes" ON public.notes FOR ALL
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_own_summaries" ON public.weekly_summaries FOR ALL
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Mock data for testing
DO $$
DECLARE
    user1_id UUID := gen_random_uuid();
    user2_id UUID := gen_random_uuid();
    category1_id UUID := gen_random_uuid();
    category2_id UUID := gen_random_uuid();
    note1_id UUID := gen_random_uuid();
    note2_id UUID := gen_random_uuid();
BEGIN
    -- Create auth users with complete field structure
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (user1_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'demo@lectry.ai', crypt('Demo123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Demo User", "role": "premium"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user2_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'test@lectry.ai', crypt('Test123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Test User", "role": "basic"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Sample notes data
    INSERT INTO public.notes (id, title, content, type, user_id, category_id, tags, created_at)
    VALUES
        (note1_id, 'Machine Learning Basics', 'Introduction to ML concepts: supervised learning, unsupervised learning, and reinforcement learning. Key algorithms include linear regression, decision trees, and neural networks.', 'text'::public.note_type, user1_id, category1_id, ARRAY['machine-learning', 'ai', 'study']::TEXT[], now() - interval '2 days'),
        (note2_id, 'Meeting Notes - Project Planning', 'Discussed project timeline, resource allocation, and milestone deliveries. Next steps: finalize requirements and begin development phase.', 'text'::public.note_type, user1_id, category2_id, ARRAY['meeting', 'project', 'planning']::TEXT[], now() - interval '1 day');

    -- Sample weekly summary
    INSERT INTO public.weekly_summaries (title, week_start, week_end, insights, key_takeaways, tasks_identified, study_questions, total_notes, category_breakdown, user_id, is_generated, generated_at)
    VALUES
        ('Week of Jan 13 - Jan 19', '2025-01-13', '2025-01-19', 'This week focused on foundational learning and project planning. Strong emphasis on technical concepts and practical application.', 
         ARRAY['Machine learning fundamentals are crucial for AI development', 'Project planning requires clear timelines and resource allocation', 'Regular note-taking improves retention and understanding']::TEXT[],
         ARRAY['Review linear regression algorithms', 'Finalize project requirements document', 'Schedule team meeting for next week']::TEXT[],
         ARRAY['What are the key differences between supervised and unsupervised learning?', 'How do decision trees handle categorical data?', 'What factors should be considered in project timeline estimation?']::TEXT[],
         2, '{"Study": 1, "Work": 1}'::jsonb, user1_id, true, now());

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

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