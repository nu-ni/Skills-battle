// app/javascript/application.js
document.addEventListener('DOMContentLoaded', function () {
    console.log("Maze game initialized");
    const mazeGrid = document.getElementById('maze-grid');
    const mazeId = mazeGrid.dataset.mazeId;
    const resetButton = document.getElementById('reset-game');
    const autoSolveButton = document.getElementById('auto-solve');
    const statusMessage = document.getElementById('status-message');
    const stepsCounter = document.getElementById('steps-counter');
    const editButton = document.getElementById('edit-maze');
    const deleteButton = document.getElementById('delete-maze');


    const stepsModal = document.getElementById('steps-modal');
    const modalClose = document.getElementById('modal-close');
    const resumeGameButton = document.getElementById('resume-game');
    const modalStepsCounter = document.getElementById('modal-steps-counter');

    resumeGameButton.addEventListener('click', () => {
        gameActive = true;
        stepsModal.style.display = "none";
    });

    let grid = [];
    let playerPos = null;
    let endPos = null;
    let steps = 0;
    let gameActive = true;
    let playerPath = [];
    let settingStart = false;
    let settingEnd = false;

    initializeGrid();

    document.addEventListener('keydown', handleKeyPress);
    mazeGrid.addEventListener('click', handleCellClick);
    resetButton.addEventListener('click', resetGame);
    autoSolveButton.addEventListener('click', autoSolve);

    if (editButton) editButton.addEventListener('click', editMaze);
    if (deleteButton) deleteButton.addEventListener('click', deleteMaze);

    function initializeGrid() {
        grid = [];
        const rows = mazeGrid.querySelectorAll('.maze-row');

        rows.forEach((row, y) => {
            const gridRow = [];
            const cells = row.querySelectorAll('.maze-cell');

            cells.forEach((cell, x) => {
                const cellType = cell.dataset.type;
                gridRow.push(cellType);

                if (cellType === 'S') {
                    playerPos = [y, x];
                    playerPath = [[y, x]];
                } else if (cellType === 'E') {
                    endPos = [y, x];
                }
            });

            grid.push(gridRow);
        });

        if (playerPos && endPos) {
            updatePlayerPosition(playerPos[0], playerPos[1]);
        } else {
            gameActive = false;
            statusMessage.textContent = "Bitte wähle einen Startpunkt (S) und einen Endpunkt (E), indem du zwei freie Felder anklickst.";
            statusMessage.style.color = 'orange';
            settingStart = true;
        }
    }

    function handleKeyPress(event) {
        if (!gameActive || !Array.isArray(playerPos)) return;

        const key = event.key;
        const [y, x] = playerPos;
        let newY = y, newX = x;

        switch (key) {
            case 'ArrowUp': newY = y - 1; break;
            case 'ArrowDown': newY = y + 1; break;
            case 'ArrowLeft': newX = x - 1; break;
            case 'ArrowRight': newX = x + 1; break;
            default: return;
        }

        movePlayer(newY, newX);
    }

    function handleCellClick(event) {
        const cell = event.target.closest('.maze-cell');
        if (!cell) return;

        const y = parseInt(cell.dataset.y);
        const x = parseInt(cell.dataset.x);
        const type = cell.dataset.type;

        if (!gameActive && (settingStart || settingEnd)) {
            if (type === '#' || type === 'S' || type === 'E') return;

            if (settingStart) {
                cell.dataset.type = 'S';
                cell.classList.add('start');
                playerPos = [y, x];
                playerPath = [[y, x]];
                settingStart = false;
                settingEnd = true;
                statusMessage.textContent = "Jetzt wähle einen Endpunkt (E).";
            } else if (settingEnd) {
                cell.dataset.type = 'E';
                cell.classList.add('end');
                endPos = [y, x];
                settingEnd = false;
                gameActive = true;
                updatePlayerPosition(playerPos[0], playerPos[1]);
                statusMessage.textContent = "Bewege dich mit Pfeiltasten oder Mausklick durch das Labyrinth";
                statusMessage.style.color = '';
            }
            return;
        }

        if (!gameActive || !Array.isArray(playerPos)) return;

        const [playerY, playerX] = playerPos;
        const isAdjacent =
            (Math.abs(y - playerY) === 1 && x === playerX) ||
            (Math.abs(x - playerX) === 1 && y === playerY);

        if (isAdjacent) {
            movePlayer(y, x);
        }
    }

    function movePlayer(y, x) {
        if (y < 0 || y >= grid.length || x < 0 || x >= grid[0].length) return;
        if (grid[y][x] === '#') {
            statusMessage.textContent = "Du kannst nicht durch Wände gehen!";
            return;
        }
    
        const [oldY, oldX] = playerPos;
        const oldCell = getCellElement(oldY, oldX);
        oldCell.classList.add('visited');
        oldCell.querySelector('.player')?.remove();
    
        playerPos = [y, x];
        playerPath.push([y, x]);
        steps++;
        stepsCounter.textContent = `Schritte: ${steps}`;
    
        updatePlayerPosition(y, x);
    
        // Überprüfen, ob der Spieler den Endpunkt erreicht hat
        if (grid[y][x] === 'E') {
            gameWon();
        } else if (grid[y][x] === 'S') {
            // Pausiert das Spiel, wenn der Spieler den Startpunkt erreicht
            gameActive = false;
            modalStepsCounter.textContent = steps;  // Zeige die Anzahl der Schritte im Modal an
            stepsModal.style.display = "block";  // Zeige das Modal an
        }
    }    

    function getCellElement(y, x) {
        return document.querySelector(`.maze-cell[data-y="${y}"][data-x="${x}"]`);
    }

    function updatePlayerPosition(y, x) {
        const cell = getCellElement(y, x);
        if (!cell.querySelector('.player')) {
            const player = document.createElement('div');
            player.className = 'player';
            cell.appendChild(player);
        }
        cell.classList.add('current');
    }

    function gameWon() {
        gameActive = false;
        const gameWonMessage = `Gewonnen! Du hast das Labyrinth in ${steps} Schritten gelöst.`;
    
        // Update der Modal-Nachricht
        const modalMessage = document.getElementById('modal-message');
        modalMessage.textContent = gameWonMessage;
    
        // Zeige das Modal an
        const modal = new bootstrap.Modal(document.getElementById('steps-modal'));
        modal.show();
    }

    function resetGame() {
        document.querySelectorAll('.maze-cell').forEach(cell => {
            cell.classList.remove('visited', 'current', 'solution-path');
            cell.querySelector('.player')?.remove();
        });

        steps = 0;
        stepsCounter.textContent = `Schritte: ${steps}`;
        gameActive = true;
        playerPath = [];

        playerPos = findCellPosition('S');
        endPos = findCellPosition('E');

        if (!playerPos || !endPos) {
            statusMessage.textContent = "Bitte setze Start- und Endpunkt (S und E), indem du zwei freie Felder auswählst.";
            statusMessage.style.color = 'orange';
            gameActive = false;
            settingStart = true;
            return;
        }

        playerPath.push(playerPos);
        updatePlayerPosition(playerPos[0], playerPos[1]);
        statusMessage.textContent = "Bewege dich mit Pfeiltasten oder Mausklick durch das Labyrinth";
        statusMessage.style.color = '';
    }

    function findCellPosition(type) {
        for (let y = 0; y < grid.length; y++) {
            for (let x = 0; x < grid[y].length; x++) {
                if (grid[y][x] === type) return [y, x];
            }
        }
        return null;
    }

    function autoSolve() {
        if (!mazeId) {
            console.error("Maze ID ist nicht verfügbar.");
            statusMessage.textContent = "Fehler: Labyrinth-ID fehlt.";
            statusMessage.style.color = 'red';
            return;
        }
    
        if (!playerPos || !endPos) {
            statusMessage.textContent = "Bitte setze Start- und Endpunkt im Labyrinth.";
            statusMessage.style.color = 'red';
            return;
        }
    
        autoSolveButton.disabled = true;
        autoSolveButton.textContent = "Lösung wird gesucht...";
    
        const dataToSend = {
            start: playerPos,  // z.B. [y, x]
            end: endPos         // z.B. [y, x]
        };
    
        console.log('Daten, die gesendet werden:', JSON.stringify(dataToSend));  // Debugging: Überprüfe die gesendeten Daten
    
        fetch(`/mazes/${mazeId}/solve`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',  // Wichtig für die korrekte Formatierung
                'Accept': 'application/json'
            },
            body: JSON.stringify(dataToSend)  // Der JSON-Body wird hier gesendet
        })
        .then(response => {
            if (!response.ok) {
                throw new Error(`Serverfehler: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            if (data.success) {
                showSolution(data.path);
                statusMessage.textContent = `Auto-Lösung gefunden: ${data.solution_length} Schritte`;
                statusMessage.style.color = 'blue';
            } else {
                statusMessage.textContent = data.message || "Fehler beim Lösen des Labyrinths";
                statusMessage.style.color = 'red';
            }
        })
        .catch(error => {
            console.error('Fehler beim Abrufen:', error);
            statusMessage.textContent = `Fehler beim Abrufen der Lösung: ${error.message}`;
            statusMessage.style.color = 'red';
        });
    }    
    
    function showSolution(path) {
        document.querySelectorAll('.maze-cell').forEach(cell => {
            cell.classList.remove('solution-path');
        });

        path.forEach(([y, x]) => {
            const cell = getCellElement(y, x);
            cell.classList.add('solution-path');
        });
    }

    function editMaze() {
        window.location.href = `/mazes/${mazeId}/edit`;
    }

    function deleteMaze() {
        if (confirm('Bist du sicher, dass du dieses Labyrinth löschen möchtest?')) {
            fetch(`/mazes/${mazeId}`, {
                method: 'DELETE',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Labyrinth erfolgreich gelöscht!');
                    window.location.href = '/mazes';
                } else {
                    alert(data.message || 'Fehler beim Löschen');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Fehler beim Löschen des Labyrinths');
            });
        }
    }
});
