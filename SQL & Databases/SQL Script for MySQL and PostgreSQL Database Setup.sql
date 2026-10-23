-- MySQL Setup
-- ==========

-- Create database with specific character set and collation
CREATE DATABASE IF NOT EXISTS company_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS hr;
CREATE SCHEMA IF NOT EXISTS finance;
CREATE SCHEMA IF NOT EXISTS audit;

-- Switch to the database
USE company_db;

-- Create tables with improved structure
CREATE TABLE hr.departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    manager_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE hr.employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    termination_date DATE,
    department_id INT,
    salary DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE INDEX idx_email (email),
    INDEX idx_dept_id (department_id),
    INDEX idx_hire_date (hire_date),
    FOREIGN KEY (department_id) REFERENCES hr.departments(department_id),
    CONSTRAINT chk_dates CHECK (termination_date IS NULL OR termination_date >= hire_date)
);

-- Add self-referential foreign key for department manager
ALTER TABLE hr.departments 
ADD CONSTRAINT fk_manager 
FOREIGN KEY (manager_id) REFERENCES hr.employees(employee_id);

CREATE TABLE finance.expense_categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    budget_limit DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE finance.expenses (
    expense_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    expense_date DATE NOT NULL,
    category_id INT NOT NULL,
    description TEXT,
    receipt_url VARCHAR(255),
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    approved_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_employee (employee_id),
    INDEX idx_category (category_id),
    INDEX idx_status (status),
    INDEX idx_date (expense_date),
    FOREIGN KEY (employee_id) REFERENCES hr.employees(employee_id),
    FOREIGN KEY (category_id) REFERENCES finance.expense_categories(category_id),
    FOREIGN KEY (approved_by) REFERENCES hr.employees(employee_id),
    CONSTRAINT chk_amount CHECK (amount > 0)
);

-- Audit table for tracking changes
CREATE TABLE audit.change_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(100) NOT NULL,
    record_id INT NOT NULL,
    action VARCHAR(10) NOT NULL,
    changed_by INT NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_value JSON,
    new_value JSON,
    INDEX idx_table_record (table_name, record_id)
);

-- Create views
CREATE VIEW hr.active_employees_view AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    d.department_name,
    e.hire_date,
    e.salary
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.is_active = TRUE;

CREATE VIEW finance.expense_summary_view AS
SELECT 
    e.employee_id,
    CONCAT(emp.first_name, ' ', emp.last_name) as employee_name,
    ec.category_name,
    COUNT(*) as expense_count,
    SUM(e.amount) as total_amount,
    e.status
FROM finance.expenses e
JOIN hr.employees emp ON e.employee_id = emp.employee_id
JOIN finance.expense_categories ec ON e.category_id = ec.category_id
GROUP BY e.employee_id, employee_name, ec.category_name, e.status;

-- Create stored procedures
DELIMITER //

CREATE PROCEDURE hr.update_employee_salary(
    IN p_employee_id INT,
    IN p_new_salary DECIMAL(12,2),
    IN p_changed_by INT
)
BEGIN
    DECLARE old_salary DECIMAL(12,2);
    
    -- Get old salary
    SELECT salary INTO old_salary 
    FROM hr.employees 
    WHERE employee_id = p_employee_id;
    
    -- Update salary
    UPDATE hr.employees 
    SET salary = p_new_salary 
    WHERE employee_id = p_employee_id;
    
    -- Log change
    INSERT INTO audit.change_log 
    (table_name, record_id, action, changed_by, old_value, new_value)
    VALUES 
    ('employees', p_employee_id, 'UPDATE', p_changed_by,
     JSON_OBJECT('salary', old_salary),
     JSON_OBJECT('salary', p_new_salary));
END //

CREATE PROCEDURE finance.approve_expense(
    IN p_expense_id INT,
    IN p_approver_id INT
)
BEGIN
    UPDATE finance.expenses 
    SET status = 'approved',
        approved_by = p_approver_id,
        updated_at = CURRENT_TIMESTAMP
    WHERE expense_id = p_expense_id
    AND status = 'pending';
END //

DELIMITER ;

-- Create users with stronger password requirements
CREATE USER IF NOT EXISTS 'hr_admin'@'localhost' IDENTIFIED BY 'Hr@dm1n2024!Secure' PASSWORD EXPIRE INTERVAL 90 DAY;
CREATE USER IF NOT EXISTS 'hr_user'@'localhost' IDENTIFIED BY 'HrUs3r2024!Secure' PASSWORD EXPIRE INTERVAL 90 DAY;
CREATE USER IF NOT EXISTS 'finance_admin'@'localhost' IDENTIFIED BY 'F1n@dm1n2024!Secure' PASSWORD EXPIRE INTERVAL 90 DAY;
CREATE USER IF NOT EXISTS 'finance_user'@'localhost' IDENTIFIED BY 'F1nUs3r2024!Secure' PASSWORD EXPIRE INTERVAL 90 DAY;
CREATE USER IF NOT EXISTS 'readonly_user'@'localhost' IDENTIFIED BY 'R3@d0nly2024!Secure' PASSWORD EXPIRE INTERVAL 90 DAY;
CREATE USER IF NOT EXISTS 'backup_user'@'localhost' IDENTIFIED BY 'B@ckup2024!Secure' PASSWORD EXPIRE INTERVAL 90 DAY;

-- Grant privileges with more granular control
-- HR Admin
GRANT ALL PRIVILEGES ON hr.* TO 'hr_admin'@'localhost';
GRANT SELECT ON finance.expense_summary_view TO 'hr_admin'@'localhost';
GRANT EXECUTE ON PROCEDURE hr.update_employee_salary TO 'hr_admin'@'localhost';

-- HR User
GRANT SELECT, INSERT, UPDATE ON hr.* TO 'hr_user'@'localhost';
GRANT SELECT ON hr.active_employees_view TO 'hr_user'@'localhost';

-- Finance Admin
GRANT ALL PRIVILEGES ON finance.* TO 'finance_admin'@'localhost';
GRANT SELECT ON hr.active_employees_view TO 'finance_admin'@'localhost';
GRANT EXECUTE ON PROCEDURE finance.approve_expense TO 'finance_admin'@'localhost';

-- Finance User
GRANT SELECT, INSERT, UPDATE ON finance.* TO 'finance_user'@'localhost';
GRANT SELECT ON finance.expense_summary_view TO 'finance_user'@'localhost';

-- Read-only user
GRANT SELECT ON hr.active_employees_view TO 'readonly_user'@'localhost';
GRANT SELECT ON finance.expense_summary_view TO 'readonly_user'@'localhost';

-- Backup user
GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER ON *.* TO 'backup_user'@'localhost';
GRANT REPLICATION CLIENT ON *.* TO 'backup_user'@'localhost';

FLUSH PRIVILEGES;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- PostgreSQL Setup
-- ===============

-- Create database
CREATE DATABASE company_db
    WITH 
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8';

-- Create schemas
CREATE SCHEMA IF NOT EXISTS hr;
CREATE SCHEMA IF NOT EXISTS finance;
CREATE SCHEMA IF NOT EXISTS audit;

-- Create custom types
CREATE TYPE employee_status AS ENUM ('active', 'inactive', 'terminated');
CREATE TYPE expense_status AS ENUM ('pending', 'approved', 'rejected');

-- Create tables with improved structure
CREATE TABLE hr.departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    manager_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE hr.employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    termination_date DATE,
    department_id INTEGER,
    salary NUMERIC(12,2),
    status employee_status DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_email UNIQUE (email),
    CONSTRAINT fk_department FOREIGN KEY (department_id) 
        REFERENCES hr.departments(department_id),
    CONSTRAINT chk_dates CHECK (termination_date IS NULL OR termination_date >= hire_date)
);

-- Add self-referential foreign key for department manager
ALTER TABLE hr.departments 
ADD CONSTRAINT fk_manager 
FOREIGN KEY (manager_id) REFERENCES hr.employees(employee_id);

CREATE TABLE finance.expense_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    budget_limit NUMERIC(12,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE finance.expenses (
    expense_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    expense_date DATE NOT NULL,
    category_id INTEGER NOT NULL,
    description TEXT,
    receipt_url VARCHAR(255),
    status expense_status DEFAULT 'pending',
    approved_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employee FOREIGN KEY (employee_id) 
        REFERENCES hr.employees(employee_id),
    CONSTRAINT fk_category FOREIGN KEY (category_id) 
        REFERENCES finance.expense_categories(category_id),
    CONSTRAINT fk_approver FOREIGN KEY (approved_by) 
        REFERENCES hr.employees(employee_id),
    CONSTRAINT chk_amount CHECK (amount > 0)
);

-- Create audit table
CREATE TABLE audit.change_log (
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id INTEGER NOT NULL,
    action VARCHAR(10) NOT NULL,
    changed_by INTEGER NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_value JSONB,
    new_value JSONB
);

-- Create indexes
CREATE INDEX idx_emp_email ON hr.employees(email);
CREATE INDEX idx_emp_dept ON hr.employees(department_id);
CREATE INDEX idx_emp_status ON hr.employees(status);
CREATE INDEX idx_exp_employee ON finance.expenses(employee_id);
CREATE INDEX idx_exp_category ON finance.expenses(category_id);
CREATE INDEX idx_exp_status ON finance.expenses(status);
CREATE INDEX idx_exp_date ON finance.expenses(expense_date);
CREATE INDEX idx_audit_table_record ON audit.change_log(table_name, record_id);

-- Create views
CREATE VIEW hr.active_employees_view AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    d.department_name,
    e.hire_date,
    e.salary
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.status = 'active';

CREATE VIEW finance.expense_summary_view AS
SELECT 
    e.employee_id,
    CONCAT(emp.first_name, ' ', emp.last_name) as employee_name,
    ec.category_name,
    COUNT(*) as expense_count,
    SUM(e.amount) as total_amount,
    e.status
FROM finance.expenses e
JOIN hr.employees emp ON e.employee_id = emp.employee_id
JOIN finance.expense_categories ec ON e.category_id = ec.category_id
GROUP BY e.employee_id, employee_name, ec.category_name, e.status;

-- Create functions and triggers
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON hr.employees
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON finance.expenses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Create functions
CREATE OR REPLACE FUNCTION hr.update_employee_salary(
    p_employee_id INTEGER,
    p_new_salary NUMERIC,
    p_changed_by INTEGER
) RETURNS VOID AS $$
DECLARE
    old_salary NUMERIC;
BEGIN
    -- Get old salary
    SELECT salary INTO old_salary 
    FROM hr.employees 
    WHERE employee_id = p_employee_id;
    
    -- Update salary
    UPDATE hr.employees 
    SET salary = p_new_salary 
    WHERE employee_id = p_employee_id;
    
    -- Log change
    INSERT INTO audit.change_log 
    (table_name, record_id, action, changed_by, old_value, new_value)
    VALUES 
    ('employees', p_employee_id, 'UPDATE', p_changed_by,
     jsonb_build_object('salary', old_salary),
     jsonb_build_object('salary', p_new_salary));
END;
$$ LANGUAGE plpgsql;

-- Create roles with stronger passwords
CREATE ROLE hr_admin WITH LOGIN PASSWORD 'Hr@dm1n2024!Secure';
CREATE ROLE hr_user WITH LOGIN PASSWORD 'HrUs3r2024!Secure';
CREATE ROLE finance_admin WITH LOGIN PASSWORD 'F1n@dm1n2024!Secure';
CREATE ROLE finance_user WITH LOGIN PASSWORD 'F1nUs3r2024!Secure';
CREATE ROLE readonly_user WITH LOGIN PASSWORD 'R3@d0nly2024!Secure';
CREATE ROLE backup_user WITH LOGIN PASSWORD 'B@ckup2024!Secure';

-- Grant privileges
-- HR Admin
GRANT USAGE ON SCHEMA hr TO hr_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA hr TO hr_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA hr TO hr_admin;

-- Grant privileges with more granular control
-- HR Admin
GRANT USAGE ON SCHEMA hr, audit TO hr_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA hr TO hr_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA hr TO hr_admin;
GRANT SELECT ON finance.expense_summary_view TO hr_admin;
GRANT EXECUTE ON FUNCTION hr.update_employee_salary TO hr_admin;

-- HR User
GRANT USAGE ON SCHEMA hr TO hr_user;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA hr TO hr_user;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA hr TO hr_user;
GRANT SELECT ON hr.active_employees_view TO hr_user;

-- Finance Admin
GRANT USAGE ON SCHEMA finance, audit TO finance_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA finance TO finance_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA finance TO finance_admin;
GRANT SELECT ON hr.active_employees_view TO finance_admin;

-- Finance User
GRANT USAGE ON SCHEMA finance TO finance_user;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA finance TO finance_user;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA finance TO finance_user;
GRANT SELECT ON finance.expense_summary_view TO finance_user;

-- Read-only user
GRANT USAGE ON SCHEMA hr, finance TO readonly_user;
GRANT SELECT ON ALL TABLES IN SCHEMA hr, finance TO readonly_user;
GRANT SELECT ON hr.active_employees_view TO readonly_user;
GRANT SELECT ON finance.expense_summary_view TO readonly_user;

-- Backup user
GRANT USAGE ON ALL SCHEMAS TO backup_user;
GRANT SELECT ON ALL TABLES IN SCHEMA hr, finance, audit TO backup_user;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA hr, finance, audit TO backup_user;

-- Alter default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA hr 
    GRANT SELECT, INSERT, UPDATE ON TABLES TO hr_user;
    
ALTER DEFAULT PRIVILEGES IN SCHEMA finance 
    GRANT SELECT, INSERT, UPDATE ON TABLES TO finance_user;
    
ALTER DEFAULT PRIVILEGES IN SCHEMA hr, finance 
    GRANT SELECT ON TABLES TO readonly_user;

-- Create additional security policies using Row Level Security (RLS)
ALTER TABLE hr.employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE finance.expenses ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY employee_access_policy ON hr.employees
    FOR ALL
    TO hr_user
    USING (department_id IN (
        SELECT department_id 
        FROM hr.employees 
        WHERE email = current_user
    ));

CREATE POLICY expense_access_policy ON finance.expenses
    FOR ALL
    TO finance_user
    USING (
        (status = 'pending')
        OR 
        (employee_id IN (
            SELECT employee_id 
            FROM hr.employees 
            WHERE department_id IN (
                SELECT department_id 
                FROM hr.employees 
                WHERE email = current_user
            )
        ))
    );

-- Create audit triggers
CREATE OR REPLACE FUNCTION audit.log_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit.change_log (
            table_name, 
            record_id, 
            action, 
            changed_by,
            new_value
        ) VALUES (
            TG_TABLE_NAME,
            NEW.employee_id,
            'INSERT',
            current_user,
            to_jsonb(NEW)
        );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit.change_log (
            table_name, 
            record_id, 
            action, 
            changed_by,
            old_value,
            new_value
        ) VALUES (
            TG_TABLE_NAME,
            NEW.employee_id,
            'UPDATE',
            current_user,
            to_jsonb(OLD),
            to_jsonb(NEW)
        );
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit.change_log (
            table_name, 
            record_id, 
            action, 
            changed_by,
            old_value
        ) VALUES (
            TG_TABLE_NAME,
            OLD.employee_id,
            'DELETE',
            current_user,
            to_jsonb(OLD)
        );
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Apply audit triggers to tables
CREATE TRIGGER employees_audit
    AFTER INSERT OR UPDATE OR DELETE ON hr.employees
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();

CREATE TRIGGER expenses_audit
    AFTER INSERT OR UPDATE OR DELETE ON finance.expenses
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();

-- Create maintenance functions
CREATE OR REPLACE FUNCTION maintenance.cleanup_audit_logs(days_to_keep INTEGER)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM audit.change_log 
    WHERE changed_at < CURRENT_TIMESTAMP - (days_to_keep || ' days')::INTERVAL;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Create database configuration
ALTER DATABASE company_db SET timezone TO 'UTC';
ALTER DATABASE company_db SET statement_timeout TO '30s';
ALTER DATABASE company_db SET idle_in_transaction_session_timeout TO '1h';

-- Create connection limits for roles
ALTER ROLE hr_admin CONNECTION LIMIT 5;
ALTER ROLE finance_admin CONNECTION LIMIT 5;
ALTER ROLE hr_user CONNECTION LIMIT 20;
ALTER ROLE finance_user CONNECTION LIMIT 20;
ALTER ROLE readonly_user CONNECTION LIMIT 50;

-- Optional: Create materialized view for heavy queries
CREATE MATERIALIZED VIEW finance.monthly_expense_summary AS
SELECT 
    date_trunc('month', e.expense_date) as month,
    d.department_name,
    ec.category_name,
    COUNT(*) as expense_count,
    SUM(e.amount) as total_amount
FROM finance.expenses e
JOIN hr.employees emp ON e.employee_id = emp.employee_id
JOIN hr.departments d ON emp.department_id = d.department_id
JOIN finance.expense_categories ec ON e.category_id = ec.category_id
GROUP BY 
    date_trunc('month', e.expense_date),
    d.department_name,
    ec.category_name;

-- Create index on materialized view
CREATE INDEX idx_monthly_expense_dept 
ON finance.monthly_expense_summary(department_name, month);

-- Grant access to materialized view
GRANT SELECT ON finance.monthly_expense_summary TO finance_admin, finance_user, readonly_user;

-- Create refresh function for materialized view
CREATE OR REPLACE FUNCTION finance.refresh_expense_summary()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY finance.monthly_expense_summary;
END;
$$ LANGUAGE plpgsql;

-- Create maintenance schema and functions
CREATE SCHEMA maintenance;

-- Create index maintenance function
CREATE OR REPLACE FUNCTION maintenance.reindex_tables()
RETURNS void AS $$
BEGIN
    REINDEX TABLE hr.employees;
    REINDEX TABLE finance.expenses;
    REINDEX TABLE audit.change_log;
    REINDEX TABLE finance.monthly_expense_summary;
END;
$$ LANGUAGE plpgsql;

-- Create vacuum analyze function
CREATE OR REPLACE FUNCTION maintenance.vacuum_analyze_tables()
RETURNS void AS $$
BEGIN
    VACUUM ANALYZE hr.employees;
    VACUUM ANALYZE finance.expenses;
    VACUUM ANALYZE audit.change_log;
END;
$$ LANGUAGE plpgsql;

COMMENT ON DATABASE company_db IS 'Company main database for HR and Finance operations';
COMMENT ON SCHEMA hr IS 'Schema for HR-related tables and functions';
COMMENT ON SCHEMA finance IS 'Schema for Finance-related tables and functions';
COMMENT ON SCHEMA audit IS 'Schema for audit logging and tracking';
COMMENT ON SCHEMA maintenance IS 'Schema for maintenance operations';

-- End of PostgreSQL Setup