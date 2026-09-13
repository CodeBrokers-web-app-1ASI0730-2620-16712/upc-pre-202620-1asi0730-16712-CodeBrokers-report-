-- =====================================================================
-- VitaLink - Esquema relacional (PostgreSQL 16)
-- Un schema por bounded context, segun la seccion 4.6 del informe.
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS iam;
CREATE SCHEMA IF NOT EXISTS elder_care;
CREATE SCHEMA IF NOT EXISTS monitoring;
CREATE SCHEMA IF NOT EXISTS alerting;
CREATE SCHEMA IF NOT EXISTS care_coordination;
CREATE SCHEMA IF NOT EXISTS notification;
CREATE SCHEMA IF NOT EXISTS marketing;


-- ---------------------------------------------------------------------
-- Bounded Context: Identity and Access Management
-- ---------------------------------------------------------------------

CREATE TABLE iam.users (
    id             UUID         NOT NULL,
    email          VARCHAR(255) NOT NULL,
    password_hash  VARCHAR(255) NOT NULL,
    role           VARCHAR(20)  NOT NULL,
    is_verified    BOOLEAN      NOT NULL DEFAULT FALSE,
    is_active      BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    last_access_at TIMESTAMPTZ,

    CONSTRAINT pk_users              PRIMARY KEY (id),
    CONSTRAINT uq_users_email        UNIQUE (email),
    CONSTRAINT ck_users_role         CHECK (role IN ('OLDER_ADULT','FAMILY_CAREGIVER','CARE_PROVIDER')),
    CONSTRAINT ck_users_email_format CHECK (email ~* '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'),
    CONSTRAINT ck_users_last_access  CHECK (last_access_at IS NULL OR last_access_at >= created_at)
);


-- ---------------------------------------------------------------------
-- Bounded Context: Elder Care
-- ---------------------------------------------------------------------

CREATE TABLE elder_care.care_providers (
    id          UUID         NOT NULL,
    user_id     UUID         NOT NULL,
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    specialty   VARCHAR(120) NOT NULL,
    institution VARCHAR(160),
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_care_providers      PRIMARY KEY (id),
    CONSTRAINT uq_care_providers_user UNIQUE (user_id),
    CONSTRAINT fk_care_providers_user FOREIGN KEY (user_id)
        REFERENCES iam.users (id) ON DELETE RESTRICT
);

CREATE TABLE elder_care.family_caregivers (
    id              UUID         NOT NULL,
    user_id         UUID         NOT NULL,
    first_name      VARCHAR(100) NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    phone_number    VARCHAR(20)  NOT NULL,
    alternate_phone VARCHAR(20),
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_family_caregivers      PRIMARY KEY (id),
    CONSTRAINT uq_family_caregivers_user UNIQUE (user_id),
    CONSTRAINT fk_family_caregivers_user FOREIGN KEY (user_id)
        REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT ck_family_caregivers_phone
        CHECK (phone_number ~ '^[0-9+() -]{7,20}$'),
    CONSTRAINT ck_family_caregivers_alt_phone
        CHECK (alternate_phone IS NULL OR alternate_phone ~ '^[0-9+() -]{7,20}$')
);

CREATE TABLE elder_care.older_adults (
    id                      UUID         NOT NULL,
    user_id                 UUID,
    first_name              VARCHAR(100) NOT NULL,
    last_name               VARCHAR(100) NOT NULL,
    birth_date              DATE         NOT NULL,
    address_street          VARCHAR(160),
    address_district        VARCHAR(80),
    address_city            VARCHAR(80),
    emergency_contact_name  VARCHAR(160),
    emergency_contact_phone VARCHAR(20),
    assigned_provider_id    UUID,
    is_monitoring_active    BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at              TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_older_adults          PRIMARY KEY (id),
    CONSTRAINT uq_older_adults_user     UNIQUE (user_id),
    CONSTRAINT fk_older_adults_user     FOREIGN KEY (user_id)
        REFERENCES iam.users (id) ON DELETE SET NULL,
    CONSTRAINT fk_older_adults_provider FOREIGN KEY (assigned_provider_id)
        REFERENCES elder_care.care_providers (id) ON DELETE SET NULL,
    CONSTRAINT ck_older_adults_phone
        CHECK (emergency_contact_phone IS NULL OR emergency_contact_phone ~ '^[0-9+() -]{7,20}$'),

    -- US-21: el seguimiento no puede activarse con el perfil incompleto.
    CONSTRAINT ck_older_adults_monitoring_requires_complete_profile CHECK (
        is_monitoring_active = FALSE OR (
            address_street          IS NOT NULL AND
            address_district        IS NOT NULL AND
            address_city            IS NOT NULL AND
            emergency_contact_name  IS NOT NULL AND
            emergency_contact_phone IS NOT NULL
        )
    )
);

CREATE TABLE elder_care.caregiver_assignments (
    id                      UUID        NOT NULL,
    older_adult_id          UUID        NOT NULL,
    family_caregiver_id     UUID        NOT NULL,
    relationship            VARCHAR(30) NOT NULL,
    is_emergency_authorized BOOLEAN     NOT NULL DEFAULT FALSE,
    assigned_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    revoked_at              TIMESTAMPTZ,

    CONSTRAINT pk_caregiver_assignments PRIMARY KEY (id),
    CONSTRAINT fk_ca_older_adult FOREIGN KEY (older_adult_id)
        REFERENCES elder_care.older_adults (id) ON DELETE CASCADE,
    CONSTRAINT fk_ca_caregiver FOREIGN KEY (family_caregiver_id)
        REFERENCES elder_care.family_caregivers (id) ON DELETE RESTRICT,
    CONSTRAINT ck_ca_relationship CHECK (
        relationship IN ('SON_OR_DAUGHTER','SPOUSE','SIBLING','PROFESSIONAL_CAREGIVER','OTHER')),
    CONSTRAINT ck_ca_revoked_after_assigned CHECK (revoked_at IS NULL OR revoked_at > assigned_at)
);

-- Un mismo familiar no puede tener dos asignaciones vigentes sobre el mismo adulto mayor.
CREATE UNIQUE INDEX uq_ca_active_assignment
    ON elder_care.caregiver_assignments (older_adult_id, family_caregiver_id)
    WHERE revoked_at IS NULL;


-- ---------------------------------------------------------------------
-- Bounded Context: Preventive Monitoring
-- ---------------------------------------------------------------------

CREATE TABLE monitoring.record_types (
    code            VARCHAR(30) NOT NULL,
    display_name    VARCHAR(80) NOT NULL,
    unit            VARCHAR(20),
    min_valid_value NUMERIC(10,2),
    max_valid_value NUMERIC(10,2),
    requires_value  BOOLEAN     NOT NULL DEFAULT TRUE,
    is_active       BOOLEAN     NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_record_types PRIMARY KEY (code),
    CONSTRAINT ck_record_types_range CHECK (
        min_valid_value IS NULL OR max_valid_value IS NULL OR min_valid_value < max_valid_value),
    CONSTRAINT ck_record_types_unit CHECK (requires_value = FALSE OR unit IS NOT NULL)
);

CREATE TABLE monitoring.health_records (
    id                UUID          NOT NULL,
    older_adult_id    UUID          NOT NULL,
    record_type_code  VARCHAR(30)   NOT NULL,
    measurement_value NUMERIC(10,2),
    note              TEXT,
    source            VARCHAR(20)   NOT NULL,
    recorded_by       UUID          NOT NULL,
    recorded_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_health_records PRIMARY KEY (id),
    CONSTRAINT fk_hr_older_adult FOREIGN KEY (older_adult_id)
        REFERENCES elder_care.older_adults (id) ON DELETE CASCADE,
    CONSTRAINT fk_hr_record_type FOREIGN KEY (record_type_code)
        REFERENCES monitoring.record_types (code) ON DELETE RESTRICT,
    CONSTRAINT fk_hr_recorded_by FOREIGN KEY (recorded_by)
        REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT ck_hr_source CHECK (source IN ('OLDER_ADULT','FAMILY_CAREGIVER','CARE_PROVIDER')),
    CONSTRAINT ck_hr_value_or_note CHECK (measurement_value IS NOT NULL OR note IS NOT NULL),
    CONSTRAINT ck_hr_value_non_negative CHECK (measurement_value IS NULL OR measurement_value >= 0)
);

-- US-11 y US-17: historial en orden cronologico descendente y por rango de fechas.
CREATE INDEX ix_hr_older_adult_recorded_at
    ON monitoring.health_records (older_adult_id, recorded_at DESC);
CREATE INDEX ix_hr_older_adult_type
    ON monitoring.health_records (older_adult_id, record_type_code, recorded_at DESC);

CREATE TABLE monitoring.monitoring_rules (
    id               UUID          NOT NULL,
    older_adult_id   UUID          NOT NULL,
    record_type_code VARCHAR(30)   NOT NULL,
    min_value        NUMERIC(10,2),
    max_value        NUMERIC(10,2),
    severity         VARCHAR(10)   NOT NULL,
    is_active        BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_monitoring_rules PRIMARY KEY (id),
    CONSTRAINT fk_mr_older_adult FOREIGN KEY (older_adult_id)
        REFERENCES elder_care.older_adults (id) ON DELETE CASCADE,
    CONSTRAINT fk_mr_record_type FOREIGN KEY (record_type_code)
        REFERENCES monitoring.record_types (code) ON DELETE RESTRICT,
    CONSTRAINT ck_mr_severity CHECK (severity IN ('HIGH','MEDIUM','LOW')),
    CONSTRAINT ck_mr_at_least_one_bound CHECK (min_value IS NOT NULL OR max_value IS NOT NULL),
    CONSTRAINT ck_mr_bounds_consistent CHECK (
        min_value IS NULL OR max_value IS NULL OR min_value <= max_value)
);

-- Evita dos reglas activas equivalentes para el mismo adulto mayor y tipo de registro.
CREATE UNIQUE INDEX uq_mr_active_rule
    ON monitoring.monitoring_rules (older_adult_id, record_type_code, severity)
    WHERE is_active;


-- ---------------------------------------------------------------------
-- Bounded Context: Alerting
-- ---------------------------------------------------------------------

CREATE TABLE alerting.alerts (
    id                    UUID        NOT NULL,
    older_adult_id        UUID        NOT NULL,
    health_record_id      UUID        NOT NULL,
    monitoring_rule_id    UUID        NOT NULL,
    assigned_provider_id  UUID,
    severity              VARCHAR(10) NOT NULL,
    status                VARCHAR(15) NOT NULL DEFAULT 'PENDING',
    raised_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_status_change_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_alerts PRIMARY KEY (id),
    -- US-15: un registro de salud origina como maximo una alerta.
    CONSTRAINT uq_alerts_health_record UNIQUE (health_record_id),
    CONSTRAINT fk_alerts_older_adult FOREIGN KEY (older_adult_id)
        REFERENCES elder_care.older_adults (id) ON DELETE CASCADE,
    CONSTRAINT fk_alerts_health_record FOREIGN KEY (health_record_id)
        REFERENCES monitoring.health_records (id) ON DELETE CASCADE,
    CONSTRAINT fk_alerts_monitoring_rule FOREIGN KEY (monitoring_rule_id)
        REFERENCES monitoring.monitoring_rules (id) ON DELETE RESTRICT,
    CONSTRAINT fk_alerts_provider FOREIGN KEY (assigned_provider_id)
        REFERENCES elder_care.care_providers (id) ON DELETE SET NULL,
    CONSTRAINT ck_alerts_severity CHECK (severity IN ('HIGH','MEDIUM','LOW')),
    CONSTRAINT ck_alerts_status CHECK (status IN ('PENDING','IN_REVIEW','ATTENDED','CLOSED')),
    CONSTRAINT ck_alerts_status_change CHECK (last_status_change_at >= raised_at)
);

-- US-08 y US-09: conteo de pendientes y ordenamiento por gravedad.
CREATE INDEX ix_alerts_provider_status_severity
    ON alerting.alerts (assigned_provider_id, status, severity);
CREATE INDEX ix_alerts_older_adult_raised_at
    ON alerting.alerts (older_adult_id, raised_at DESC);

CREATE TABLE alerting.alert_status_changes (
    id          UUID        NOT NULL,
    alert_id    UUID        NOT NULL,
    from_status VARCHAR(15) NOT NULL,
    to_status   VARCHAR(15) NOT NULL,
    changed_by  UUID        NOT NULL,
    changed_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_alert_status_changes PRIMARY KEY (id),
    CONSTRAINT uq_asc_alert_changed_at UNIQUE (alert_id, changed_at),
    CONSTRAINT fk_asc_alert FOREIGN KEY (alert_id)
        REFERENCES alerting.alerts (id) ON DELETE CASCADE,
    CONSTRAINT fk_asc_changed_by FOREIGN KEY (changed_by)
        REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT ck_asc_from_status CHECK (from_status IN ('PENDING','IN_REVIEW','ATTENDED','CLOSED')),
    CONSTRAINT ck_asc_to_status   CHECK (to_status   IN ('PENDING','IN_REVIEW','ATTENDED','CLOSED')),
    CONSTRAINT ck_asc_different_status CHECK (from_status <> to_status)
);

CREATE INDEX ix_asc_alert_changed_at
    ON alerting.alert_status_changes (alert_id, changed_at DESC);


-- ---------------------------------------------------------------------
-- Bounded Context: Care Coordination
-- ---------------------------------------------------------------------

CREATE TABLE care_coordination.care_records (
    id                     UUID        NOT NULL,
    alert_id               UUID        NOT NULL,
    care_provider_id       UUID        NOT NULL,
    attended_by            UUID        NOT NULL,
    observation_text       TEXT,
    observation_written_at TIMESTAMPTZ,
    outcome                VARCHAR(30) NOT NULL,
    attended_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_care_records PRIMARY KEY (id),
    CONSTRAINT uq_cr_alert_attendant UNIQUE (alert_id, attended_by, attended_at),
    CONSTRAINT fk_cr_alert FOREIGN KEY (alert_id)
        REFERENCES alerting.alerts (id) ON DELETE CASCADE,
    CONSTRAINT fk_cr_provider FOREIGN KEY (care_provider_id)
        REFERENCES elder_care.care_providers (id) ON DELETE RESTRICT,
    CONSTRAINT fk_cr_attended_by FOREIGN KEY (attended_by)
        REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT ck_cr_outcome CHECK (outcome IN (
        'RESOLVED_REMOTELY','IN_PERSON_VISIT_SCHEDULED','REFERRED_TO_EMERGENCY','NO_ACTION_REQUIRED')),
    -- US-13: la observacion es opcional, pero texto y fecha van juntos o no van.
    CONSTRAINT ck_cr_observation_pairing CHECK (
        (observation_text IS NULL) = (observation_written_at IS NULL)),
    CONSTRAINT ck_cr_observation_length CHECK (
        observation_text IS NULL OR char_length(observation_text) BETWEEN 1 AND 1000)
);

CREATE INDEX ix_cr_alert ON care_coordination.care_records (alert_id, attended_at DESC);


-- ---------------------------------------------------------------------
-- Bounded Context: Notification
-- ---------------------------------------------------------------------

CREATE TABLE notification.notifications (
    id                  UUID         NOT NULL,
    recipient_id        UUID         NOT NULL,
    related_alert_id    UUID,
    channel             VARCHAR(10)  NOT NULL,
    subject             VARCHAR(200) NOT NULL,
    body                TEXT         NOT NULL,
    status              VARCHAR(10)  NOT NULL DEFAULT 'PENDING',
    attempts            SMALLINT     NOT NULL DEFAULT 0,
    provider_message_id VARCHAR(120),
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    sent_at             TIMESTAMPTZ,
    failure_reason      VARCHAR(300),

    CONSTRAINT pk_notifications PRIMARY KEY (id),
    CONSTRAINT fk_n_recipient FOREIGN KEY (recipient_id)
        REFERENCES iam.users (id) ON DELETE CASCADE,
    CONSTRAINT fk_n_alert FOREIGN KEY (related_alert_id)
        REFERENCES alerting.alerts (id) ON DELETE SET NULL,
    CONSTRAINT ck_n_channel CHECK (channel IN ('EMAIL','SMS')),
    CONSTRAINT ck_n_status  CHECK (status IN ('PENDING','SENT','FAILED')),
    CONSTRAINT ck_n_attempts CHECK (attempts BETWEEN 0 AND 5),
    CONSTRAINT ck_n_sent_pairing    CHECK ((status = 'SENT')   = (sent_at IS NOT NULL)),
    CONSTRAINT ck_n_failure_pairing CHECK ((status = 'FAILED') = (failure_reason IS NOT NULL)),
    CONSTRAINT ck_n_receipt CHECK (status <> 'SENT' OR provider_message_id IS NOT NULL),
    CONSTRAINT ck_n_sent_after_created CHECK (sent_at IS NULL OR sent_at >= created_at)
);

CREATE INDEX ix_n_recipient_created ON notification.notifications (recipient_id, created_at DESC);
CREATE INDEX ix_n_retryable ON notification.notifications (status, attempts) WHERE status = 'FAILED';


-- ---------------------------------------------------------------------
-- Bounded Context: Marketing
-- ---------------------------------------------------------------------

CREATE TABLE marketing.contact_requests (
    id          UUID         NOT NULL,
    full_name   VARCHAR(160) NOT NULL,
    email       VARCHAR(255) NOT NULL,
    specialty   VARCHAR(120),
    segment     VARCHAR(20)  NOT NULL,
    message     TEXT,
    status      VARCHAR(12)  NOT NULL DEFAULT 'PENDING',
    received_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    attended_at TIMESTAMPTZ,

    CONSTRAINT pk_contact_requests PRIMARY KEY (id),
    CONSTRAINT ck_contact_segment CHECK (segment IN ('CARE_PROVIDER','FAMILY_CAREGIVER')),
    CONSTRAINT ck_contact_status  CHECK (status IN ('PENDING','ATTENDED','DISCARDED')),
    CONSTRAINT ck_contact_email_format
        CHECK (email ~* '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'),
    CONSTRAINT ck_contact_attended_pairing CHECK ((status = 'ATTENDED') = (attended_at IS NOT NULL)),
    -- US-03: la especialidad solo aplica al visitante profesional de salud.
    CONSTRAINT ck_contact_specialty_scope CHECK (segment = 'CARE_PROVIDER' OR specialty IS NULL),
    CONSTRAINT ck_contact_attended_after_received
        CHECK (attended_at IS NULL OR attended_at >= received_at)
);

CREATE INDEX ix_contact_status_received ON marketing.contact_requests (status, received_at DESC);
CREATE INDEX ix_contact_email_received ON marketing.contact_requests (email, received_at DESC);
