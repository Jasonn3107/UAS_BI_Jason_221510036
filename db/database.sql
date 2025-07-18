
-- Created for ContractRec System

-- Drop database jika ada (untuk fresh installation)
DROP DATABASE IF EXISTS contract_rec_db;
CREATE DATABASE contract_rec_db;
USE contract_rec_db;

-- Tabel Users (untuk autentikasi)
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'hr', 'manager') NOT NULL,
    division_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive') DEFAULT 'active'
);

-- Tabel Divisions
CREATE TABLE divisions (
    division_id INT PRIMARY KEY AUTO_INCREMENT,
    division_name VARCHAR(100) NOT NULL,
    description TEXT,
    manager_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Employees (disesuaikan dengan implementasi aktual)
CREATE TABLE employees (
    eid INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,  -- Sesuai dengan implementasi aktual
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    birth_date DATE,
    address TEXT,
    status ENUM('active', 'resigned', 'terminated', 'probation') DEFAULT 'active',  -- Ditambah probation
    join_date DATE NOT NULL,
    resign_date DATE NULL,
    resign_reason TEXT NULL,  -- Kolom baru yang ditambahkan
    education_level ENUM('D3', 'S1', 'S2', 'S3') NOT NULL,
    major VARCHAR(100) NOT NULL,
    last_education_place VARCHAR(200),
    designation VARCHAR(100),
    role VARCHAR(100) NOT NULL,
    division_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (division_id) REFERENCES divisions(division_id)
);

-- Tabel Contracts (disesuaikan dengan implementasi aktual)
CREATE TABLE contracts (
    contract_id INT PRIMARY KEY AUTO_INCREMENT,
    eid INT NOT NULL,  -- Sesuai dengan implementasi aktual (bukan employee_id)
    type ENUM('probation', '1', '2', '3', 'permanent') NOT NULL,  -- Sesuai dengan implementasi aktual
    start_date DATE NOT NULL,
    end_date DATE,
    status ENUM('active', 'completed', 'terminated', 'extended') DEFAULT 'active',
    review_date DATE,
    permanent_date DATE NULL,
    salary DECIMAL(15,2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (eid) REFERENCES employees(eid) ON DELETE CASCADE
);

-- Tabel Recommendations
CREATE TABLE recommendations (
    recommendation_id INT PRIMARY KEY AUTO_INCREMENT,
    eid INT NOT NULL,
    recommended_by INT NOT NULL,
    recommendation_type ENUM('extend', 'permanent', 'terminate', 'review', 'kontrak1', 'kontrak2', 'kontrak3') NOT NULL,  -- Ditambah tipe kontrak spesifik
    recommended_duration INT NULL, -- dalam bulan, atau 'permanent' untuk permanent
    reason TEXT,
    system_recommendation TEXT,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (eid) REFERENCES employees(eid) ON DELETE CASCADE,
    FOREIGN KEY (recommended_by) REFERENCES users(user_id)
);

-- Tabel Contract History untuk tracking perubahan
CREATE TABLE contract_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    contract_id INT NOT NULL,
    action ENUM('created', 'extended', 'terminated', 'completed') NOT NULL,
    old_end_date DATE,
    new_end_date DATE,
    reason TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (contract_id) REFERENCES contracts(contract_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(user_id)
);

-- Insert HANYA akun admin default
INSERT INTO users (username, email, password, role) VALUES 
('admin', 'admin@contractrec.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');

-- Add foreign key constraints
ALTER TABLE users ADD FOREIGN KEY (division_id) REFERENCES divisions(division_id);
ALTER TABLE divisions ADD FOREIGN KEY (manager_id) REFERENCES users(user_id);

-- Indexes for better performance
CREATE INDEX idx_employees_status ON employees(status);
CREATE INDEX idx_employees_division ON employees(division_id);
CREATE INDEX idx_employees_join_date ON employees(join_date);
CREATE INDEX idx_employees_resign_date ON employees(resign_date);
CREATE INDEX idx_contracts_eid ON contracts(eid);
CREATE INDEX idx_contracts_type ON contracts(type);
CREATE INDEX idx_contracts_status ON contracts(status);
CREATE INDEX idx_contracts_start_date ON contracts(start_date);
CREATE INDEX idx_contracts_end_date ON contracts(end_date);
CREATE INDEX idx_recommendations_eid ON recommendations(eid);
CREATE INDEX idx_recommendations_status ON recommendations(status);
CREATE INDEX idx_recommendations_type ON recommendations(recommendation_type);
CREATE INDEX idx_recommendations_created_at ON recommendations(created_at);

-- Views untuk kemudahan query
CREATE VIEW active_employees_with_contracts AS
SELECT 
    e.eid,
    e.name,
    e.email,
    e.role,
    e.join_date,
    e.status as employee_status,
    e.division_id,
    d.division_name,
    c.contract_id,
    c.type as contract_type,
    c.start_date as contract_start,
    c.end_date as contract_end,
    c.status as contract_status,
    DATEDIFF(CURDATE(), e.join_date) as days_employed,
    CASE 
        WHEN c.end_date IS NULL THEN NULL
        ELSE DATEDIFF(c.end_date, CURDATE())
    END as days_to_contract_end
FROM employees e
LEFT JOIN divisions d ON e.division_id = d.division_id
LEFT JOIN contracts c ON e.eid = c.eid AND c.status = 'active'
WHERE e.status IN ('active', 'probation');

-- View untuk pending recommendations
CREATE VIEW pending_recommendations_view AS
SELECT 
    r.recommendation_id,
    r.eid,
    e.name as employee_name,
    e.email as employee_email,
    e.role as employee_role,
    d.division_name,
    r.recommendation_type,
    r.recommended_duration,
    r.reason,
    r.system_recommendation,
    r.status,
    u.username as recommended_by_name,
    c.type as current_contract_type,
    c.end_date as current_contract_end,
    r.created_at,
    r.updated_at
FROM recommendations r
JOIN employees e ON r.eid = e.eid
LEFT JOIN divisions d ON e.division_id = d.division_id
JOIN users u ON r.recommended_by = u.user_id
LEFT JOIN contracts c ON e.eid = c.eid AND c.status = 'active'
WHERE r.status = 'pending';

-- Trigger untuk otomatis update contract history
DELIMITER //
CREATE TRIGGER contract_history_trigger 
AFTER UPDATE ON contracts
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status OR OLD.end_date != NEW.end_date THEN
        INSERT INTO contract_history (
            contract_id, 
            action, 
            old_end_date, 
            new_end_date, 
            reason, 
            created_at
        ) VALUES (
            NEW.contract_id,
            CASE 
                WHEN NEW.status = 'extended' THEN 'extended'
                WHEN NEW.status = 'terminated' THEN 'terminated'
                WHEN NEW.status = 'completed' THEN 'completed'
                ELSE 'created'
            END,
            OLD.end_date,
            NEW.end_date,
            CONCAT('Status changed from ', OLD.status, ' to ', NEW.status),
            NOW()
        );
    END IF;
END//
DELIMITER ;

-- Informasi instalasi
SELECT 'Database schema fresh berhasil dibuat!' as status;
SELECT 'Login dengan: username=admin, password=password' as login_info; 