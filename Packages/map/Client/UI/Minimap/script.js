let knownGameCoords = [
    [0, 0],
    [0, 0],
    [0, 0],
];
let knownImageCoords = [
    [0, 0],
    [0, 0],
    [0, 0],
];
let maxMinimapBlipsCount = 30;
let currentPlayerWorldCoords = { x: 0, y: 0 };

const mapContainer = $(".minimap");
const playerIndicator = $(".minimap .player-indicator");

const mapSize = { width: mapContainer.width(), height: mapContainer.height() };
const minimapSize = { width: 260, height: 260 };

let persistentBlips = [];
let userBlips = [];
let currentPlayerCoords = { x: minimapSize.width / 2, y: minimapSize.height / 2 };
let isMinimapCircular = false;
let showPlayers = true;
let minimapPlayerBlipElements = {};

// Show the minimap
const showMinimap = () => {
    $(".minimap-section").removeClass("hidden");
};

// Hide the minimap
const hideMinimap = () => {
    $(".minimap-section").addClass("hidden");
};

// Convert game coordinates to minimap coordinates using barycentric interpolation
const barycentricInterpolation = ({ x, y }) => {
    const [[x1, y1], [x2, y2], [x3, y3]] = knownGameCoords;
    const [[u1, v1], [u2, v2], [u3, v3]] = knownImageCoords;

    const w1 = ((y2 - y3) * (x - x3) + (x3 - x2) * (y - y3)) / ((y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3));
    const w2 = ((y3 - y1) * (x - x3) + (x1 - x3) * (y - y3)) / ((y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3));
    const w3 = 1 - w1 - w2;

    const u = w1 * u1 + w2 * u2 + w3 * u3;
    const v = w1 * v1 + w2 * v2 + w3 * v3;

    return { x: u, y: v };
};

// Check if a blip is within the minimap view
const isBlipInView = (blipX, blipY) => {
    const minimapX = currentPlayerCoords.x - minimapSize.width / 2;
    const minimapY = currentPlayerCoords.y - minimapSize.height / 2;

    return blipX >= minimapX && blipX <= minimapX + minimapSize.width && blipY >= minimapY && blipY <= minimapY + minimapSize.height;
};

// Recalculate blip position based on camera angle
const rotatePoint = (x, y, angle) => {
    const radians = (Math.PI / 180) * angle;
    const cos = Math.cos(radians);
    const sin = Math.sin(radians);

    const nx = cos * (x - minimapSize.width / 2) - sin * (y - minimapSize.height / 2) + minimapSize.width / 2;
    const ny = sin * (x - minimapSize.width / 2) + cos * (y - minimapSize.height / 2) + minimapSize.height / 2;

    return { x: nx, y: ny };
};

// Move a blip to the edge of a circular minimap
const moveBlipToEdgeCircular = (blipX, blipY, cameraRotation) => {
    let normalizedX = blipX - currentPlayerCoords.x;
    let normalizedY = blipY - currentPlayerCoords.y;

    const angle = Math.atan2(normalizedY, normalizedX) - (Math.PI / 180) * cameraRotation;

    const radius = minimapSize.width / 2;
    let edgeX = minimapSize.width / 2 + radius * Math.cos(angle);
    let edgeY = minimapSize.height / 2 + radius * Math.sin(angle);

    edgeY -= 10;
    edgeX += 10;

    return { x: edgeX, y: edgeY };
};

// Move a blip to the edge of a square minimap
const moveBlipToEdgeSquare = (blipX, blipY, cameraRotation) => {
    let normalizedX = blipX - currentPlayerCoords.x;
    let normalizedY = blipY - currentPlayerCoords.y;

    // Calculate the angle from the player to the blip
    const angle = Math.atan2(normalizedY, normalizedX) - (Math.PI / 180) * cameraRotation;

    // Determine the maximum distance to the edges of the square
    const distanceToEdge = Math.min(minimapSize.width / 2 / Math.abs(Math.cos(angle)), minimapSize.height / 2 / Math.abs(Math.sin(angle)));

    // Calculate the final coordinates on the edge of the minimap
    let edgeX = minimapSize.width / 2 + distanceToEdge * Math.cos(angle);
    let edgeY = minimapSize.height / 2 + distanceToEdge * Math.sin(angle);

    edgeY -= 10;
    edgeX += 10;

    return { x: edgeX, y: edgeY };
};

// Toggle minimap shape between square and circular
const toggleMinimapShape = (isCircular) => {
    isMinimapCircular = isCircular;
    if (isCircular) {
        mapContainer.css({
            "border-radius": "100%",
        });
    } else {
        mapContainer.css({
            "border-radius": "10px",
        });
    }
};

// Set blips on the minimap and adjust their positions
function setBlips(blips, cameraRotation = 0) {
    $(".map-blip").remove();

    let px = currentPlayerWorldCoords.x;
    let py = currentPlayerWorldCoords.y;

    let sorted = blips.slice().sort((a, b) => {
        let da = distance2D(a.coords.x, a.coords.y, px, py);
        let db = distance2D(b.coords.x, b.coords.y, px, py);
        return da - db;
    });

    let nearestBlips = sorted.slice(0, maxMinimapBlipsCount);

    nearestBlips.forEach((blip) => {
        createMapBlip(blip, cameraRotation);
    });
}
function createMapBlip(blip, cameraRotation) {
    const { id, imgUrl, coords } = blip;

    const blipHtml = `<img data-id="${id}" src="${imgUrl}" class="map-blip">`;
    $(".minimap .rotator-container>div:not(.player-indicator)").append(blipHtml);

    let $mapBlip = $(`.map-blip[data-id="${id}"]`);

    let { x, y } = barycentricInterpolation(coords);
    $mapBlip.data("coords", JSON.stringify({ x, y }));

    const blipW = $mapBlip.width();
    const blipH = $mapBlip.height();
    x -= blipW / 2;
    y -= blipH / 2;

    const inView = isBlipInView(x, y);
    if (!inView) {
        const edgeCoords = isMinimapCircular ? moveBlipToEdgeCircular(x, y, cameraRotation) : moveBlipToEdgeSquare(x, y, cameraRotation);

        x = edgeCoords.x - blipW / 2;
        y = edgeCoords.y - blipH / 2;

        $("#blip-container .blip-container-relative").append($mapBlip);
    } else {
        y -= 20;
    }

    $mapBlip.css({ left: `${x}px`, bottom: `${y}px` });

    if (inView) {
        const fixedCamRot = -cameraRotation;
        $mapBlip.css({
            transform: `translate(-50%, -50%) rotate(${fixedCamRot}deg)`,
        });
    }
}
function distance2D(x1, y1, x2, y2) {
    let dx = x1 - x2;
    let dy = y1 - y2;
    return Math.sqrt(dx * dx + dy * dy);
}

// Center the minimap on the player coordinates and update the camera rotation
const goToCoords = (coords, cameraRotation) => {
    currentPlayerCoords = coords;

    let { x, y } = coords;

    let mapContainerWidth = mapContainer.width();
    let mapContainerHeight = mapContainer.height();

    let adjustedX = mapContainerWidth / 2 - x;
    let adjustedY = mapContainerHeight / 2 - y;

    $(".minimap .rotator-container>div:not(.player-indicator)").css({
        left: adjustedX,
        bottom: adjustedY,
    });

    $(".minimap .rotator-container").css({
        transform: `rotate(${cameraRotation}deg)`,
    });

    $(".map-blip").each(function () {
        const blipData = $(this).data("coords");
        if (!blipData) return;
        if (blipData) {
            const blipCoords = JSON.parse(blipData);

            const isInView = isBlipInView(blipCoords.x, blipCoords.y);

            if (!isInView) {
                const edgeCoords = isMinimapCircular ? moveBlipToEdgeCircular(blipCoords.x, blipCoords.y, cameraRotation) : moveBlipToEdgeSquare(blipCoords.x, blipCoords.y, cameraRotation);
                $(this).css({
                    left: edgeCoords.x + "px",
                    bottom: edgeCoords.y + "px",
                });
                if (!$(this).parent().is("#blip-container .blip-container-relative")) {
                    $("#blip-container .blip-container-relative").append($(this));
                }
                $(this).css({ transform: "translate(-50%, -50%)" }); // Reset rotation for blips outside of view
            } else {
                $(this).css({
                    left: blipCoords.x + "px",
                    bottom: blipCoords.y - 20 + "px",
                });

                const fixedCameraRotation = cameraRotation - 90;
                $(this).css({
                    transform: `translate(-50%, -50%) rotate(${-fixedCameraRotation}deg) rotate(-90deg)`,
                });

                if (!$(this).parent().is(".rotator-container>div:not(.player-indicator)")) {
                    $(".rotator-container>div:not(.player-indicator)").append($(this));
                }
            }
        }
    });
};

// Set the player's heading on the minimap
const setPlayerHeading = (playerHeading) => {
    let fixedHeading = playerHeading;

    playerIndicator.css({
        transform: `translate(-50%, 50%) rotate(${fixedHeading}deg) rotate(-300deg)`,
    });
};

// Set initial blips and minimap shape
const hardcodedBlips = [];
setBlips(hardcodedBlips, 0); // Initialize without camera rotation
toggleMinimapShape(false);

Events.Subscribe("ToggleShape", (isCircular) => {
    toggleMinimapShape(isCircular);
});

Events.Subscribe("UpdatePlayerPos", (playerCoordsX, playerCoordsY, playerHeading, cameraRotation) => {
    currentPlayerWorldCoords = { x: playerCoordsX, y: playerCoordsY };
    let playerCoords = { x: playerCoordsX, y: playerCoordsY };
    window.currentPlayerWorldCoords = playerCoords;
    setPlayerHeading(playerHeading);
    cameraRotation = -cameraRotation - 90;
    let { x, y } = barycentricInterpolation(playerCoords);
    goToCoords({ x, y }, cameraRotation);
    setBlips(persistentBlips, cameraRotation);
});

// Set known game and image coordinates
Events.Subscribe("InitMinimapData", (gameCoords, imageCoords, maxBlipsCount) => {
    knownGameCoords = gameCoords;
    knownImageCoords = imageCoords;
    maxMinimapBlipsCount = maxBlipsCount;
    console.log("Minimap Data =>", knownGameCoords, knownImageCoords, maxMinimapBlipsCount);
});

// Set minimap shape based on the provided shape
Events.Subscribe("SetMinimapShape", (shape) => {
    const isCircular = shape === "circle";
    toggleMinimapShape(isCircular);
});

// Set blips on the minimap
Events.Subscribe("SetBlips", (blips) => {
    persistentBlips = blips;
    setBlips(persistentBlips, 0);
});

// Remove blip by ID
Events.Subscribe("RemoveBlip", function (id) {
    persistentBlips = persistentBlips.filter((blip) => blip.id !== id);
    setBlips(persistentBlips, 0);
});

// Set minimap position
Events.Subscribe("SetPosition", (position) => {
    switch (position) {
        case 0:
            $(".minimap-section").attr("data-position", "top-left");
            break;
        case 1:
            $(".minimap-section").attr("data-position", "top-right");
            break;
        case 2:
            $(".minimap-section").attr("data-position", "bottom-left");
            break;
        case 3:
            $(".minimap-section").attr("data-position", "bottom-right");
            break;
    }
});

Events.Subscribe("Map:TogglePlayers", (state) => {
    showPlayers = state;
    if (!showPlayers) {
        for (let id in minimapPlayerBlipElements) {
            minimapPlayerBlipElements[id].remove();
        }
        minimapPlayerBlipElements = {};
    }
});

Events.Subscribe("Map:UpdatePlayersPos", function (playerBlips) {
    if (!showPlayers) return;
    let updatedIds = new Set();
    for (let id in minimapPlayerBlipElements) {
        if (!updatedIds.has(Number(id))) {
            minimapPlayerBlipElements[id].remove();
            delete minimapPlayerBlipElements[id];
        }
    }
    playerBlips.forEach((p) => {
        updatedIds.add(p.id);
        let blip = minimapPlayerBlipElements[p.id];
        if (!blip) {
            blip = document.createElement("div");
            blip.className = "player-blip";
            blip.dataset.id = p.id;
            $(".minimap .rotator-container>div:not(.player-indicator)").append(blip);
            minimapPlayerBlipElements[p.id] = blip;
        }
        let coords = barycentricInterpolation({ x: p.x, y: p.y });
        let blipWidth = blip.offsetWidth || 15;
        let blipHeight = blip.offsetHeight || 15;
        let posX = coords.x - blipWidth / 2;
        let posY = coords.y - blipHeight / 2;
        blip.style.position = "absolute";
        blip.style.left = posX + "px";
        blip.style.bottom = posY + "px";
    });
});
