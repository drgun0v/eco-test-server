DROP TABLE IF EXISTS agriculture_fields; -- We are replacing the old system

CREATE TABLE IF NOT EXISTS agriculture_plants (
    field_id    VARCHAR(64) NOT NULL,
    plant_index INT NOT NULL,           -- 1 to 10
    stage       TINYINT NOT NULL DEFAULT 0, -- 0=Empty, 1=Bucket, 2=Growing, 3=Ready
    planted_at  INT NOT NULL DEFAULT 0,
    PRIMARY KEY (field_id, plant_index)
);