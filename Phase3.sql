-- EMPLOYEE
CREATE TABLE Employee (
    EmployeeID VARCHAR(10) PRIMARY KEY, -- Format: EMP00000
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50),
    LastName VARCHAR(50) NOT NULL,
    PhoneNumber VARCHAR(15) UNIQUE NOT NULL,
    Email VARCHAR(100) NOT NULL CHECK (Email LIKE '%@procare.com'),
    Address TEXT,
    Salary DECIMAL(10, 2) NOT NULL CHECK (Salary > 0),
    JobTitle VARCHAR(50) NOT NULL
);
COMMENT ON COLUMN Employee.Salary IS 'Employee salary in USD';
CREATE UNIQUE INDEX unique_email_employee ON Employee (LOWER(Email));

-- CLIENT
CREATE TABLE Client (
    ClientID VARCHAR(10) PRIMARY KEY, --CLI00000
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50),
    LastName VARCHAR(50) NOT NULL,
    DOB DATE NOT NULL CHECK (DOB < CURRENT_DATE),
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
    Email VARCHAR(100) NOT NULL CHECK (Email ~ '^[A-Za-z0-9._]+@[A-Za-z0-9.]+\.[A-Za-z]{2,}$')
);
CREATE UNIQUE INDEX unique_email_client ON Client (LOWER(Email));

-- CLIENT PHONE
CREATE TABLE ClientPhoneNumber (
    ClientID VARCHAR(10), 
	CONSTRAINT fk_ClientID FOREIGN KEY (ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    PhoneNumber VARCHAR(15) NOT NULL, -- not unique since can have 2 clients living in same house = same landline
    CONSTRAINT client_phone_id PRIMARY KEY (ClientID, PhoneNumber)
);

-- CLIENT ADDRESS
CREATE TABLE ClientAddress (
    ClientID VARCHAR(10),
	CONSTRAINT fk_ClientID FOREIGN KEY(ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    Address TEXT NOT NULL,
	CONSTRAINT client_address_ID PRIMARY KEY (ClientID, Address)
);

-- MEDICAL RECORDS
CREATE TABLE MedicalRecords (
    ClientID VARCHAR(10),
	CONSTRAINT fk_ClientID FOREIGN KEY(ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    ICDCode VARCHAR(50) NOT NULL CHECK (ICDCode ~ '^[A-Z0-9]{3,4}(\.[A-Z0-9]{1,4})?$'),
    DateCreated DATE DEFAULT CURRENT_DATE NOT NULL CHECK (DateCreated <= CURRENT_DATE),
    ConditionName VARCHAR(100) NOT NULL,
    Description TEXT,
    CONSTRAINT medical_record_id PRIMARY KEY (ClientID, ICDCode)
);

-- INSURANCE PLAN
CREATE TABLE InsurancePlan (
    InsurancePlanName VARCHAR(100) PRIMARY KEY,
    PlanType VARCHAR(50) NOT NULL,
    Description TEXT,
    CoverageLevel VARCHAR(50) NOT NULL,
    Premium DECIMAL(10, 2) NOT NULL CHECK (Premium > 0),
    Deductible DECIMAL(10, 2) NOT NULL CHECK (Deductible >= 0)
);

-- CLAIM REQUESTS
CREATE TABLE RequestClaim (
    EmployeeID VARCHAR(10),
	CONSTRAINT fk_EmployeeID FOREIGN KEY(EmployeeID) REFERENCES Employee(EmployeeID) ON DELETE CASCADE ON UPDATE CASCADE,
    ClientID VARCHAR(10),
	CONSTRAINT fk_CLientID FOREIGN KEY(ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    DateCreated DATE DEFAULT CURRENT_DATE NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount > 0),
    ApprovalStatus VARCHAR(50) DEFAULT 'Pending' NOT NULL,
    DecisionDate DATE,
    CONSTRAINT request_id PRIMARY KEY (EmployeeID, ClientID, DateCreated)
);

-- PAYS
CREATE TABLE Pays (
    EmployeeID VARCHAR(10),
	CONSTRAINT fk_EmployeeID FOREIGN KEY(EmployeeID) REFERENCES Employee(EmployeeID) ON DELETE SET NULL ON UPDATE CASCADE,
    ClientID VARCHAR(10),
	CONSTRAINT fk_ClientID FOREIGN KEY(ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    Date DATE DEFAULT CURRENT_DATE NOT NULL CHECK (Date <= CURRENT_DATE),
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount > 0),
    Purpose TEXT,
    CONSTRAINT payment_id PRIMARY KEY (EmployeeID, ClientID, Date)
);

-- EMPLOYEE DEPENDENT
CREATE TABLE EmployeeDependent (
    EmployeeID VARCHAR(10),
	CONSTRAINT fk_EmployeeID FOREIGN KEY(EmployeeID) REFERENCES Employee(EmployeeID) ON DELETE CASCADE ON UPDATE CASCADE,
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50) DEFAULT '' NOT NULL, -- will need for PK so not null
    LastName VARCHAR(50) NOT NULL,
    DOB DATE NOT NULL CHECK (DOB < CURRENT_DATE),
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')), 
    Relationship VARCHAR(50) NOT NULL,
    CONSTRAINT employee_dependent_id PRIMARY KEY (EmployeeID, FirstName, MiddleName, LastName)
);

-- CLIENT DEPENDENT
CREATE TABLE ClientDependent (
    ClientID VARCHAR(10),
	CONSTRAINT fk_ClientID FOREIGN KEY(ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE,
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50) DEFAULT '' NOT NULL, -- will need for PK so not null
    LastName VARCHAR(50) NOT NULL,
    DOB DATE NOT NULL CHECK (DOB < CURRENT_DATE),
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')), 
    Relationship VARCHAR(50) NOT NULL,
    CONSTRAINT client_dependent_id PRIMARY KEY (ClientID, FirstName, MiddleName, LastName)
);

-- HEALTHCARE PROVIDERS
CREATE TABLE HealthcareProvider (
    HealthcareProviderID VARCHAR(10) PRIMARY KEY, -- Format: HCP00000
    ProviderName VARCHAR(50) NOT NULL,
    ProviderType VARCHAR(50) NOT NULL,
    PhoneNumber VARCHAR(15) UNIQUE NOT NULL,
    Address TEXT NOT NULL
);

-- DOCTOR
CREATE TABLE Doctor (
    DoctorID VARCHAR(10) PRIMARY KEY, -- Format: DOC00000
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50),
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL CHECK (Email ~ '^[A-Za-z0-9._]+@[A-Za-z0-9.]+\.[A-Za-z]{2,}$'),
    PhoneNumber VARCHAR(15) UNIQUE,
    SupervisorHealthcareProviderID VARCHAR(10),
	CONSTRAINT fk_healthcare_provider_id FOREIGN KEY(SupervisorHealthcareProviderID) REFERENCES HealthcareProvider(HealthcareProviderID) 
	ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE UNIQUE INDEX unique_email_doctor ON Doctor (LOWER(Email));

-- DOCTOR SPECIALTY
CREATE TABLE DoctorSpecialization (
    DoctorID VARCHAR(10),
	CONSTRAINT fk_DoctorID FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID) ON DELETE CASCADE ON UPDATE CASCADE,
    Specialization VARCHAR(50) NOT NULL,
    CONSTRAINT specialization_id PRIMARY KEY (DoctorID, Specialization)
);

-- EMPLOY DOCTORS
CREATE TABLE EmployDoctor (
    HealthcareProviderID VARCHAR(10),
	CONSTRAINT fk_healthcareProviderID FOREIGN KEY(HealthcareProviderID) REFERENCES HealthcareProvider(HealthcareProviderID) 
	ON DELETE CASCADE ON UPDATE CASCADE,
    DoctorID VARCHAR(10),
	CONSTRAINT fk_DoctorID FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT employ_doctor_id PRIMARY KEY (HealthcareProviderID, DoctorID)
);

-- AGENT
CREATE TABLE Agent (
    AgentID VARCHAR(10) PRIMARY KEY, -- Format: AGT00000
    AgentName VARCHAR(100) NOT NULL,
    CommissionRate DECIMAL(5, 2) NOT NULL CHECK (CommissionRate >= 0), 
    Email VARCHAR(100) NOT NULL CHECK (Email ~ '^[A-Za-z0-9._]+@[A-Za-z0-9.]+\.[A-Za-z]{2,}$'),
    LicenseNumber VARCHAR(50) UNIQUE NOT NULL,
    PhoneNumber VARCHAR(15) UNIQUE NOT NULL
);
CREATE UNIQUE INDEX unique_email_agent ON Agent (LOWER(Email));

-- POLICIES
CREATE TABLE Policy (
    PolicyNumber VARCHAR(10) PRIMARY KEY, -- Format: PNM00000
    ExactCost DECIMAL(10, 2) CHECK (ExactCost >= 0) NOT NULL,
    StartDate DATE NOT NULL DEFAULT CURRENT_DATE,
    EndDate DATE NOT NULL,
    InsurancePlanName VARCHAR(100),
	CONSTRAINT fk_insurancePlanName FOREIGN KEY(InsurancePlanName) REFERENCES InsurancePlan(InsurancePlanName) 
	ON DELETE CASCADE ON UPDATE CASCADE
);

-- COVERS 
CREATE TABLE Covers (
    InsurancePlanName VARCHAR(100),
	CONSTRAINT fk_InsurancePlanName FOREIGN KEY(InsurancePlanName) REFERENCES InsurancePlan(InsurancePlanName) 
	ON DELETE CASCADE ON UPDATE CASCADE,
    HealthcareProviderID VARCHAR(10),
	CONSTRAINT fk_HealthcareProviderID FOREIGN KEY(HealthcareProviderID) REFERENCES HealthcareProvider(HealthcareProviderID) 
	ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT coverage_id PRIMARY KEY (InsurancePlanName, HealthcareProviderID)
);

-- MEDICAL SERVICES
CREATE TABLE MedicalService (
    ServiceID VARCHAR(10) PRIMARY KEY, -- Format: MDS00000
    ServiceName VARCHAR(100) NOT NULL,
    Description TEXT
);

-- PROVIDE
CREATE TABLE Provide (
    ClientID VARCHAR(10),
	CONSTRAINT fk_clientID FOREIGN KEY(ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    DoctorID VARCHAR(10),
	CONSTRAINT fk_doctorID FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID) ON DELETE SET NULL,
    ServiceID VARCHAR(10),
	CONSTRAINT fk_serviceID FOREIGN KEY(ServiceID) REFERENCES MedicalService(ServiceID) ON DELETE SET NULL,
    Date DATE NOT NULL DEFAULT CURRENT_DATE,
    ServiceCost DECIMAL(10, 2) CHECK (ServiceCost >= 0) NOT NULL,
    CONSTRAINT provided_service_id PRIMARY KEY (ClientID, DoctorID, ServiceID, Date)
);

-- DOCTOR REQUEST
CREATE TABLE RequestDoctor (
    ClientID VARCHAR(10),
	CONSTRAINT fk_clientID FOREIGN KEY(CLientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    DoctorID VARCHAR(10),
	CONSTRAINT fk_doctorID FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID) ON DELETE CASCADE ON UPDATE CASCADE,
    HealthcareProviderID VARCHAR(10),
	CONSTRAINT fk_healthcareProviderID FOREIGN KEY(HealthcareProviderID) REFERENCES HealthcareProvider(HealthcareProviderID) 
	ON DELETE CASCADE ON UPDATE CASCADE,
    Date DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT doctor_request_id PRIMARY KEY (ClientID, DoctorID, HealthcareProviderID, Date)
);

-- DOCTOR REFER
CREATE TABLE Refer (
    ClientID VARCHAR(10),
	CONSTRAINT fk_clientID FOREIGN KEY(ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    ReferringDoctorID VARCHAR(10),
	CONSTRAINT fk_referringDoctorID FOREIGN KEY(ReferringDoctorID) REFERENCES Doctor(DoctorID) 
	ON DELETE SET NULL ON UPDATE CASCADE,
    ReferredDoctorID VARCHAR(10),
	CONSTRAINT fk_referredDoctorID FOREIGN KEY(ReferredDoctorID) REFERENCES Doctor(DoctorID) 
	ON DELETE CASCADE ON UPDATE CASCADE,
    Date DATE NOT NULL DEFAULT CURRENT_DATE,
    Reason TEXT,
    CONSTRAINT referal_id PRIMARY KEY (ClientID, ReferringDoctorID, ReferredDoctorID, Date)
);

-- SELL
CREATE TABLE Sell (
    ClientID VARCHAR(10),
	CONSTRAINT fk_clientID FOREIGN KEY(ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    PolicyNumber VARCHAR(10),
	CONSTRAINT fk_policyNumber FOREIGN KEY(PolicyNumber) REFERENCES Policy(PolicyNumber) ON DELETE CASCADE ON UPDATE CASCADE,
    AgentID VARCHAR(10),
	CONSTRAINT fk_agentID FOREIGN KEY(AgentID) REFERENCES Agent(AgentID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT sell_transaction_id PRIMARY KEY (ClientID, PolicyNumber, AgentID)
);

-- INSERT STATEMENTS
INSERT INTO Employee (EmployeeID, FirstName, MiddleName, LastName, PhoneNumber, Email, Address, Salary, JobTitle) VALUES
('EMP00001', 'Omar', 'Khaled', 'Haddad', '712345678', 'omar.haddad@procare.com', '12 Main St, Beirut', 1500, 'Software Developer'),
('EMP00002', 'Layla', 'Samir', 'Kassem', '703456789', 'layla.kassem@procare.com', '34 Elm St, Tripoli', 1800, 'Claims Manager'),
('EMP00003', 'Ziad', 'Rami', 'Nassar', '714567890', 'ziad.nassar@procare.com', '56 Cedar St, Sidon', 2000, 'Marketing Specialist'),
('EMP00004', 'Hana', 'Nour', 'Jebril', '705678901', 'hana.jebril@procare.com', '78 Olive St, Tyre', 1700, 'HR Coordinator'),
('EMP00005', 'Fadi', 'Joe', 'Salameh', '716789012', 'fadi.salameh@procare.com', '90 Palm St, Baabda', 1600, 'Claims Specialist'),
('EMP00006', 'Rania', 'Tarek', 'Matar', '707890123', 'rania.matar@procare.com', '23 Jasmine St, Zahle', 1900, 'UX Designer'),
('EMP00007', 'Karim', 'Ali', 'Issa', '718901234', 'karim.boukhallil@procare.com', '45 Rose St, Byblos', 2100, 'Sales Executive'),
('EMP00008', 'Dalia', 'Ziad', 'Sayegh', '709012345', 'dalia.sayegh@procare.com', '67 Orchid St, Jounieh', 1750, 'Customer Service Rep'),
('EMP00009', 'Noor', 'Fadi', 'Ghazal', '718912345', 'noor.ghazal@procare.com', '89 Pinetree St, Beirut', 2200, 'Account Manager'),
('EMP00010', 'Sami', 'Omar', 'Shams', '712345670', 'sami.shams@procare.com', '44 Sunset Ave, Tripoli', 1850, 'Financial Coordinator');

INSERT INTO Client (ClientID, FirstName, MiddleName, LastName, DOB, Gender, Email) VALUES
('CLI00001', 'Ali', 'Jamal', 'Hajj', '1985-02-14', 'M', 'ali.hajj@email.com'),
('CLI00002', 'Lina', 'Samir', 'Karam', '1990-08-25', 'F', 'lina.karam@email.com'),
('CLI00003', 'Omar', 'Fouad', 'Nasr', '1987-11-03', 'M', 'omar.nasr@email.com'),
('CLI00004', 'Nour', 'Rami', 'Daher', '1992-07-19', 'F', 'nour.daher@email.com'),
('CLI00005', 'Rami', 'Khaled', 'Saab', '1983-05-30', 'M', 'rami.saab@email.com'),
('CLI00006', 'Hiba', 'Ahmad', 'Sayegh', '1988-12-12', 'F', 'hiba.sayegh@email.com'),
('CLI00007', 'Samir', 'Fadi', 'Youssef', '1991-01-22', 'M', 'samir.youssef@email.com'),
('CLI00008', 'Layal', 'Tarek', 'Khalil', '1989-04-15', 'F', 'layal.khalil@email.com'),
('CLI00009', 'Karim', 'Walid', 'Assaf', '1993-09-17', 'M', 'karim.assaf@email.com'),
('CLI00010', 'Nadine', 'Ziad', 'Jaber', '1995-03-08', 'F', 'nadine.jaber@email.com');

INSERT INTO ClientPhoneNumber (ClientID, PhoneNumber) VALUES
('CLI00001', '71234567'),
('CLI00001', '01860123'),
('CLI00002', '70345678'),
('CLI00003', '71456789'),
('CLI00004', '70567890'),
('CLI00005', '71678901'),
('CLI00006', '70789012'),
('CLI00007', '71890123'),
('CLI00008', '70901234'),
('CLI00009', '71234567'),
('CLI00010', '70345678');

INSERT INTO ClientAddress (ClientID, Address) VALUES
('CLI00001', '15 Cedar Rd, Beirut'),
('CLI00002', '28 Maple St, Tripoli'),
('CLI00003', '34 Pine Ave, Sidon'),
('CLI00004', '56 Jasmine St, Tyre'),
('CLI00004', 'Banque du Liban, Riad El Solh, Beirut'),
('CLI00005', '78 Olive Rd, Zahle'),
('CLI00006', '90 Palm Ave, Baabda'),
('CLI00007', '12 Cedar Blvd, Byblos'),
('CLI00008', '23 Rose Ln, Jounieh'),
('CLI00009', '45 Oak St, Nabatieh'),
('CLI00010', '67 Birch Ave, Aley');

INSERT INTO MedicalRecords (ClientID, ICDCode, DateCreated, ConditionName, Description) VALUES
('CLI00001', 'A01.0', '2024-01-15', 'Typhoid Fever', 'Acute bacterial infection'),
('CLI00002', 'J20.9', '2023-11-20', 'Acute Bronchitis', 'Inflammation of the bronchial tubes'),
('CLI00003', 'E11.9', '2024-02-03', 'Type 2 Diabetes', 'Chronic condition affecting metabolism'),
('CLI00004', 'I10', '2023-05-18', 'Essential Hypertension', 'High blood pressure'),
('CLI00005', 'K21.9', '2023-08-22', 'Gastroesophageal Reflux', 'Acid reflux in the esophagus'),
('CLI00006', 'L50.0', '2024-03-10', 'Urticaria', 'Condition with red, itchy welts'),
('CLI00007', 'M54.5', '2024-06-15', 'Low Back Pain', 'Pain in the lower back region'),
('CLI00008', 'F32.9', '2023-09-12', 'Major Depressive Disorder', 'Persistent feeling of sadness'),
('CLI00009', 'N39.0', '2024-04-25', 'Urinary Tract Infection', 'Bacterial infection in the urinary tract'),
('CLI00010', 'H52.4', '2023-12-30', 'Presbyopia', 'Age-related difficulty in seeing close objects');

INSERT INTO InsurancePlan (InsurancePlanName, PlanType, Description, CoverageLevel, Premium, Deductible) VALUES
('Basic Health Plan', 'HMO', 'Provides comprehensive health coverage', 'Silver', 200, 1000),
('Flexible Care Plan', 'PPO', 'Offers flexibility in choosing healthcare providers', 'Gold', 300, 500),
('Comprehensive Plan', 'POS', 'Combines HMO and PPO features for more options', 'Platinum', 350, 300),
('Essential Coverage', 'EPO', 'Covers essential health benefits with no out-of-network coverage', 'Bronze', 180, 1500),
('High Deductible Health Plan', 'HDHP', 'Lower premiums with higher deductibles for catastrophic coverage', 'Bronze', 150, 2500),
('Family Protection Plan', 'HMO', 'Family-focused plan with low out-of-pocket costs', 'Silver', 250, 750),
('Premium Wellness Plan', 'PPO', 'High-level coverage with extensive provider network', 'Platinum', 400, 250),
('Student Health Plan', 'EPO', 'Designed for students, with essential coverage', 'Gold', 150, 1200),
('Senior Advantage Plan', 'HMO', 'Tailored for seniors, includes wellness programs', 'Gold', 220, 800),
('Preventive Care Plan', 'POS', 'Focused on preventive care and routine checkups', 'Silver', 170, 1000);

INSERT INTO RequestClaim (EmployeeID, ClientID, DateCreated, Amount, ApprovalStatus, DecisionDate) VALUES
('EMP00005', 'CLI00001', '2024-01-05', 250, 'Approved', '2024-01-10'),
('EMP00002', 'CLI00002', '2024-02-12', 500, 'Approved', '2024-02-15'),
('EMP00002', 'CLI00003', '2024-03-01', 300, 'Pending', NULL),
('EMP00002', 'CLI00004', '2024-03-18', 450, 'Approved', '2024-03-20'),
('EMP00005', 'CLI00005', '2024-04-05', 600, 'Denied', '2024-04-08'),
('EMP00002', 'CLI00006', '2024-04-20', 400, 'Approved', '2024-04-25'),
('EMP00005', 'CLI00007', '2024-05-10', 700, 'Pending', NULL),
('EMP00005', 'CLI00008', '2024-06-02', 550, 'Approved', '2024-06-05'),
('EMP00002', 'CLI00009', '2024-06-15', 250, 'Denied', '2024-06-18'),
('EMP00002', 'CLI00010', '2024-07-01', 650, 'Approved', '2024-07-10');

INSERT INTO Pays (EmployeeID, ClientID, Date, Amount, Purpose) VALUES
('EMP00008', 'CLI00001', '2024-01-10', 500, 'Service Fees'),
('EMP00009', 'CLI00002', '2024-02-15', 750, 'Claims Processing Fee'),
('EMP00010', 'CLI00003', '2024-03-05', 300, 'Policy Issuance Fee'),
('EMP00010', 'CLI00004', '2024-03-20', 600, 'Annual Premium Payment'),
('EMP00009', 'CLI00005', '2024-04-08', 450, 'Risk Assessment Fee'),
('EMP00008', 'CLI00006', '2024-04-25', 800, 'Insurance Consultation Fee'),
('EMP00008', 'CLI00007', '2024-05-12', 700, 'Claims Adjustment Fee'),
('EMP00008', 'CLI00008', '2024-06-01', 400, 'Coverage Modification Fee'),
('EMP00010', 'CLI00009', '2024-06-18', 550, 'Insurance Renewal Fee'),
('EMP00009', 'CLI00010', '2024-07-10', 650, 'Services Fees');

INSERT INTO EmployeeDependent (EmployeeID, FirstName, MiddleName, LastName, DOB, Gender, Relationship) VALUES
('EMP00001', 'Khaled', 'Omar', 'Haddad', '2010-05-15', 'M', 'Son'),
('EMP00002', 'Tia', 'Hadi', 'Saab', '2012-08-20', 'M', 'Son'),
('EMP00003', 'Rami', 'Ziad', 'Nassar', '2008-03-12', 'M', 'Son'),
('EMP00004', 'Latifa', 'Abed', 'Bakri', '1957-07-25', 'F', 'Parent'),
('EMP00005', 'Anthony', 'Fadi', 'Salameh', '2011-09-30', 'M', 'Son'),
('EMP00006', 'Omar', 'Sami', 'Mansour', '2013-06-10', 'M', 'Son'),
('EMP00007', 'Dalia', 'Karim', 'Issa', '2009-11-05', 'F', 'Daughter'),
('EMP00008', 'Ziad', 'Jad', 'Sabbagh', '2014-02-28', 'M', 'Son'),
('EMP00009', 'Fadi', 'Ayman', 'Ghazal', '1960-04-14', 'M', 'Parent'),
('EMP00010', 'Yara', 'Sami', 'Shams', '2012-12-18', 'F', 'Daughter');

INSERT INTO ClientDependent (ClientID, FirstName, MiddleName, LastName, DOB, Gender, Relationship) VALUES
('CLI00001', 'Cynthia', 'Ali', 'Hajj', '2000-01-01', 'F', 'Daughter'),
('CLI00001', 'Dana', 'Ali', 'Hajj', '2002-02-02', 'F', 'Daughter'),
('CLI00003', 'Ahmad', 'Omar', 'Nasr', '2001-03-03', 'M', 'Son'),
('CLI00005', 'Elie', 'Rami', 'Saab', '2003-04-04', 'M', 'Son'),
('CLI00007', 'Sam', 'Samir', 'Youssef', '2004-05-05', 'M', 'Son'),
('CLI00007', 'Layal', 'Samir', 'Youssef', '2006-06-06', 'F', 'Daughter'),
('CLI00010', 'Abed', 'Tarek', 'Bader', '2002-07-07', 'M', 'Son'),
('CLI00004', 'Ghazi', 'Saad', 'Batrouni', '2001-08-08', 'M', 'Son'),
('CLI00006', 'Nada', 'Dani', 'Kanj', '2003-09-09', 'F', 'Daughter'),
('CLI00006', 'Kamal', 'Dani', 'Kanj', '2005-10-10', 'M', 'Son');

INSERT INTO HealthcareProvider (HealthcareProviderID, ProviderName, ProviderType, PhoneNumber, Address) VALUES
('HCP00001', 'HealthFirst Clinic', 'Clinic', '01234567123', 'Wellness St, Ashrafieh, Beirut'),
('HCP00002', 'CarePlus Hospital', 'Hospital', '01345678456', 'Care Rd, Hamra, Beirut'),
('HCP00003', 'MediQuick Pharmacy', 'Pharmacy', '01456789789', 'Rx Ave, Jdeideh, Beirut'),
('HCP00004', 'Family Health Center', 'Clinic', '01567890101', 'Family Ln, Tripoli'),
('HCP00005', 'Wellness Medical Group', 'Specialist Center', '01678901202', 'Health Dr, Sidon'),
('HCP00006', 'Emergency Care Unit', 'Hospital', '01789012303', 'Urgent St, Zahle'),
('HCP00007', 'Pediatric Specialists', 'Specialist Center', '01890123404', 'Kids Blvd, Byblos'),
('HCP00008', 'Senior Health Services', 'Home Care', '01901234505', 'Elder St, Baabda'),
('HCP00009', 'Dental Wellness Center', 'Dental Clinic', '01012345606', 'Smile St, Bekaa'),
('HCP00010', 'Vision Care Center', 'Specialist Center', '01123456707', 'Sight St, Nabatieh');

INSERT INTO Doctor (DoctorID, FirstName, MiddleName, LastName, Email, PhoneNumber, SupervisorHealthcareProviderID) VALUES
('DOC00001', 'Ahmad', 'Khaled', 'Khoury', 'ahmad.khoury@email.com', '03456789', 'HCP00001'),
('DOC00002', 'Layla', 'Samir', 'Kabbani', 'layla.hariri@email.com', '03567890', 'HCP00002'),
('DOC00003', 'Ziad', 'Omar', 'Rahme', 'ziad.rahme@email.com', '03678901', 'HCP00003'),
('DOC00004', 'Rania', 'Fouad', 'Jabbour', 'rania.jabbour@email.com', '03789012', 'HCP00004'),
('DOC00005', 'Samir', 'Jamil', 'Fahed', 'samir.fahed@email.com', '03890123', 'HCP00005'),
('DOC00006', 'Dalia', 'Ziad', 'Ghanem', 'dalia.ghanem@email.com', '03901234', 'HCP00006'),
('DOC00007', 'Omar', 'Tariq', 'Husseini', 'omar.husseini@email.com', '03012345', 'HCP00007'),
('DOC00008', 'Nour', 'Sami', 'Itani', 'nour.aoun@email.com', '03123456', 'HCP00008'),
('DOC00009', 'Hiba', 'Rami', 'Kassem', 'hiba.kassem@email.com', '03234567', 'HCP00009'),
('DOC00010', 'Yara', 'Ali', 'Najm', 'yara.najm@email.com', '03345678', 'HCP00010');

INSERT INTO DoctorSpecialization (DoctorID, Specialization) VALUES
('DOC00001', 'Cardiology'),
('DOC00001', 'Internal Medicine'),
('DOC00002', 'Pediatrics'),
('DOC00003', 'Orthopedics'),
('DOC00003', 'Sports Medicine'),
('DOC00004', 'Obstetrics'),
('DOC00004', 'Gynecology'),
('DOC00005', 'Dermatology'),
('DOC00006', 'Psychiatry'),
('DOC00006', 'Neurology'),
('DOC00007', 'General Surgery'),
('DOC00008', 'Family Medicine'),
('DOC00009', 'Dentistry'),
('DOC00010', 'Ophthalmology');

INSERT INTO EmployDoctor (HealthcareProviderID, DoctorID) VALUES
('HCP00001', 'DOC00001'),
('HCP00001', 'DOC00005'),
('HCP00002', 'DOC00002'),
('HCP00003', 'DOC00003'),
('HCP00004', 'DOC00004'),
('HCP00005', 'DOC00006'),
('HCP00006', 'DOC00007'),
('HCP00007', 'DOC00008'),
('HCP00008', 'DOC00009'),
('HCP00009', 'DOC00010');

INSERT INTO Agent (AgentID, AgentName, CommissionRate, Email, LicenseNumber, PhoneNumber) VALUES
('AGT00001', 'Rami Hbeish', 5.00, 'rami.h@email.com', 'L001', '71234567'),
('AGT00002', 'Nour Youssef', 6.00, 'nour.y@email.com', 'L002', '71234568'),
('AGT00003', 'Leila Bahji', 4.00, 'leila.b@email.com', 'L003', '71234569'),
('AGT00004', 'Jamil Akl', 7.00, 'jamil.a@email.com', 'L004', '71234570'),
('AGT00005', 'Mira Khamis', 5.00, 'mira.k@email.com', 'L005', '71234571'),
('AGT00006', 'Sami Zaatari', 6.00, 'sami.z@email.com', 'L006', '71234572'),
('AGT00007', 'Nadine Qassem', 5.00, 'nadine.q@email.com', 'L007', '71234573'),
('AGT00008', 'Tarek Soufi', 4.00, 'tarek.s@email.com', 'L008', '71234574'),
('AGT00009', 'Hala Chams', 5.00, 'hala.c@email.com', 'L009', '71234575'),
('AGT00010', 'Ziad Dabbous', 6.00, 'ziad.d@email.com', 'L010', '71234576');

INSERT INTO Policy (PolicyNumber, ExactCost, StartDate, EndDate, InsurancePlanName) VALUES
('PNM00001', 500.00, '2024-01-01', '2024-12-31', 'Basic Health Plan'),
('PNM00002', 750.00, '2024-02-01', '2025-01-31', 'Flexible Care Plan'),
('PNM00003', 1200.00, '2024-03-01', '2025-02-28', 'Comprehensive Plan'),
('PNM00004', 400.00, '2024-04-01', '2024-10-01', 'Essential Coverage'),
('PNM00005', 1000.00, '2024-05-01', '2025-04-30', 'High Deductible Health Plan'),
('PNM00006', 600.00, '2024-06-01', '2025-05-31', 'Family Protection Plan'),
('PNM00007', 800.00, '2024-07-01', '2025-06-30', 'Premium Wellness Plan'),
('PNM00008', 350.00, '2024-08-01', '2024-11-30', 'Student Health Plan'),
('PNM00009', 550.00, '2024-09-01', '2025-08-31', 'Senior Advantage Plan'),
('PNM00010', 450.00, '2024-10-01', '2025-09-30', 'Preventive Care Plan');

INSERT INTO Covers (InsurancePlanName, HealthcareProviderID) VALUES
('Basic Health Plan', 'HCP00001'),
('Flexible Care Plan', 'HCP00001'),
('Essential Coverage', 'HCP00002'),
('Comprehensive Plan', 'HCP00003'),
('Essential Coverage', 'HCP00004'),
('High Deductible Health Plan', 'HCP00005'),
('Family Protection Plan', 'HCP00006'),
('Premium Wellness Plan', 'HCP00007'),
('Student Health Plan', 'HCP00008'),
('Senior Advantage Plan', 'HCP00009'),
('Preventive Care Plan', 'HCP00010'),
('Premium Wellness Plan', 'HCP00010');

INSERT INTO MedicalService (ServiceID, ServiceName, Description) VALUES
('MDS00001', 'General Check-up', 'Routine examination to assess overall health.'),
('MDS00002', 'Blood Test', 'Laboratory analysis to evaluate blood conditions.'),
('MDS00003', 'X-ray', 'Imaging technique to view bones and structures.'),
('MDS00004', 'MRI Scan', 'Advanced imaging for detailed body analysis.'),
('MDS00005', 'Physical Therapy', 'Rehabilitation treatment to improve mobility.'),
('MDS00006', 'Vaccination', 'Immunization to prevent diseases.'),
('MDS00007', 'Allergy Testing', 'Tests to identify specific allergies.'),
('MDS00008', 'Ultrasound', 'Imaging technique using sound waves for diagnosis.'),
('MDS00009', 'Surgical Consultation', 'Evaluation and planning for potential surgery.'),
('MDS00010', 'Dermatology Services', 'Treatment for skin-related issues.');

INSERT INTO Provide (ClientID, DoctorID, ServiceID, Date, ServiceCost) VALUES
('CLI00005', 'DOC00003', 'MDS00001', '2024-10-01', 100),
('CLI00002', 'DOC00007', 'MDS00006', '2024-10-02', 150),
('CLI00009', 'DOC00001', 'MDS00004', '2024-10-03', 200),
('CLI00001', 'DOC00008', 'MDS00002', '2024-10-04', 400),
('CLI00010', 'DOC00005', 'MDS00007', '2024-10-05', 250),
('CLI00004', 'DOC00002', 'MDS00005', '2024-10-06', 80),
('CLI00006', 'DOC00009', 'MDS00008', '2024-10-07', 120),
('CLI00003', 'DOC00010', 'MDS00009', '2024-10-08', 300),
('CLI00008', 'DOC00006', 'MDS00003', '2024-10-09', 500),
('CLI00007', 'DOC00004', 'MDS00010', '2024-10-10', 90);

INSERT INTO RequestDoctor (ClientID, DoctorID, HealthcareProviderID, Date) VALUES
('CLI00001', 'DOC00001', 'HCP00001', '2024-10-01'),
('CLI00002', 'DOC00002', 'HCP00002', '2024-10-02'),
('CLI00003', 'DOC00003', 'HCP00003', '2024-10-03'),
('CLI00004', 'DOC00004', 'HCP00004', '2024-10-04'),
('CLI00005', 'DOC00005', 'HCP00005', '2024-10-05'),
('CLI00006', 'DOC00006', 'HCP00006', '2024-10-06'),
('CLI00007', 'DOC00007', 'HCP00007', '2024-10-07'),
('CLI00008', 'DOC00008', 'HCP00008', '2024-10-08'),
('CLI00009', 'DOC00009', 'HCP00009', '2024-10-09'),
('CLI00010', 'DOC00010', 'HCP00010', '2024-10-10');

INSERT INTO Refer (ClientID, ReferringDoctorID, ReferredDoctorID, Date, Reason) VALUES
('CLI00001', 'DOC00001', 'DOC00002', '2024-10-01', 'Specialist Consultation'),
('CLI00002', 'DOC00002', 'DOC00003', '2024-10-02', 'Further Evaluation'),
('CLI00003', 'DOC00003', 'DOC00004', '2024-10-03', 'Surgical Assessment'),
('CLI00004', 'DOC00004', 'DOC00005', '2024-10-04', 'Dermatological Concern'),
('CLI00005', 'DOC00005', 'DOC00006', '2024-10-05', 'Mental Health Evaluation'),
('CLI00006', 'DOC00006', 'DOC00007', '2024-10-06', 'Neurological Assessment'),
('CLI00007', 'DOC00007', 'DOC00008', '2024-10-07', 'Family Medicine Follow-up'),
('CLI00008', 'DOC00008', 'DOC00009', '2024-10-08', 'Dental Issues'),
('CLI00009', 'DOC00009', 'DOC00010', '2024-10-09', 'Vision Check'),
('CLI00010', 'DOC00010', 'DOC00001', '2024-10-10', 'General Health Review');

INSERT INTO Sell (ClientID, PolicyNumber, AgentID) VALUES
('CLI00001', 'PNM00005', 'AGT00002'),
('CLI00002', 'PNM00010', 'AGT00002'),
('CLI00003', 'PNM00001', 'AGT00001'),
('CLI00004', 'PNM00006', 'AGT00004'),
('CLI00005', 'PNM00002', 'AGT00005'),
('CLI00006', 'PNM00007', 'AGT00005'),
('CLI00007', 'PNM00003', 'AGT00007'),
('CLI00008', 'PNM00009', 'AGT00008'),
('CLI00009', 'PNM00004', 'AGT00009'),
('CLI00010', 'PNM00008', 'AGT00010');

SELECT * FROM Employee;
SELECT * FROM Client;
SELECT * FROM ClientPhoneNumber;
SELECT * FROM ClientAddress;
SELECT * FROM MedicalRecords;
SELECT * FROM InsurancePlan;
SELECT * FROM RequestClaim;
SELECT * FROM Pays;
SELECT * FROM EmployeeDependent;
SELECT * FROM ClientDependent;
SELECT * FROM HealthcareProvider;
SELECT * FROM Doctor;
SELECT * FROM DoctorSpecialization;
SELECT * FROM EmployDoctor;
SELECT * FROM Agent;
SELECT * FROM Policy;
SELECT * FROM Covers;
SELECT * FROM MedicalService;
SELECT * FROM Provide;
SELECT * FROM RequestDoctor;
SELECT * FROM Refer;
SELECT * FROM Sell;

-- COMPLEX QUERIES
-- the distribution of clients in the hospitals based on the insurance plans level
SELECT 
    H.HealthcareProviderID, 
    H.ProviderName AS HealthcareProviderName, 
    IP.CoverageLevel AS InsurancePlanLevel, 
    COUNT(DISTINCT C.ClientID) AS ClientCount  
FROM Provide P 
JOIN Client C ON P.ClientID = C.ClientID 
JOIN Sell S ON C.ClientID = S.ClientID 
JOIN Policy L ON S.PolicyNumber = L.PolicyNumber 
JOIN InsurancePlan IP ON L.InsurancePlanName = IP.InsurancePlanName 
JOIN EmployDoctor ED ON P.DoctorID = ED.DoctorID 
JOIN HealthcareProvider H ON ED.HealthcareProviderID = H.HealthcareProviderID 
GROUP BY H.HealthcareProviderID, H.ProviderName, IP.CoverageLevel 
ORDER BY H.HealthcareProviderID, IP.CoverageLevel;

-- the spendings of the clients in different healthcare providers
CREATE VIEW ClientServicePaymentsView AS 
WITH ClientServicePayments AS ( 
	SELECT 
        H.HealthcareProviderID, 
        H.ProviderName AS HealthcareProviderName, 
        C.ClientID, 
        CONCAT(C.FirstName, ' ', COALESCE(C.MiddleName, ''), ' ', C.LastName) AS ClientFullName, 
        MS.ServiceID, 
        MS.ServiceName, 
        DATE(P.Date) AS PaymentDate, 
        TO_CHAR(P.Date, 'YYYY-MM') AS RevenueMonth, 
        P.ServiceCost AS PaymentAmount 
    FROM Provide P 
    JOIN Client C ON P.ClientID = C.ClientID
    JOIN Doctor D ON P.DoctorID = D.DoctorID 
    JOIN EmployDoctor ED ON D.DoctorID = ED.DoctorID 
    JOIN HealthcareProvider H ON ED.HealthcareProviderID = H.HealthcareProviderID 
    JOIN MedicalService MS ON P.ServiceID = MS.ServiceID 
)
SELECT 
    HealthcareProviderID, 
    HealthcareProviderName, 
    ClientID, 
    ClientFullName, 
    ServiceID, 
    ServiceName, 
    PaymentDate, 
    RevenueMonth, 
    PaymentAmount
FROM ClientServicePayments;
SELECT 
    HealthcareProviderID, 
    HealthcareProviderName, 
    ClientID, 
    ClientFullName, 
    ServiceID, 
    ServiceName, 
    PaymentDate, 
    RevenueMonth, 
    PaymentAmount
FROM ClientServicePaymentsView 
ORDER BY PaymentDate, ClientFullName, ServiceName;

-- fraud claims
SELECT 
    RC.ClientID,
    CONCAT(C.FirstName, ' ', COALESCE(C.MiddleName, ''), ' ', C.LastName) AS ClientName,
    E.EmployeeID,
    CONCAT(E.FirstName, ' ', COALESCE(E.MiddleName, ''), ' ', E.LastName) AS EmployeeName,
    TO_CHAR(RC.DateCreated, 'YYYY-MM') AS ClaimMonth,
    COUNT(*) AS ClaimCount,
    SUM(RC.Amount) AS TotalAmount,
    (MAX(RC.DateCreated) - MIN(RC.DateCreated)) AS ClaimPeriod 
FROM RequestClaim RC
JOIN Client C ON RC.ClientID = C.ClientID
JOIN Employee E ON RC.EmployeeID = E.EmployeeID
GROUP BY RC.ClientID, ClaimMonth, E.EmployeeID, C.FirstName, C.LastName, E.FirstName, E.LastName, C.MiddleName, E.MiddleName
HAVING COUNT(*) > 5 
   AND SUM(RC.Amount) > 50000
   AND (MAX(RC.DateCreated) - MIN(RC.DateCreated)) < 30; 

INSERT INTO RequestClaim (EmployeeID, ClientID, DateCreated, Amount, ApprovalStatus, DecisionDate) VALUES
('EMP00005', 'CLI00001', '2024-01-06', 25000, 'Pending', NULL),
('EMP00006', 'CLI00001', '2024-01-06', 50000, 'Pending', NULL),
('EMP00005', 'CLI00001', '2024-01-07', 2000, 'Pending', NULL),
('EMP00007', 'CLI00001', '2024-01-06', 5000, 'Pending', NULL),
('EMP00008', 'CLI00001', '2024-01-06', 25000, 'Pending', NULL),
('EMP00001', 'CLI00001', '2024-01-06', 50000, 'Pending', NULL);