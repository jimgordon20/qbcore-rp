const blipsContainer = $(".blips");
const blipElement = blipsContainer.find(".blip");

const mapContainer = $(".map-container");
const mapWrapper = $(".map-wrapper");
const minimap = $(".map-wrapper .map");
const playerMarker = $(".player-marker");
const waypoint = $(".waypoint");

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

let mapImageWidth = 7680;
let mapImageHeight = 4200;
let scale = 1;
let scaleValues = {
    minMapScale: 0.4,
    maxMapScale: 2.0,
};
let playerMarkerScale = 1;
let zoomAmount = 2;
let persistentBlips = [];
let isDragging = false;
let startX = 0;
let startY = 0;
let offsetX = 0;
let offsetY = 0;
let calculating = false;
let animating = false;

let persistentBlipGroups = [];
let selectedGroupIndex = -1;
let selectedBlipIndex = 0;
let scrollInterval = null;
const scrollDelay = 100;
let lastKey = null;
let blinkingBlips = {};

// -1 = playerMarker, 0 = waypoint, 0+n = blips
let selectedBlip = -1;

// Map drag and movement handling
$(document).on("mousedown", function (event) {
    if ($(event.target).hasClass("map-blip")) return;
    if (event.button === 0 && !animating) {
        $("body").css("cursor", "grabbing");
        isDragging = true;
        startX = event.pageX;
        startY = event.pageY;
        offsetX = parseFloat(mapWrapper.css("left"));
        offsetY = parseFloat(mapWrapper.css("bottom"));
        mapWrapper.css("transition", "none");
    }
});

$(document).on("mousemove", function (event) {
    recalculateBlips();
    if (isDragging) {
        let currentX = event.pageX;
        let currentY = event.pageY;
        let diffX = currentX - startX;
        let diffY = currentY - startY;

        diffX /= scale;
        diffY /= scale;

        let newLeft = offsetX + diffX;
        let newTop = offsetY - diffY;

        const boundaryX = mapImageWidth / 10;
        const boundaryY = mapImageHeight / 10;

        newLeft = Math.max(-mapImageWidth + boundaryX, Math.min(boundaryX, newLeft));
        newTop = Math.max(-mapImageHeight + boundaryY, Math.min(boundaryY, newTop));

        mapWrapper.css({ left: newLeft, bottom: newTop });
    }
});

$(document).on("mouseup", function (event) {
    if (event.button === 0 && isDragging) {
        $("body").css("cursor", "grab");
        isDragging = false;
        mapWrapper.css("transition", "all 0.2s linear");

        let clickX = event.pageX;
        let clickY = event.pageY;

        let mapWrapperPos = mapWrapper.position();
        let mapContainerPos = mapContainer.position();

        let mapWrapperBottom = mapWrapperPos.top / scale + mapWrapper.height();
        let mapX = (clickX - mapContainerPos.left) / scale - mapWrapperPos.left / scale;
        let mapY = (clickY - mapContainerPos.top) / scale - mapWrapperBottom;

        console.log(`Map Coordinates - X: ${mapX}, Y: ${-mapY}`);
    }
});

// Handle double-click to remove waypoint
$(document).on("dblclick", ".waypoint-marker", function (event) {
    event.stopPropagation();
    event.preventDefault();
    $(this).remove();
    Events.Call("Map:RemoveWaypointBlip");
});

// Move to waypoint coordinates on click
$(document).on("click", ".waypoint-marker", function (event) {
    event.stopPropagation();
    event.preventDefault();

    let waypointCoords = JSON.parse($(this).data("coords"));
    goToCoords(waypointCoords);
});

// Handle double-click to set waypoint
$(document).on("dblclick", ".map-container", function (event) {
    event.preventDefault();
    if ($(event.target).hasClass("waypoint-marker")) return;

    let clickX = event.pageX;
    let clickY = event.pageY;

    let mapWrapperPos = mapWrapper.position();
    let mapContainerPos = mapContainer.position();

    let mapWrapperBottom = mapWrapperPos.top / scale + mapWrapper.height();
    let mapX = (clickX - mapContainerPos.left) / scale - mapWrapperPos.left / scale;
    let mapY = (clickY - mapContainerPos.top) / scale - mapWrapperBottom;

    let gameCoords = reverseBarycentricInterpolation({ x: mapX, y: -mapY });

    Events.Call("Map:AddWaypointBlip", gameCoords.x, gameCoords.y);
});

// Handle map zoom
$(document).on("wheel", ".map-container", function (e) {
    let delta = e.originalEvent.deltaY;
    let newScale;

    if (delta < 0 && scale * 1.1 <= scaleValues.maxMapScale) {
        newScale = scale * 1.1;
    } else if (delta > 0 && scale * 0.9 >= scaleValues.minMapScale) {
        newScale = scale * 0.9;
    } else {
        return;
    }

    setMapScale(newScale);
});

// Select blip on the map
$(document).on("click", ".blip", function () {
    let blipName = $(this).data("name");
    let groupIndex = persistentBlipGroups.findIndex((group) => group.name === blipName);

    if (groupIndex !== -1) {
        selectedGroupIndex = groupIndex;
        selectedBlipIndex = 0;

        let group = persistentBlipGroups[selectedGroupIndex];
        let blipElement = $(this);

        if (group.blips.length > 1) {
            blipElement.find(".blip-counter").text(`1/${group.blips.length}`);
        } else {
            blipElement.find(".blip-counter").text("");
        }

        blipElement.addClass("active").siblings().removeClass("active");

        let blip = group.blips[selectedBlipIndex];
        let blipId = blip.id;
        let mapBlip = $(`.map-blip[data-id="${blipId}"]`);
        let blipCoords = JSON.parse(mapBlip.data("coords"));
        let blipWidth = mapBlip.width();
        let blipHeight = mapBlip.height();

        blipCoords.x -= blipWidth / 2;
        blipCoords.y -= blipHeight / 2;

        goToCoords(blipCoords);
    }
});

// Handle keyboard input for map navigation
$(document).on("keydown", function (e) {
    if (scrollInterval) return;

    if (e.key === "ArrowUp" || e.key === "ArrowDown") {
        scrollBlips(e.key === "ArrowUp" ? "up" : "down");

        scrollInterval = setInterval(() => {
            scrollBlips(e.key === "ArrowUp" ? "up" : "down");
        }, scrollDelay);

        lastKey = e.key;
    }

    if (e.key === "m" || e.key === "M") {
        Events.Call("Map:ExitMap");
    }
});

// Stop scrolling when key is released
$(document).on("keyup", function (e) {
    if (scrollInterval && (e.key === "ArrowUp" || e.key === "ArrowDown")) {
        clearInterval(scrollInterval);
        scrollInterval = null;
        lastKey = null;
    }
});

// Move to clicked coordinates on right-click
$(document).on("mousedown", ".map-container", function (event) {
    if (event.button === 2) {
        event.preventDefault();

        let clickX = event.pageX;
        let clickY = event.pageY;

        let mapWrapperPos = mapWrapper.position();
        let mapContainerPos = mapContainer.position();

        let mapWrapperBottom = mapWrapperPos.top / scale + mapWrapper.height();
        let mapX = (clickX - mapContainerPos.left) / scale - mapWrapperPos.left / scale;
        let mapY = (clickY - mapContainerPos.top) / scale - mapWrapperBottom;

        goToCoords({ x: mapX, y: mapY });
    }
});

$(document).on("click", ".waypoint-marker", function (event) {
    event.stopPropagation();
    event.preventDefault();

    let waypointCoords = JSON.parse($(this).data("coords"));
    goToCoords(waypointCoords);
});

function goToCoords(coords) {
    let { x, y } = { x: coords.x, y: -coords.y };

    let mapContainerWidth = mapContainer.width();
    let mapContainerHeight = mapContainer.height();

    let adjustedX = mapContainerWidth / 2 - x;
    let adjustedY = mapContainerHeight / 2 + y;

    mapWrapper.css({
        left: adjustedX,
        bottom: adjustedY,
    });
}

function setMapScale(s) {
    $(".map-blip").css("transform", "translate(-50%, -50%) scale(" + 1 / s + ")");
    $(".waypoint-marker").css("transform", "scale(" + 1 / s + ")");

    mapContainer.css({
        transformOrigin: "center",
        transform: "translate(-50%, -50%) scale(" + s + ")",
    });

    scale = s;
}

function updatePlayerPos(playerCoords, playerHeading) {
    let { x, y } = barycentricInterpolation(playerCoords);
    playerMarker.data("coords", JSON.stringify({ x: x, y: y }));

    let playerMarkerWidth = playerMarker.width();
    let playerMarkerHeight = playerMarker.height();

    x -= playerMarkerWidth / 2;
    y -= playerMarkerHeight / 2;

    playerMarker.css({
        left: x,
        bottom: y,
        transform: "rotate(" + (playerHeading + 360) + "deg) rotate(-210deg) rotate(-90deg) scale(" + 1 / scale + ")",
    });
}

function setBlips(blips) {
    let blipGroups = [];
    let blipsByName = {};

    blips = blips.filter((blip) => blip.type !== "waypoint");

    blips.forEach((blip) => {
        let { name } = blip;
        if (!blipsByName[name]) {
            blipsByName[name] = [];
        }
        blipsByName[name].push(blip);
    });

    for (let name in blipsByName) {
        blipGroups.push({
            name: name,
            blips: blipsByName[name],
        });
    }

    persistentBlips = blips;
    persistentBlipGroups = blipGroups;

    blipsContainer.empty();
    $(".map-blip").remove();

    blipGroups.forEach((group) => {
        let firstBlip = group.blips[0];
        let { imgUrl } = firstBlip;
        let count = group.blips.length;
        let counterText = count > 1 ? `1/${count}` : "";

        let newBlip = `<div class="blip" data-name="${group.name}">
            <p>${group.name} <span class="blip-counter">${counterText}</span></p>
            <img src="${imgUrl}" alt="">
        </div>`;
        blipsContainer.append(newBlip);
    });

    blips.forEach((blip) => {
        let { imgUrl, id } = blip;
        let mapBlip = $("<img>", {
            "data-id": id,
            "data-name": blip.name,
            src: imgUrl,
            alt: "",
            class: "map-blip",
        });

        if (blinkingBlips[id]) {
            mapBlip.addClass("blinking");
        }

        mapWrapper.append(mapBlip);

        let { x, y } = barycentricInterpolation(blip.coords);
        mapBlip.data("coords", JSON.stringify({ x: x, y: y }));

        let mapBlipWidth = mapBlip.width();
        let mapBlipHeight = mapBlip.height();

        x -= mapBlipWidth / 2;
        y -= mapBlipHeight / 2;

        mapBlip.css({
            left: x,
            bottom: y,
            transform: "translate(-50%, -50%) scale(" + 1 / scale + ")",
        });

        mapBlip.on("click", function () {
            let blipCoords = JSON.parse($(this).data("coords"));
            let blipWidth = $(this).width();
            let blipHeight = $(this).height();

            blipCoords.x -= blipWidth / 2;
            blipCoords.y -= blipHeight / 2;

            goToCoords(blipCoords);
        });
    });
}

function scrollBlips(direction) {
    if (direction === "up") {
        if (selectedGroupIndex == -1) {
            selectedGroupIndex = persistentBlipGroups.length - 1;
            selectedBlipIndex = persistentBlipGroups[selectedGroupIndex].blips.length - 1;
        } else {
            selectedBlipIndex--;
            if (selectedBlipIndex < 0) {
                selectedGroupIndex--;
                if (selectedGroupIndex < -1) {
                    selectedGroupIndex = persistentBlipGroups.length - 1;
                }
                if (selectedGroupIndex == -1) {
                    selectedBlipIndex = 0;
                } else {
                    selectedBlipIndex = persistentBlipGroups[selectedGroupIndex].blips.length - 1;
                }
            }
        }
    } else if (direction === "down") {
        if (selectedGroupIndex == -1) {
            selectedGroupIndex = 0;
            selectedBlipIndex = 0;
        } else {
            selectedBlipIndex++;
            let group = persistentBlipGroups[selectedGroupIndex];
            if (selectedBlipIndex >= group.blips.length) {
                selectedGroupIndex++;
                if (selectedGroupIndex >= persistentBlipGroups.length) {
                    selectedGroupIndex = -1;
                    selectedBlipIndex = 0;
                } else {
                    selectedBlipIndex = 0;
                }
            }
        }
    }

    if (selectedGroupIndex == -1) {
        let playerCoords = JSON.parse(playerMarker.data("coords"));
        goToCoords(playerCoords);
        $(".blip").removeClass("active");
    } else {
        let group = persistentBlipGroups[selectedGroupIndex];
        let blipElement = $('.blip[data-name="' + group.name + '"]');
        if (group.blips.length > 1) {
            blipElement.find(".blip-counter").text(`${selectedBlipIndex + 1}/${group.blips.length}`);
        } else {
            blipElement.find(".blip-counter").text("");
        }
        blipElement.addClass("active").siblings().removeClass("active");

        let blip = group.blips[selectedBlipIndex];
        let blipId = blip.id;
        let mapBlip = $(`.map-blip[data-id="${blipId}"]`);
        let blipCoords = JSON.parse(mapBlip.data("coords"));
        blipCoords.y -= 10;
        blipCoords.x -= 10;

        goToCoords(blipCoords);
    }

    setTimeout(() => recalculateBlips(), 500);
}

function recalculateBlips() {
    if (calculating) return;
    calculating = true;
    var viewportWidth = $(window).width();
    var viewportHeight = $(window).height();
    var centerScreenX = viewportWidth / 2;
    var centerScreenY = viewportHeight / 2;

    var maxDistance = Math.sqrt(Math.pow(centerScreenX, 2) + Math.pow(centerScreenY, 2));

    $(".map-blip, .waypoint-marker").each(function () {
        var $blip = $(this);
        var blipOffset = $blip.offset();
        var blipWidth = $blip.outerWidth();
        var blipHeight = $blip.outerHeight();
        var blipCenterX = blipOffset.left + blipWidth / 2;
        var blipCenterY = blipOffset.bottom + blipHeight / 2;

        var distanceToCenter = Math.sqrt(Math.pow(blipCenterX - centerScreenX, 2) + Math.pow(blipCenterY - centerScreenY, 2));
        var opacity = 1 - distanceToCenter / maxDistance;

        $blip.css("opacity", opacity);
    });
    setTimeout(() => (calculating = false), 100);
}

function barycentricInterpolation({ x, y }) {
    const [[x1, y1], [x2, y2], [x3, y3]] = knownGameCoords;
    const [[u1, v1], [u2, v2], [u3, v3]] = knownImageCoords;

    const w1 = ((y2 - y3) * (x - x3) + (x3 - x2) * (y - y3)) / ((y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3));
    const w2 = ((y3 - y1) * (x - x3) + (x1 - x3) * (y - y3)) / ((y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3));
    const w3 = 1 - w1 - w2;

    const u = w1 * u1 + w2 * u2 + w3 * u3;
    const v = w1 * v1 + w2 * v2 + w3 * v3;

    return { x: u, y: v };
}

function reverseBarycentricInterpolation(screenCoords) {
    const [[u1, v1], [u2, v2], [u3, v3]] = knownImageCoords;
    const [[x1, y1], [x2, y2], [x3, y3]] = knownGameCoords;

    const denominator = (v2 - v3) * (u1 - u3) + (u3 - u2) * (v1 - v3);

    if (denominator === 0) {
        console.error("Error: denominator is zero in barycentric interpolation.");
        return { x: 0, y: 0 };
    }

    const w1 = ((v2 - v3) * (screenCoords.x - u3) + (u3 - u2) * (screenCoords.y - v3)) / denominator;
    const w2 = ((v3 - v1) * (screenCoords.x - u3) + (u1 - u3) * (screenCoords.y - v3)) / denominator;
    const w3 = 1 - w1 - w2;

    const x = w1 * x1 + w2 * x2 + w3 * x3;
    const y = w1 * y1 + w2 * y2 + w3 * y3;

    return { x: x, y: y };
}

function setWaypoint(gameCoords) {
    $(".waypoint-marker").remove();

    let { x, y } = barycentricInterpolation(gameCoords);

    let waypointMarker = $("<img>", {
        class: "waypoint-marker",
        src: "./media/map-icons/marker.svg",
        alt: "Marker",
    });

    waypointMarker.data("coords", JSON.stringify({ x: x, y: y }));

    waypointMarker.on("load", function () {
        let markerWidth = waypointMarker.width();
        let markerHeight = waypointMarker.height();

        x -= markerWidth / 2;
        y -= markerHeight / 2;

        waypointMarker.css({
            left: x,
            bottom: y,
            transform: "scale(" + 1 / scale + ")",
        });
    });

    mapWrapper.append(waypointMarker);
}

function startBlinkingBlip(blipId) {
    if (blinkingBlips[blipId]) return;

    blinkingBlips[blipId] = Date.now() + 5000;
    let blipElement = $(`.map-blip[data-id="${blipId}"]`);
    if (blipElement.length > 0) {
        blipElement.addClass("blinking");
    }
}

function stopBlinkingBlip(blipId) {
    delete blinkingBlips[blipId];
    let blipElement = $(`.map-blip[data-id="${blipId}"]`);
    if (blipElement.length > 0) {
        blipElement.removeClass("blinking");
    }
}

setInterval(function () {
    let currentTime = Date.now();
    for (let blipId in blinkingBlips) {
        if (currentTime > blinkingBlips[blipId]) {
            stopBlinkingBlip(blipId);
        }
    }
}, 500);

const hardcodedBlips = [];
hardmapBlips = [
    { id: 1, name: "car shop", coords: { x: 124069, y: -178853 }, imgUrl: "./media/map-icons/cars-icon.svg" },
    { id: 2, name: "hotel", coords: { x: -25227, y: 217105 }, imgUrl: "./media/map-icons/hotel-icon.svg" },
    { id: 3, name: "police station", coords: { x: 19838.9, y: 11656.1 }, imgUrl: "./media/map-icons/police-icon.svg" },
    { id: 4, name: "park", coords: { x: 50000, y: -60000 }, imgUrl: "./media/map-icons/park-icon.svg" },
    { id: 5, name: "hospital", coords: { x: -33787.4, y: 134419.7 }, imgUrl: "./media/map-icons/medicine-icon.svg" },
    { id: 6, name: "fire dept", coords: { x: 17978.9, y: -81652.2 }, imgUrl: "./media/map-icons/firedept-icon.svg" },
    { id: 7, name: "bank", coords: { x: -15757.2, y: -49698.1 }, imgUrl: "./media/map-icons/bank-icon.svg" },
    { id: 8, name: "bank", coords: { x: -28861.0, y: -61394.7 }, imgUrl: "./media/map-icons/bank-icon.svg" },
    { id: 9, name: "bank", coords: { x: -24135.4, y: -81352.9 }, imgUrl: "./media/map-icons/bank-icon.svg" },
    { id: 10, name: "bank", coords: { x: 19417.4, y: -58780.5 }, imgUrl: "./media/map-icons/bank-icon.svg" },
    { id: 11, name: "convenience store", coords: { x: -12991, y: -11003 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 12, name: "convenience store", coords: { x: -36505, y: -73568 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 13, name: "convenience store", coords: { x: 417, y: -97079 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 14, name: "convenience store", coords: { x: 16681, y: -46656 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 15, name: "convenience store", coords: { x: 4347, y: 95383 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 16, name: "convenience store", coords: { x: -66619, y: -93930 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 17, name: "convenience store", coords: { x: -54299, y: -42392 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 18, name: "convenience store", coords: { x: 14385, y: 148275 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 19, name: "convenience store", coords: { x: -29640, y: 171248 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 20, name: "convenience store", coords: { x: -42868, y: -113714 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 21, name: "convenience store", coords: { x: -6867, y: -72680 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 22, name: "convenience store", coords: { x: -49719, y: -26348 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 23, name: "convenience store", coords: { x: 13210, y: -20963 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 24, name: "convenience store", coords: { x: -12929, y: 118341 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 25, name: "convenience store", coords: { x: -23252, y: 121788 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 26, name: "convenience store", coords: { x: 12004, y: -17089 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 27, name: "convenience store", coords: { x: -19975, y: 127011 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 28, name: "convenience store", coords: { x: -12867, y: 122088 }, imgUrl: "./media/map-icons/shop-icon.svg" },
    { id: 30, name: "gun store", coords: { x: -2541, y: -89358 }, imgUrl: "./media/map-icons/gun-icon.svg" },
    { id: 31, name: "soft rock cafe", coords: { x: -43221, y: -111533 }, imgUrl: "./media/map-icons/food-icon.svg" },
    { id: 32, name: "mc lounge", coords: { x: -47806, y: -24400 }, imgUrl: "./media/map-icons/bar-icon.svg" },
    { id: 33, name: "best burger", coords: { x: -30968, y: 171822 }, imgUrl: "./media/map-icons/food-icon.svg" },
    { id: 34, name: "mirage theater", coords: { x: -7569, y: -101562 }, imgUrl: "./media/map-icons/cinema-icon.svg" },
    { id: 35, name: "mirage theater", coords: { x: -37731, y: 49628 }, imgUrl: "./media/map-icons/cinema-icon.svg" },
];

setBlips(hardmapBlips);
setMapScale(0.4);

Events.Subscribe("Map:SetBlips", (blips) => {
    setBlips(blips);
});

Events.Subscribe("Map:ShowMap", () => {
    let playerCoords = JSON.parse(playerMarker.data("coords"));
    goToCoords(playerCoords);
});

Events.Subscribe("Map:UpdatePlayerPos", (playerX, playerY, playerHeading) => {
    let playerCoords = { x: playerX, y: playerY };
    updatePlayerPos(playerCoords, playerHeading);
});

Events.Subscribe("Map:SetKnownCoords", (gameCoords, imageCoords) => {
    knownGameCoords = gameCoords;
    knownImageCoords = imageCoords;
});

Events.Subscribe("Map:UpdateView", () => {
    if (selectedBlip == -1) {
        let playerCoords = JSON.parse(playerMarker.data("coords"));
        goToCoords(playerCoords);
        $(".blip").removeClass("active");
    } else {
        let blipId = persistentBlips[selectedBlip].id;
        let blip = $(`.map-blip[data-id="${blipId}"]`);
        let blipCoords = JSON.parse(blip.data("coords"));
        blipCoords.y -= 10;
        blipCoords.x -= 10;
        $('.blip[data-id="' + blipId + '"]')
            .addClass("active")
            .siblings()
            .removeClass("active");
        goToCoords(blipCoords);
    }
});

Events.Subscribe("Map:SetWaypoint", function (waypointBlip) {
    setWaypoint(waypointBlip.coords);
});

Events.Subscribe("Map:RemoveWaypoint", function () {
    $(".waypoint-marker").remove();
});

Events.Subscribe("Map:BlinkBlip", function (blipId) {
    startBlinkingBlip(blipId);
});

Events.Subscribe("Map:BlinkWaypoint", function () {
    let waypointMarker = $(".waypoint-marker");
    if (waypointMarker.length > 0) {
        waypointMarker.addClass("blinking");
        setTimeout(function () {
            waypointMarker.removeClass("blinking");
        }, 5000);
    }
});
