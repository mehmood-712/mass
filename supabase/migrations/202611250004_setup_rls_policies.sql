
-- MASS Migration 004
-- Setup Row Level Security, Policies and Signup Trigger


-- =====================================================
-- 1. HELPER FUNCTIONS
-- =====================================================

-- Check whether current user is a teacher
CREATE OR REPLACE FUNCTION public.is_teacher()
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.profiles p
        WHERE p.id = (SELECT auth.uid())
          AND p.role = 'teacher'
    );
$$;


-- Check whether current user owns a student record
CREATE OR REPLACE FUNCTION public.is_student_record_owner(
    _student_id UUID
)
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.students s
        WHERE s.id = _student_id
          AND s.user_id = (SELECT auth.uid())
    );
$$;


-- Check whether current student is enrolled in a class
CREATE OR REPLACE FUNCTION public.is_student_in_class(
    _class_id UUID
)
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.enrollments e
        JOIN public.students s ON s.id = e.student_id
        WHERE e.class_id = _class_id
          AND s.user_id = (SELECT auth.uid())
    );
$$;


-- Allow authenticated users to execute helper functions
GRANT EXECUTE ON FUNCTION public.is_teacher()
TO authenticated;

GRANT EXECUTE ON FUNCTION public.is_student_record_owner(UUID)
TO authenticated;

GRANT EXECUTE ON FUNCTION public.is_student_in_class(UUID)
TO authenticated;


-- =====================================================
-- 2. LEGACY TABLE SECURITY
-- =====================================================

-- Keep the old table inaccessible to application users
ALTER TABLE public.students_legacy ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own students"
ON public.students_legacy;

DROP POLICY IF EXISTS "Users can insert own students"
ON public.students_legacy;

DROP POLICY IF EXISTS "Users can update own students"
ON public.students_legacy;

DROP POLICY IF EXISTS "Users can delete own students"
ON public.students_legacy;

REVOKE ALL PRIVILEGES
ON TABLE public.students_legacy
FROM anon, authenticated;


-- =====================================================
-- 3. ENABLE ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;


-- =====================================================
-- 4. PROFILES POLICIES
-- =====================================================

CREATE POLICY "Users can view own profile"
ON public.profiles
FOR SELECT
TO authenticated
USING (
    id = (SELECT auth.uid())
);


CREATE POLICY "Users can update own profile"
ON public.profiles
FOR UPDATE
TO authenticated
USING (
    id = (SELECT auth.uid())
)
WITH CHECK (
    id = (SELECT auth.uid())
);


-- =====================================================
-- 5. CLASSES POLICIES
-- All teachers can access all classes.
-- Students can view their enrolled classes.
-- =====================================================

CREATE POLICY "Users can view permitted classes"
ON public.classes
FOR SELECT
TO authenticated
USING (
    public.is_teacher()
    OR public.is_student_in_class(id)
);


CREATE POLICY "Teachers can create classes"
ON public.classes
FOR INSERT
TO authenticated
WITH CHECK (
    public.is_teacher()
    AND teacher_id = (SELECT auth.uid())
);


CREATE POLICY "Teachers can update classes"
ON public.classes
FOR UPDATE
TO authenticated
USING (
    public.is_teacher()
)
WITH CHECK (
    public.is_teacher()
);


-- =====================================================
-- 6. STUDENTS POLICIES
-- All teachers can manage all student records.
-- Students can view only their own record.
-- =====================================================

CREATE POLICY "Users can view permitted students"
ON public.students
FOR SELECT
TO authenticated
USING (
    public.is_teacher()
    OR user_id = (SELECT auth.uid())
);


CREATE POLICY "Teachers can insert students"
ON public.students
FOR INSERT
TO authenticated
WITH CHECK (
    public.is_teacher()
);


CREATE POLICY "Teachers can update students"
ON public.students
FOR UPDATE
TO authenticated
USING (
    public.is_teacher()
)
WITH CHECK (
    public.is_teacher()
);


-- =====================================================
-- 7. ENROLLMENTS POLICIES
-- All teachers can manage all enrollments.
-- Students can view their own enrollments.
-- =====================================================

CREATE POLICY "Users can view permitted enrollments"
ON public.enrollments
FOR SELECT
TO authenticated
USING (
    public.is_teacher()
    OR public.is_student_record_owner(student_id)
);


CREATE POLICY "Teachers can insert enrollments"
ON public.enrollments
FOR INSERT
TO authenticated
WITH CHECK (
    public.is_teacher()
);


CREATE POLICY "Teachers can update enrollments"
ON public.enrollments
FOR UPDATE
TO authenticated
USING (
    public.is_teacher()
)
WITH CHECK (
    public.is_teacher()
);


-- =====================================================
-- 8. ATTENDANCE POLICIES
-- All teachers can access all attendance records.
-- Students can view only their own attendance.
-- =====================================================

CREATE POLICY "Users can view permitted attendance"
ON public.attendance
FOR SELECT
TO authenticated
USING (
    public.is_teacher()
    OR public.is_student_record_owner(student_id)
);


-- Teachers can directly mark approved attendance.
CREATE POLICY "Teachers can insert attendance"
ON public.attendance
FOR INSERT
TO authenticated
WITH CHECK (
    public.is_teacher()
    AND marked_by = (SELECT auth.uid())
    AND approval_status = 'approved'
    AND status IS NOT NULL
    AND verification_method = 'teacher'
);


-- Students can submit their own pending attendance request.
CREATE POLICY "Students can submit attendance requests"
ON public.attendance
FOR INSERT
TO authenticated
WITH CHECK (
    public.is_student_record_owner(student_id)
    AND marked_by = (SELECT auth.uid())
    AND approval_status = 'pending'
    AND status IS NULL
    AND verification_method IN (
        'photo',
        'device_biometric'
    )
    AND reviewed_by IS NULL
    AND reviewed_at IS NULL
);


-- Teachers can approve or reject any attendance request.
CREATE POLICY "Teachers can review attendance"
ON public.attendance
FOR UPDATE
TO authenticated
USING (
    public.is_teacher()
)
WITH CHECK (
    public.is_teacher()
    AND reviewed_by = (SELECT auth.uid())
    AND reviewed_at IS NOT NULL
);


-- Students can resubmit their own rejected requests.
-- Old teacher review information must be cleared.
CREATE POLICY "Students can resubmit rejected requests"
ON public.attendance
FOR UPDATE
TO authenticated
USING (
    public.is_student_record_owner(student_id)
    AND approval_status = 'rejected'
)
WITH CHECK (
    public.is_student_record_owner(student_id)
    AND approval_status = 'pending'
    AND status IS NULL
    AND reviewed_by IS NULL
    AND reviewed_at IS NULL
);


-- =====================================================
-- 9. TABLE PERMISSIONS
-- =====================================================

-- Profiles
GRANT SELECT ON public.profiles TO authenticated;

-- Users can update only their full name.
-- They cannot change their role or account ID.
GRANT UPDATE (full_name)
ON public.profiles TO authenticated;


-- Classes
GRANT SELECT, INSERT
ON public.classes TO authenticated;

GRANT UPDATE (class_name, section, academic_year)
ON public.classes TO authenticated;


-- Students
GRANT SELECT, INSERT, UPDATE
ON public.students TO authenticated;


-- Enrollments
GRANT SELECT, INSERT, UPDATE
ON public.enrollments TO authenticated;


-- Attendance
GRANT SELECT, INSERT
ON public.attendance TO authenticated;

GRANT UPDATE (
    status,
    approval_status,
    verification_method,
    attendance_photo_path,
    reviewed_by,
    reviewed_at
)
ON public.attendance TO authenticated;


-- =====================================================
-- 10. SIGNUP TRIGGER FUNCTION
-- Every new signup receives student role by default.
-- Teacher role must be assigned through trusted access.
-- =====================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
    INSERT INTO public.profiles (
        id,
        full_name,
        email,
        role
    )
    VALUES (
        NEW.id,
        COALESCE(
            NULLIF(BTRIM(NEW.raw_user_meta_data ->> 'full_name'), ''),
            'New User'
        ),
        NEW.email,
        'student'
    )
    ON CONFLICT (id) DO NOTHING;

    RETURN NEW;
END;
$$;


-- =====================================================
-- 11. CREATE AUTH SIGNUP TRIGGER
-- =====================================================

DROP TRIGGER IF EXISTS on_auth_user_created
ON auth.users;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();


-- END OF MASS MIGRATION 004
