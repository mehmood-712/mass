
-- MASS Migration 002
-- Preserve old students table and create core tables

-- 1. Preserve existing legacy students table
ALTER TABLE public.students
RENAME TO students_legacy;


-- 2. Create classes table
CREATE TABLE public.classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_name TEXT NOT NULL,
    section TEXT NOT NULL,
    academic_year TEXT NOT NULL,
    teacher_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- 3. Create new students table
CREATE TABLE public.students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    full_name TEXT NOT NULL,
    reference_photo_path TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    is_active BOOLEAN NOT NULL DEFAULT true
);


-- 4. Create enrollments table
CREATE TABLE public.enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL,
    class_id UUID NOT NULL,
    academic_year TEXT NOT NULL,
    roll_number TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- 5. Create attendance table
CREATE TABLE public.attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL,
    enrollment_id UUID NOT NULL,
    attendance_date DATE NOT NULL,
    status TEXT,
    marked_by UUID NOT NULL,
    marked_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    approval_status TEXT NOT NULL DEFAULT 'approved',
    verification_method TEXT NOT NULL DEFAULT 'teacher',
    attendance_photo_path TEXT,
    reviewed_by UUID,
    reviewed_at TIMESTAMPTZ
);
