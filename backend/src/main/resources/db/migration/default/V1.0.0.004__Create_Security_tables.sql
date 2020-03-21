CREATE TABLE users (
    user_uuid UUID NOT NULL PRIMARY KEY ,
    email VARCHAR(255) NOT NULL,
    enabled BOOLEAN NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    locked BOOLEAN NOT NULL,
    password VARCHAR(255) NOT NULL,
    UNIQUE(email)
);

GRANT SELECT, INSERT, UPDATE (email, enabled, first_name, last_name, locked, password), DELETE ON users TO vguser;

CREATE TABLE authorities (
    authority_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    UNIQUE(name)
);

GRANT SELECT, INSERT, UPDATE (name), DELETE ON authorities TO vguser;
GRANT USAGE, SELECT ON SEQUENCE authorities_authority_id_seq TO vguser;

CREATE TABLE user_authorities (
    user_uuid UUID NOT NULL,
    authority_id bigint not null,
    PRIMARY KEY (user_uuid, authority_id)
);

GRANT SELECT, INSERT, UPDATE, DELETE ON user_authorities TO vguser;