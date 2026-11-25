
-- MASS Migration 003
-- Add Foreign Keys, Unique Constraints, Checks and Indexes


-- ==========================================
-- 1. CLASSES TABLE CONSTRAINTS
-- ==========================================

ALTER TABLE public.classes
ADD CONSTRAINT classes_teacher_id_fkey
FOREIGN KEY (teacher_id)
REFERENCES public.profiles(id)
ON DELETE RESTRICT;

ALTER TABLE public.classes
ADD CONSTRAINT classes_name_section_year_unique
UNIQUE (class_name, section, academic_year);

-- Required for enrollment composite foreign key
ALTER TABLE public.classes
ADD CONSTRAINT classes_id_academic_year_unique
UNIQUE (id, academic_year);


-- ==========================================
-- 2. STUDENTS TABLE CONSTRAINTS
-- ==========================================

ALTER TABLE public.students
ADD CONSTRAINT students_user_id_unique
UNIQUE (user_id);

ALTER TABLE public.students
ADD CONSTRAINT students_user_id_fkey
FOREIGN KEY (user_id)
REFERENCES public.profiles(id)
ON DELETE SET NULL;


-- ==========================================
-- 3. ENROLLMENTS TABLE CONSTRAINTS
-- ==========================================

ALTER TABLE public.enrollments
ADD CONSTRAINT enrollments_student_id_fkey
FOREIGN KEY (student_id)
REFERENCES public.students(id)
ON DELETE RESTRICT;

-- Class and academic year must match
ALTER TABLE public.enrollments
ADD CONSTRAINT enrollments_class_year_fkey
FOREIGN KEY (class_id, academic_year)
REFERENCES public.classes(id, academic_year)
ON DELETE RESTRICT;

-- One enrollment per student per academic year
ALTER TABLE public.enrollments
ADD CONSTRAINT enrollments_student_year_unique
UNIQUE (student_id, academic_year);

-- Roll number must be unique within a class
ALTER TABLE public.enrollments
ADD CONSTRAINT enrollments_roll_class_unique
UNIQUE (roll_number, class_id);

-- Required for attendance composite foreign key
ALTER TABLE public.enrollments
ADD CONSTRAINT enrollments_id_student_unique
UNIQUE (id, student_id);


-- ==========================================
-- 4. ATTENDANCE TABLE CONSTRAINTS
-- ==========================================

-- Enrollment and student identity must match
ALTER TABLE public.attendance
ADD CONSTRAINT attendance_enrollment_student_fkey
FOREIGN KEY (enrollment_id, student_id)
REFERENCES public.enrollments(id, student_id)
ON DELETE RESTRICT;

-- Who submitted or marked the attendance
ALTER TABLE public.attendance
ADD CONSTRAINT attendance_marked_by_fkey
FOREIGN KEY (marked_by)
REFERENCES public.profiles(id)
ON DELETE RESTRICT;

-- Who reviewed the student request
ALTER TABLE public.attendance
ADD CONSTRAINT attendance_reviewed_by_fkey
FOREIGN KEY (reviewed_by)
REFERENCES public.profiles(id)
ON DELETE RESTRICT;

-- One attendance record per enrollment per date
ALTER TABLE public.attendance
ADD CONSTRAINT attendance_enrollment_date_unique
UNIQUE (enrollment_id, attendance_date);

-- Allowed final attendance statuses
ALTER TABLE public.attendance
ADD CONSTRAINT attendance_status_check
CHECK (status IN ('present', 'absent', 'leave'));

-- Allowed approval statuses
ALTER TABLE public.attendance
ADD CONSTRAINT attendance_approval_status_check
CHECK (approval_status IN ('pending', 'approved', 'rejected'));

-- Allowed verification methods
ALTER TABLE public.attendance
ADD CONSTRAINT attendance_verification_method_check
CHECK (
    verification_method IN (
        'teacher',
        'photo',
        'device_biometric'
    )
);

-- Attendance status must match approval status
ALTER TABLE public.attendance
ADD CONSTRAINT attendance_approval_consistency_check
CHECK (
    (
        approval_status = 'approved'
        AND status IS NOT NULL
    )
    OR
    (
        approval_status IN ('pending', 'rejected')
        AND status IS NULL
    )
);


-- ==========================================
-- 5. INDEXES
-- ==========================================

CREATE INDEX idx_classes_teacher_id
ON public.classes(teacher_id);

CREATE INDEX idx_enrollments_class_id
ON public.enrollments(class_id);

CREATE INDEX idx_attendance_student_id
ON public.attendance(student_id);

CREATE INDEX idx_attendance_marked_by
ON public.attendance(marked_by);

-- Helps teacher find pending requests
CREATE INDEX idx_attendance_approval_date
ON public.attendance(approval_status, attendance_date);

-- END OF MASS MIGRATION 003
