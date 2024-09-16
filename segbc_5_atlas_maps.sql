


################################
-- make atlas coverage
DROP TABLE IF EXISTS segbc_atlas;
CREATE TABLE segbc_atlas AS
  (WITH grid AS
    (SELECT
      row_number() over () AS id,
      ST_SetSRID(geom, 3308) AS geom
    FROM
        (SELECT
          (ST_SquareGrid(40000, ST_Transform(geom, 3308))).* AS atlas_grid
        FROM segbc_study_area
        )grid
    )
  SELECT DISTINCT
    grid.*
  FROM grid
  JOIN segbc_study_area ON ST_Intersects(grid.geom, ST_Transform(segbc_study_area.geom, 3308))
  )
;

-- display prioritisation permutations
DROP VIEW IF EXISTS segbc_prioritisation_display;
CREATE VIEW segbc_prioritisation_display AS
SELECT
  row_number() over () AS id,
  segbc_prioritisation.value,
  segbc_prioritisation_lut.*,
  segbc_prioritisation.geom
FROM segbc_prioritisation
JOIN segbc_prioritisation_lut ON segbc_prioritisation.value = segbc_prioritisation_lut.original_value
;

