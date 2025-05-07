CREATE TABLE `mazes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `creator` VARCHAR(255),
  `size` INT,
  `difficulty` INT,
  `remark` TEXT,
  `data` TEXT,
  `solution` TEXT,
  `solution_length` INT,
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NOT NULL,
  INDEX(`created_at`),
  INDEX(`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- wurde nicht getetstet, besser readme beachten
