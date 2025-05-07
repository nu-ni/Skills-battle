# Maze Game App

Dieses Projekt ist eine interaktive Labyrinth-Spiel-App, die in Ruby on Rails entwickelt wurde. Benutzer können Labyrinthe erstellen, spielen und Lösungen für ihre Labyrinthe erhalten. Es bietet eine benutzerfreundliche Oberfläche mit Funktionen wie Start- und Endpunktsetzung sowie einer Auto-Solve-Option.

## Voraussetzungen

* **Ruby** (Version 3.1 oder höher)
* **Rails** (Version 8.x oder höher)
* **MySQL oder PostgreSQL** (je nach Konfiguration der Datenbank)
* **Node.js** (für die Verwaltung von JavaScript und Styles)
* **Yarn** (für das Verwalten von Frontend-Abhängigkeiten)

## Installation

### 1. Abhängigkeiten installieren

Stelle sicher, dass du alle benötigten Ruby-Gems und JavaScript-Abhängigkeiten installierst:

```bash
bundle install       # Installiert Ruby-Abhängigkeiten
```

### 2. Datenbank konfigurieren

Die App verwendet eine relationale Datenbank, um Labyrinth-Daten zu speichern. Du kannst die Datenbank konfigurieren und die notwendigen Tabellen erstellen, indem du folgende Befehle ausführst:

```bash
rails db:create       # Erstellt die Datenbank
rails db:migrate      # Führt alle Migrationen aus
rails db:seed         # Füllt die Datenbank mit Testdaten (optional)
```

Stelle sicher, dass die Datei `config/database.yml` korrekt konfiguriert ist, um die Verbindung zu deiner Datenbank herzustellen.

### 3. Starten der Rails-Server

Starte den Rails-Server, um die App lokal zu verwenden:

```bash
rails server
```

Die App wird nun unter `http://localhost:3000` verfügbar sein.

## Abhängigkeiten

* **Ruby on Rails 8.x**
* **Bootstrap 5** für das Styling und die Modals
* **JavaScript (Vanilla JS und Bootstrap-Modals)** für das interaktive Labyrinth-Spiel
* **MySQL** oder **PostgreSQL** für die Datenbankverwaltung

## Troubleshooting

* **Rails Server startet nicht**: Stelle sicher, dass du die richtigen Versionen von Ruby, Rails und Node.js verwendest.
* **Datenbankprobleme**: Überprüfe die Datenbankkonfiguration in der Datei `config/database.yml`.
* **Fehlende Abhängigkeiten**: Stelle sicher, dass alle Gems und JavaScript-Abhängigkeiten korrekt installiert sind.
