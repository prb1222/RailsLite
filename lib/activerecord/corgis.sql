CREATE TABLE corgis (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  house_id INTEGER,

  FOREIGN KEY(house_id) REFERENCES human(id)
);

CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL
);

INSERT INTO
  houses (id, address)
VALUES
  (1, "26th and Guerrero"), (2, "Dolores and Market");

INSERT INTO
  humans (id, fname, lname, house_id)
VALUES
  (1, "Peter", "Benavides", 1),
  (2, "Matt", "Rubens", 1),
  (3, "Ned", "Ruggeri", 2),
  (4, "Corgiless", "Human", NULL);

INSERT INTO
  corgis (id, name, description, owner_id)
VALUES
  (1, "Goddard", "Father of rocketry." 1),
  (2, "Maxwell", "Famous for his equations.", 2),
  (3, "Planck", "Now known for little things.", 3),
  (4, "Haber", "Feeds billions every day with his process.",3),
  (5, "Stray Corgi", NULL);
