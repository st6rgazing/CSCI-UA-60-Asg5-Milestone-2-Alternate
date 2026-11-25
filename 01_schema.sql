PRAGMA foreign_keys = ON;

CREATE TABLE region (
  region_id INT PRIMARY KEY,
  region_name TEXT NOT NULL UNIQUE,
  country TEXT NOT NULL,
  regulatory_regime TEXT NOT NULL
);

CREATE TABLE availability_zone (
  zone_id INT PRIMARY KEY,
  region_id INT NOT NULL,
  zone_code TEXT NOT NULL UNIQUE,
  redundancy_level TEXT NOT NULL CHECK (redundancy_level IN ('standard','high','critical')),
  FOREIGN KEY (region_id) REFERENCES region (region_id)
);

CREATE TABLE data_center (
  dc_id INT PRIMARY KEY,
  zone_id INT NOT NULL,
  dc_name TEXT NOT NULL UNIQUE,
  city TEXT NOT NULL,
  opened_date DATE NOT NULL,
  FOREIGN KEY (zone_id) REFERENCES availability_zone (zone_id)
);

CREATE TABLE staff (
  staff_id INT PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  staff_role TEXT NOT NULL CHECK (staff_role IN ('account_manager','engineer','technician','billing','support')),
  home_dc_id INT NOT NULL,
  FOREIGN KEY (home_dc_id) REFERENCES data_center (dc_id)
);

CREATE TABLE resource_type (
  type_id INT PRIMARY KEY,
  type_name TEXT NOT NULL UNIQUE,
  category TEXT NOT NULL CHECK (category IN ('compute','gpu','storage','network','bare_metal')),
  performance_tier TEXT NOT NULL CHECK (performance_tier IN ('standard','performance','premium')),
  vcpus INT NOT NULL DEFAULT 0 CHECK (vcpus >= 0),
  memory_gb INT NOT NULL DEFAULT 0 CHECK (memory_gb >= 0),
  storage_gb INT NOT NULL DEFAULT 0 CHECK (storage_gb >= 0),
  gpu_count INT NOT NULL DEFAULT 0 CHECK (gpu_count >= 0),
  is_reassignable INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE resource_group (
  group_id INT PRIMARY KEY,
  group_name TEXT NOT NULL UNIQUE,
  group_type TEXT NOT NULL CHECK (group_type IN ('cluster','rack','pool','failover_pair')),
  spans_multiple_zones INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE resource (
  resource_id INT PRIMARY KEY,
  dc_id INT NOT NULL,
  type_id INT NOT NULL,
  group_id INT,
  resource_code TEXT NOT NULL UNIQUE,
  purpose TEXT NOT NULL CHECK (purpose IN ('production','spare','test')),
  install_date DATE NOT NULL,
  FOREIGN KEY (dc_id) REFERENCES data_center (dc_id),
  FOREIGN KEY (type_id) REFERENCES resource_type (type_id),
  FOREIGN KEY (group_id) REFERENCES resource_group (group_id)
);

CREATE TABLE resource_status_log (
  status_log_id INT PRIMARY KEY,
  resource_id INT NOT NULL,
  staff_id INT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('maintenance','outage','degraded','retired')),
  is_scheduled INTEGER NOT NULL,
  reason TEXT,
  start_time TEXT NOT NULL,
  end_time TEXT,
  CHECK (end_time > start_time),
  FOREIGN KEY (resource_id) REFERENCES resource (resource_id),
  FOREIGN KEY (staff_id) REFERENCES staff (staff_id)
);

CREATE TABLE client (
  client_id INT PRIMARY KEY,
  client_name TEXT NOT NULL UNIQUE,
  client_type TEXT NOT NULL CHECK (client_type IN ('enterprise','government','startup','academic','nonprofit')),
  industry TEXT NOT NULL,
  qualification_level TEXT NOT NULL CHECK (qualification_level IN ('standard','silver','gold','platinum')),
  contract_type TEXT NOT NULL CHECK (contract_type IN ('pay_as_you_go','annual','multi_year')),
  discount_pct REAL NOT NULL DEFAULT 0 CHECK (discount_pct BETWEEN 0 AND 50),
  max_priority_level INT NOT NULL CHECK (max_priority_level BETWEEN 1 AND 5),
  is_confidential INTEGER NOT NULL DEFAULT 0,
  account_manager_id INT NOT NULL,
  FOREIGN KEY (account_manager_id) REFERENCES staff (staff_id)
);

CREATE TABLE team (
  team_id INT PRIMARY KEY,
  client_id INT NOT NULL,
  team_name TEXT NOT NULL,
  UNIQUE (client_id, team_name),
  FOREIGN KEY (client_id) REFERENCES client (client_id)
);

CREATE TABLE client_user (
  user_id INT PRIMARY KEY,
  team_id INT NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  is_emergency_contact INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (team_id) REFERENCES team (team_id)
);

CREATE TABLE billing_account (
  billing_account_id INT PRIMARY KEY,
  client_id INT NOT NULL,
  account_name TEXT NOT NULL,
  billing_email TEXT NOT NULL,
  UNIQUE (client_id, account_name),
  FOREIGN KEY (client_id) REFERENCES client (client_id)
);

CREATE TABLE project (
  project_id INT PRIMARY KEY,
  team_id INT NOT NULL,
  project_name TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE,
  CHECK (end_date >= start_date),
  FOREIGN KEY (team_id) REFERENCES team (team_id)
);

CREATE TABLE cost_allocation_rule (
  rule_id INT PRIMARY KEY,
  project_id INT NOT NULL,
  billing_account_id INT NOT NULL,
  share_pct REAL NOT NULL CHECK (share_pct > 0 AND share_pct <= 100),
  effective_from DATE NOT NULL,
  effective_to DATE,
  CHECK (effective_to >= effective_from),
  FOREIGN KEY (project_id) REFERENCES project (project_id),
  FOREIGN KEY (billing_account_id) REFERENCES billing_account (billing_account_id)
);

CREATE TABLE service (
  service_id INT PRIMARY KEY,
  service_name TEXT NOT NULL UNIQUE,
  category TEXT NOT NULL CHECK (category IN ('network','storage','support','security','backup')),
  billing_unit TEXT NOT NULL,
  unit_price REAL NOT NULL CHECK (unit_price >= 0)
);

CREATE TABLE rate (
  rate_id INT PRIMARY KEY,
  type_id INT NOT NULL,
  pricing_model TEXT NOT NULL CHECK (pricing_model IN ('on_demand','reserved','peak','off_peak')),
  price_per_hour REAL NOT NULL CHECK (price_per_hour >= 0),
  start_hour INT CHECK (start_hour BETWEEN 0 AND 23),
  end_hour INT CHECK (end_hour BETWEEN 0 AND 23),
  min_hours_per_month INT,
  effective_from DATE NOT NULL,
  effective_to DATE,
  CHECK (effective_to >= effective_from),
  CHECK ((start_hour IS NULL) = (end_hour IS NULL)),
  FOREIGN KEY (type_id) REFERENCES resource_type (type_id)
);

CREATE TABLE reservation (
  reservation_id INT PRIMARY KEY,
  project_id INT NOT NULL,
  region_id INT NOT NULL,
  user_id INT NOT NULL,
  type_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  zone_policy TEXT NOT NULL CHECK (zone_policy IN ('single_zone','multi_zone','any')),
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('pending','confirmed','active','completed','cancelled')),
  deposit_amount REAL NOT NULL DEFAULT 0 CHECK (deposit_amount >= 0),
  created_at TEXT NOT NULL,
  CHECK (end_time > start_time),
  FOREIGN KEY (project_id) REFERENCES project (project_id),
  FOREIGN KEY (region_id) REFERENCES region (region_id),
  FOREIGN KEY (user_id) REFERENCES client_user (user_id),
  FOREIGN KEY (type_id) REFERENCES resource_type (type_id)
);

CREATE TABLE reservation_change (
  change_id INT PRIMARY KEY,
  reservation_id INT NOT NULL,
  staff_id INT NOT NULL,
  change_type TEXT NOT NULL CHECK (change_type IN ('extend','shorten','add_capacity','reduce_capacity','change_type','cancel')),
  old_value TEXT,
  new_value TEXT,
  status TEXT NOT NULL CHECK (status IN ('requested','approved','rejected')),
  extra_charge REAL NOT NULL DEFAULT 0 CHECK (extra_charge >= 0),
  requested_at TEXT NOT NULL,
  FOREIGN KEY (reservation_id) REFERENCES reservation (reservation_id),
  FOREIGN KEY (staff_id) REFERENCES staff (staff_id)
);

CREATE TABLE deployment (
  deployment_id INT PRIMARY KEY,
  reservation_id INT NOT NULL,
  deployment_name TEXT NOT NULL,
  scaling_mode TEXT NOT NULL CHECK (scaling_mode IN ('fixed','auto','manual')),
  priority_level INT NOT NULL CHECK (priority_level BETWEEN 1 AND 5),
  is_confidential INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  FOREIGN KEY (reservation_id) REFERENCES reservation (reservation_id)
);

CREATE TABLE deployment_resource (
  deployment_resource_id INT PRIMARY KEY,
  deployment_id INT NOT NULL,
  resource_id INT NOT NULL,
  added_at TEXT NOT NULL,
  removed_at TEXT,
  reason TEXT NOT NULL CHECK (reason IN ('initial','scale_up','replacement','migration')),
  CHECK (removed_at > added_at),
  FOREIGN KEY (deployment_id) REFERENCES deployment (deployment_id),
  FOREIGN KEY (resource_id) REFERENCES resource (resource_id)
);

CREATE TABLE resource_assignment (
  assignment_id INT PRIMARY KEY,
  reservation_id INT NOT NULL,
  resource_id INT,
  group_id INT,
  staff_id INT NOT NULL,
  assigned_from TEXT NOT NULL,
  assigned_to TEXT NOT NULL,
  replaces_assignment_id INT,
  reason TEXT NOT NULL CHECK (reason IN ('initial','failover','maintenance','upgrade','capacity_add')),
  CHECK (assigned_to > assigned_from),
  -- Milestone 1 fix: an assignment targets exactly one of a resource or a resource group
  CHECK ((resource_id IS NULL) <> (group_id IS NULL)),
  FOREIGN KEY (reservation_id) REFERENCES reservation (reservation_id),
  FOREIGN KEY (resource_id) REFERENCES resource (resource_id),
  FOREIGN KEY (group_id) REFERENCES resource_group (group_id),
  FOREIGN KEY (staff_id) REFERENCES staff (staff_id),
  FOREIGN KEY (replaces_assignment_id) REFERENCES resource_assignment (assignment_id)
);

CREATE TABLE deployment_event (
  event_id INT PRIMARY KEY,
  deployment_id INT NOT NULL,
  user_id INT,
  staff_id INT,
  event_type TEXT NOT NULL CHECK (event_type IN ('create','start','stop','scale_up','scale_down','config_change','access','restart','failover','delete')),
  auth_method TEXT NOT NULL CHECK (auth_method IN ('password','mfa','sso','api_key','staff_console')),
  event_time TEXT NOT NULL,
  notes TEXT,
  CHECK ((user_id IS NULL) <> (staff_id IS NULL)),
  FOREIGN KEY (deployment_id) REFERENCES deployment (deployment_id),
  FOREIGN KEY (user_id) REFERENCES client_user (user_id),
  FOREIGN KEY (staff_id) REFERENCES staff (staff_id)
);

CREATE TABLE usage_record (
  usage_id INT PRIMARY KEY,
  deployment_id INT NOT NULL,
  resource_id INT,
  rate_id INT,
  service_id INT,
  period_start TEXT NOT NULL,
  period_end TEXT NOT NULL,
  quantity REAL NOT NULL CHECK (quantity >= 0),
  is_estimate INTEGER NOT NULL DEFAULT 0,
  amount REAL NOT NULL,
  charge_status TEXT NOT NULL CHECK (charge_status IN ('pending','billed','disputed','waived')),
  recorded_at TEXT NOT NULL,
  CHECK ((rate_id IS NULL) <> (service_id IS NULL)),
  CHECK (rate_id IS NULL OR resource_id IS NOT NULL),
  -- Milestone 1 fix: a service charge is not tied to a resource
  CHECK (service_id IS NULL OR resource_id IS NULL),
  CHECK (period_end > period_start),
  FOREIGN KEY (deployment_id) REFERENCES deployment (deployment_id),
  FOREIGN KEY (resource_id) REFERENCES resource (resource_id),
  FOREIGN KEY (rate_id) REFERENCES rate (rate_id),
  FOREIGN KEY (service_id) REFERENCES service (service_id)
);

CREATE TABLE adjustment (
  adjustment_id INT PRIMARY KEY,
  deployment_id INT NOT NULL,
  staff_id INT NOT NULL,
  assignment_id INT,
  adjustment_type TEXT NOT NULL CHECK (adjustment_type IN ('sla_credit','goodwill_credit','change_fee','correction','manual_charge')),
  reason TEXT NOT NULL,
  amount REAL NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (deployment_id) REFERENCES deployment (deployment_id),
  FOREIGN KEY (staff_id) REFERENCES staff (staff_id),
  FOREIGN KEY (assignment_id) REFERENCES resource_assignment (assignment_id)
);

CREATE TABLE invoice (
  invoice_id INT PRIMARY KEY,
  billing_account_id INT NOT NULL,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  due_date DATE NOT NULL,
  total_amount REAL NOT NULL,
  amount_paid REAL NOT NULL DEFAULT 0,
  paid_date DATE,
  status TEXT NOT NULL CHECK (status IN ('issued','paid','partial','overdue')),
  UNIQUE (billing_account_id, period_start),
  CHECK (period_end >= period_start AND due_date >= period_end),
  CHECK (amount_paid >= 0 AND amount_paid <= total_amount),
  FOREIGN KEY (billing_account_id) REFERENCES billing_account (billing_account_id)
);

CREATE VIEW deployment_owner AS
SELECT d.deployment_id, r.reservation_id, r.project_id, r.region_id, t.client_id
FROM deployment d
JOIN reservation r ON r.reservation_id = d.reservation_id
JOIN project p ON p.project_id = r.project_id
JOIN team t ON t.team_id = p.team_id;
