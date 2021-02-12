--==Para saber que queries correr es necesario revisar el README

-- 1.2.1
ALTER USER erobles WITH PASSWORD 'erobles123456';

-- 2.1
SELECT entid, nom_ent, geom FROM estados LIMIT 1;
SELECT munid, nom_mun, nom_ent, geom FROM municipios LIMIT 1;
SELECT anpid, nombre, cat_manejo, geom FROM anp LIMIT 1;
SELECT gid, desecon3, geom FROM ecorregiones LIMIT 1;  -- aun no se ocupa
SELECT idejemplar, idnombrecatvalido, especievalidabusqueda, comentarioscatvalido, entid, munid, anpid, ecorid, latitud, 
longitud, localidad, municipiomapa, estadomapa, paismapa, categoriataxonomica, fechacolecta, colector, coleccion, probablelocnodecampo, 
ejemplarfosil, institucion, paiscoleccion, proyecto, urlproyecto, urlejemplar, urlorigen FROM snib LIMIT 1;

-- 2.1.1
ALTER TABLE anp RENAME COLUMN gid TO anpid;

-- 3.
SELECT idejemplar, idnombrecatvalido, especievalidabusqueda, comentarioscatvalido, entid, munid, anpid, ecorid, latitud, 
longitud, localidad, municipiomapa, estadomapa, paismapa, categoriataxonomica, fechacolecta, colector, coleccion, probablelocnodecampo, 
ejemplarfosil, institucion, paiscoleccion, proyecto, urlproyecto, urlejemplar, urlorigen
INTO TABLE snib_ev 
FROM snib 
WHERE idnombrecatvalido <> '' AND especievalidabusqueda <> '' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%';

-- 4.
ALTER TABLE snib_ev ADD COLUMN id SERIAL PRIMARY KEY;

-- 5.
CREATE INDEX idx_snib_ev_idnombrecatvalido ON snib_ev USING btree (idnombrecatvalido);
CREATE INDEX idx_snib_ev_entid ON snib_ev USING btree (entid);
CREATE INDEX idx_snib_ev_munid ON snib_ev USING btree (munid);
CREATE INDEX idx_snib_ev_anpid ON snib_ev USING btree (anpid);
CREATE INDEX idx_snib_ev_ecorid ON snib_ev USING btree (ecorid);
CREATE INDEX idx_snib_ev_categoriataxonomica ON snib_ev USING btree (categoriataxonomica);
CREATE INDEX idx_snib_ev_coleccion ON snib_ev USING btree (coleccion);
CREATE INDEX idx_snib_ev_probablelocnodecampo ON snib_ev USING btree (probablelocnodecampo);
CREATE INDEX idx_snib_ev_ejemplarfosil ON snib_ev USING btree (ejemplarfosil);

-- 6.1
ALTER TABLE snib_ev ADD COLUMN tipocoleccion smallint NOT NULL DEFAULT 1;

-- 6.2
UPDATE snib_ev SET tipocoleccion=2 WHERE coleccion IN ('eBird eBird', 'aVerAves aVerAves');
UPDATE snib_ev SET tipocoleccion=3 WHERE ejemplarfosil='SI';
UPDATE snib_ev SET tipocoleccion=4 WHERE probablelocnodecampo='SI';
UPDATE snib_ev SET tipocoleccion=5 WHERE coleccion='Naturalista Naturalista';

-- 6.3
ALTER TABLE snib_ev ADD COLUMN idnombrecatvalidoespecie character varying(50);

-- 6.4
UPDATE snib_ev SET idnombrecatvalidoespecie = idnombrecatvalido;

-- 6.5
CREATE INDEX idx_snib_ev_idnombrecatvalidoespecie ON snib_ev USING btree (idnombrecatvalidoespecie);

-- 7.
ALTER TABLE snib RENAME TO snib_orig;
ALTER TABLE snib_ev RENAME TO snib;

-- 11.
DROP DATABASE geoportal;

-- 12.
ALTER DATABASE geoportal_tmp RENAME TO geoportal;