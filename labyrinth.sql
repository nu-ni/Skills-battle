CREATE TABLE mazes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  creator VARCHAR(255),
  size INT,
  difficulty INT,
  remark TEXT,
  data TEXT,
  solution TEXT,
  solution_length INT,
  created_at DATETIME
);

