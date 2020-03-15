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

CREATE TABLE authorities (
    authority_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    UNIQUE(name)
);

CREATE TABLE user_authorities (
    user_uuid UUID NOT NULL,
    authority_id bigint not null,
    PRIMARY KEY (user_uuid, authority_id)
);