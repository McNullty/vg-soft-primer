CREATE TABLE items (
   uuid UUID NOT NULL PRIMARY KEY,
   description VARCHAR(100) NOT NULL,
   name VARCHAR(100) NOT NULL
);

GRANT SELECT, INSERT, UPDATE (description, name), DELETE ON items TO vguser;