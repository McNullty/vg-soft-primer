CREATE TABLE items (
   uuid UUID NOT NULL PRIMARY KEY,
   description VARCHAR(100) NOT NULL,
   name VARCHAR(100) NOT NULL,
   version INTEGER DEFAULT 0
);

GRANT SELECT, INSERT, UPDATE (description, name, version), DELETE ON items TO vguser;