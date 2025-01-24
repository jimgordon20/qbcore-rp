const blipsContainer = $(".blips > div");
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
    minMapScale: 0.6,
    maxMapScale: 4,
};
let playerMarkerScale = 1;
let zoomAmount = 0.2;
let persistentBlips = [];
let isDragging = false;
let startX = 0;
let startY = 0;
let offsetX = 0;
let offsetY = 0;
let calculating = false;
let animating = false;

// -1 = playerMarker, 0 = waypoint, 0+n = blips
let selectedBlip = -1;

let allGroups = [];
let startIndex = 0;
let endIndex = 14;
let selectedGroupIndex = -1;
let subGroups = [];
let subStart = 0;
let subEnd = 0;
let selectedInSub = 0;
let visibleCount = 14;
let ringStart = 0;
let finalOrderedBlips = [];
let allOriginalBlips = [];
let playerBlipElements = {};
let showPlayers = true;

// Handle map movement
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

        mapWrapper.css({
            left: newLeft,
            bottom: newTop,
        });
    }
});

$(document).on("mouseup", function (event) {
    if (event.button === 0 && isDragging) {
        $("body").css("cursor", "grab");
        isDragging = false;
        mapWrapper.css("transition", "all 0.2s ease-in-out");

        // Calculate map coordinates based on user click
        let clickX = event.pageX;
        let clickY = event.pageY;

        let mapWrapperPos = mapWrapper.position();
        let mapContainerPos = mapContainer.position();

        let mapWrapperBottom = mapWrapperPos.top / scale + mapWrapper.height();
        let mapX = (clickX - mapContainerPos.left) / scale - mapWrapperPos.left / scale;
        let mapY = (clickY - mapContainerPos.top) / scale - mapWrapperBottom;

        // Print map coordinates
        console.log(`Map Coordinates - X: ${mapX}, Y: ${-mapY}`);
    }
});

// Handle double-click to set waypoint
$(document).on("dblclick", ".map-container", function (event) {
    event.preventDefault();

    let clickX = event.pageX;
    let clickY = event.pageY;

    let mapWrapperPos = mapWrapper.position();
    let mapContainerPos = mapContainer.position();

    let mapWrapperBottom = mapWrapperPos.top / scale + mapWrapper.height();
    let mapX = (clickX - mapContainerPos.left) / scale - mapWrapperPos.left / scale;
    let mapY = (clickY - mapContainerPos.top) / scale - mapWrapperBottom;

    mapX += 10;
    mapY += 10;

    let ingameClickedCoords = reverseBarycentricInterpolation({ x: mapX, y: -mapY });

    // Remove previous waypoint
    $(".waypoint-marker").remove();

    // Trigger event to add blip
    Events.Call("Map:AddWaypointBlip", ingameClickedCoords.x, ingameClickedCoords.y);
});

// Handle map zoom
$(document).on("wheel", ".map-container", function (e) {
    animating = true;
    let delta = e.originalEvent.deltaY;
    let newScale;

    if (delta < 0) {
        newScale = scale + zoomAmount;
    } else {
        newScale = scale - zoomAmount;
    }

    setMapScale(newScale);
    setTimeout(() => (animating = false), 300);
});

// Handle keyboard input for map navigation
$(document).on("keydown", function (e) {
    // If the search is focused, ignore Backspace/M
    if ($("input.search").is(":focus") && (e.key === "Backspace" || e.key === "M" || e.key === "m")) return;

    // Arrow navigation according to finalOrderedBlips
    if (e.key === "ArrowUp" || e.key === "ArrowDown") {
        if (finalOrderedBlips.length < 1) return;
        // Find current index in finalOrderedBlips
        let currentId = selectedBlip !== -1 ? persistentBlips[selectedBlip].id : null;
        let currentIdx = finalOrderedBlips.indexOf(currentId);
        // If none selected, treat as -1
        if (currentIdx < 0) currentIdx = -1;

        if (e.key === "ArrowDown") {
            currentIdx++;
            if (currentIdx >= finalOrderedBlips.length) currentIdx = -1;
        } else {
            currentIdx--;
            if (currentIdx < -1) currentIdx = finalOrderedBlips.length - 1;
        }

        if (currentIdx === -1) {
            // No selection
            selectedBlip = -1;
            blipsContainer.scrollTop(0);
        } else {
            let nextId = finalOrderedBlips[currentIdx];
            let findNext = persistentBlips.findIndex((b) => b.id === nextId);
            if (findNext !== -1) selectedBlip = findNext;
        }
        highlightBlipByIndex(selectedBlip);
    } else if (e.key === "Backspace" || e.key === "M" || e.key === "m") {
        Events.Call("Map:ExitMap");
    } else if (e.key === "Enter") {
        if (selectedBlip !== -1) {
            $(".teleport-confirm").removeClass("hidden");
        }
    } else if (e.key === "O" || e.key === "o") {
        showPlayers = !showPlayers;
        for (let id in playerBlipElements) {
            playerBlipElements[id].remove();
        }
        playerBlipElements = {};
        Events.Call("Map:TogglePlayers", showPlayers);
    }

    // Highlight or revert
    if (selectedBlip === -1) {
        let p = JSON.parse(playerMarker.data("coords"));
        goToCoords(p);
        $(".blip").removeClass("active");
        revertAllGroupNames();
    } else {
        let blipId = persistentBlips[selectedBlip].id;
        $(`.blip[data-ids*="${blipId}"]`).get(0)?.scrollIntoView({ block: "nearest" });
        let blip = $(`.map-blip[data-id="${blipId}"]`);
        if (!blip.length) throw new Error("Blip coords not found");
        let c = JSON.parse(blip.data("coords"));
        c.y -= 10;
        c.x -= 10;
        revertAllGroupNames();
        $(".blip").removeClass("active");
        $(".map-blip").removeClass("active");
        let foundGroup = getGroupDataByBlipId(blipId);
        if (foundGroup) {
            foundGroup.addClass("active");
            let g = foundGroup.data("groupData");
            let idx = g.items.findIndex((x) => x.id === blipId);
            if (g.items.length === 1) {
                foundGroup.find("p").text(g.name);
            } else {
                foundGroup.find("p").text(`${g.name} (${idx + 1}/${g.items.length})`);
            }
        }
        blip.addClass("active");
        goToCoords(c);
    }
    setTimeout(() => recalculateBlips(), 500);
});

$(".teleport-confirm .btn-yes").on("click", function () {
    if (selectedBlip === -1) {
        $(".teleport-confirm").addClass("hidden");
        return;
    }
    //let chosen = persistentBlips[selectedBlip];
    //let parsedCoords = barycentricInterpolation(chosen.coords);
    Events.Call("Map:TeleportToBlip", selectedBlip);
    $(".teleport-confirm").addClass("hidden");
});

$(".teleport-confirm .btn-no").on("click", function () {
    $(".teleport-confirm").addClass("hidden");
});

// Handle right-click to move to clicked coordinates
$(document).on("mousedown", ".map-container", function (event) {
    if (event.button === 2) {
        event.preventDefault();

        // si es waypoint marker, borrarlo y retornar
        if ($(event.target).hasClass("waypoint-marker")) {
            let waypoints = persistentBlips.filter((b) => b.name === "Waypoint");
            waypoints.forEach((wp) => {
                Events.Call("Map:RemoveBlip", wp.id);
            });
            $(".waypoint-marker").remove();
            return;
        }

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

/* $(document).on("contextmenu", ".waypoint-marker", function(event) {
    event.preventDefault();
    let waypoints = persistentBlips.filter(b => b.name === "Waypoint");
    console.log("waypoints", JSON.stringify(waypoints), $(this).data("id"));
    waypoints.forEach(wp => {
        Events.Call("Map:RemoveBlip", wp.id);
    });
    $(".waypoint-marker").remove();
}); */

$(".search").on("input", function () {
    let q = $(this).val().trim().toLowerCase();
    if (!q) {
        persistentBlips = allOriginalBlips.slice();
    } else {
        let filtered = allOriginalBlips.filter((b) => b.name.toLowerCase().includes(q) || (b.group || "").toLowerCase().includes(q));
        persistentBlips = filtered;
    }
    setBlips(persistentBlips);
});

// Center map on specific coordinates
function goToCoords(coords) {
    let { x, y } = coords;
    console.log(x, y);
    let mapContainerWidth = mapContainer.width();
    let mapContainerHeight = mapContainer.height();

    let adjustedX = mapContainerWidth / 2 - x;
    let adjustedY = mapContainerHeight / 2 + y;

    mapWrapper.css({
        left: adjustedX,
        bottom: adjustedY,
    });
}

// Set map scale and adjust player marker and blips accordingly
function setMapScale(s) {
    if (s < scaleValues.minMapScale) {
        return;
    }
    if (s > scaleValues.maxMapScale) {
        return;
    }

    let actualPlayerMarkerTransform = playerMarker.css("transform");
    $(".map-blip").css("transform", "translate(-0%, -0%) scale(" + 1 / s + ")");

    mapContainer.css({
        transformOrigin: "center",
        transform: "translate(-50%, -50%) scale(" + s + ")",
    });

    if (s > scale) {
        playerMarkerScale -= zoomAmount;
    } else {
        playerMarkerScale += zoomAmount;
    }

    scale = s;
}

// Update player position on the map
function updatePlayerPos(playerCoords, playerHeading) {
    let { x, y } = barycentricInterpolation(playerCoords);
    playerMarker.data("coords", JSON.stringify({ x: x, y: -y }));

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

function revertAllGroupNames() {
    $(".blip").each(function () {
        let g = $(this).data("groupData");
        if (!g) return;
        let total = g.items.length;
        let text = total === 1 ? g.name : `${g.name} (${total})`;
        $(this).find("p").text(text);
    });
}

function getGroupDataByBlipId(blipId) {
    let result = null;
    $(".blip").each(function () {
        let idsString = $(this).attr("data-ids") || "";
        if (idsString.split(",").includes(String(blipId))) {
            result = $(this);
        }
    });
    return result;
}

function setBlips(allBlips) {
    // Clear existing
    $(".blip").remove();
    $(".map-blip").remove();

    persistentBlips = allBlips.slice();

    // Group by blip.group
    let groupedByGroup = allBlips.reduce((acc, b) => {
        let g = b.group || "Others";
        if (!acc[g]) acc[g] = [];
        acc[g].push(b);
        return acc;
    }, {});

    // For each group, further group by blip.name
    let finalData = [];
    for (let groupKey in groupedByGroup) {
        let groupedByName = groupedByGroup[groupKey].reduce((acc, b) => {
            if (!acc[b.name]) acc[b.name] = { name: b.name, items: [] };
            acc[b.name].items.push(b);
            return acc;
        }, {});
        finalData.push({ groupName: groupKey, nameGroups: Object.values(groupedByName) });
    }

    // Render
    finalData.forEach((grp) => {
        let groupHeader = $(`
        <div class="blip group-header">
          <p>${grp.groupName}</p>
        </div>
      `);
        blipsContainer.append(groupHeader);

        grp.nameGroups.forEach((ng) => {
            let label = ng.items.length > 1 ? `${ng.name} (${ng.items.length})` : ng.name;
            let ids = ng.items.map((x) => x.id).join(",");

            let div = $(`
          <div class="blip" data-ids="${ids}">
            <p>${label}</p>
            <img src="${ng.items[0].imgUrl}" alt="">
          </div>
        `);
            div.data("groupData", ng);
            blipsContainer.append(div);
            div.on("click", function () {
                let ids = $(this).attr("data-ids").split(",");
                if (!ids.length) return;
                let firstId = parseInt(ids[0], 10);
                let newIndex = persistentBlips.findIndex((b) => b.id === firstId);
                if (newIndex !== -1) {
                    selectedBlip = newIndex;
                    // same highlight code as arrow keys
                    $(this).get(0)?.scrollIntoView({ block: "nearest" });
                }
            });
            // Place each item on the map
            ng.items.forEach((b) => {
                let html = `<img data-id="${b.id}" src="${b.imgUrl}" class="map-blip ${b.name === "Waypoint" ? "waypoint-marker" : ""}">`;
                mapWrapper.append(html);
                let $mapBlip = $(`.map-blip[data-id="${b.id}"]`);
                let { x, y } = barycentricInterpolation(b.coords);
                $mapBlip.data("coords", JSON.stringify({ x, y: -y }));

                let w = $mapBlip.width();
                let h = $mapBlip.height();
                x -= w / 2;
                y -= h / 2;
                $mapBlip.css({ left: x, bottom: y });

                $mapBlip.on("click", function () {
                    let bid = parseInt($(this).data("id"), 10);
                    let newIndex = persistentBlips.findIndex((b) => b.id === bid);
                    if (newIndex === -1) return;
                    selectedBlip = newIndex;
                    highlightBlipByIndex(newIndex);
                });
            });
        });
    });

    finalOrderedBlips = [];
    $(".blips>div .blip")
        .not(".group-header")
        .each(function () {
            let ids = $(this).attr("data-ids").split(",");
            ids.forEach((idStr) => {
                let parsed = parseInt(idStr, 10);
                if (!isNaN(parsed)) finalOrderedBlips.push(parsed);
            });
        });
}

function selectNextGroup() {
    if (subGroups.length < 1) return;
    selectedInSub++;
    if (selectedInSub >= subGroups.length) {
        selectedInSub = subGroups.length - 1;
        if (allGroups.length <= visibleCount) return;
        subGroups.shift();
        ringStart = (ringStart + 1) % allGroups.length;
        let nextIndex = (ringStart + visibleCount - 1) % allGroups.length;
        let nextGroup = allGroups[nextIndex];
        if (!subGroups.includes(nextGroup)) subGroups.push(nextGroup);
        selectedInSub = subGroups.length - 1;
        renderSubGroups();
    }
    highlightCurrent();
}

function selectPrevGroup() {
    if (subGroups.length < 1) return;
    selectedInSub--;
    if (selectedInSub < 0) {
        selectedInSub = 0;
        if (allGroups.length <= visibleCount) return;
        subGroups.pop();
        ringStart = (ringStart - 1 + allGroups.length) % allGroups.length;
        let prevGroup = allGroups[ringStart];
        subGroups.unshift(prevGroup);
        selectedInSub = 0;
        renderSubGroups();
    }
    highlightCurrent();
}

function renderSubGroups() {
    blipsContainer.empty();
    $(".map-blip").remove();
    subGroups.forEach((g) => {
        let size = g.items.length;
        let label = size === 1 ? g.name : `${g.name} (${size})`;
        let ids = g.items.map((x) => x.id).join(",");
        let div = $(`
      <div class="blip" data-ids="${ids}">
        <p>${label}</p>
        <img src="${g.imgUrl}" alt="">
      </div>
    `);
        div.data("groupData", g);
        blipsContainer.append(div);
        div.on("mouseenter", function () {
            revertAllGroupNames();
            $(".blip").removeClass("active");
            $(this).addClass("active");
            $(".map-blip").removeClass("active");
            let gd = $(this).data("groupData");
            let idx = subGroups.indexOf(gd);
            selectedInSub = idx;
            if (gd.items.length < 2) {
                let b = gd.items[0];
                $(`.map-blip[data-id="${b.id}"]`).addClass("active");
                return;
            }
            let i = 0;
            $(this)
                .find("p")
                .text(`${gd.name} (${i + 1}/${gd.items.length})`);
            $(`.map-blip[data-id="${gd.items[i].id}"]`).addClass("active");
        });
        div.on("mouseleave", function () {
            let gd = $(this).data("groupData");
            if (gd.items.length === 1) $(this).find("p").text(gd.name);
            else $(this).find("p").text(`${gd.name} (${gd.items.length})`);
            $(this).removeClass("active");
            $(".map-blip").removeClass("active");
        });
    });
    subGroups.forEach((g) => {
        g.items.forEach((b) => {
            let html = `<img data-id="${b.id}" src="${b.imgUrl}" alt="" class="map-blip">`;
            mapWrapper.append(html);
            let { x, y } = barycentricInterpolation(b.coords);
            let c = $(`.map-blip[data-id="${b.id}"]`);
            c.data("coords", JSON.stringify({ x, y: -y }));
            let w = c.width();
            let h = c.height();
            x -= w / 2;
            y -= h / 2;
            c.css({ left: x, bottom: y });
        });
    });
    $(".map-blip").on("click", function () {
        revertAllGroupNames();
        $(".blip").removeClass("active");
        $(".map-blip").removeClass("active");
        let bid = $(this).data("id");
        let coords = JSON.parse($(this).data("coords"));
        coords.x -= 0;
        coords.y -= 0;
        let found = getGroupDataByBlipId(bid);
        if (found) {
            let groupData = found.data("groupData");
            let idx2 = subGroups.indexOf(groupData);
            if (idx2 >= 0) {
                selectedInSub = idx2;
                found.addClass("active");
                if (groupData.items.length === 1) {
                    found.find("p").text(groupData.name);
                } else {
                    let i2 = groupData.items.findIndex((x) => x.id === bid);
                    found.find("p").text(`${groupData.name} (${i2 + 1}/${groupData.items.length})`);
                }
            }
        }
        $(this).addClass("active");
        goToCoords(coords);
    });
}

function highlightCurrent() {
    if (selectedInSub < 0 || selectedInSub >= subGroups.length) return;
    let g = subGroups[selectedInSub];
    $(".blip").removeClass("active");
    let b = $(".blip").filter((i, el) => $(el).data("groupData") === g);
    b.addClass("active");
    $(".map-blip").removeClass("active");
    if (g.items.length > 0) {
        let first = g.items[0];
        $(`.map-blip[data-id="${first.id}"]`).addClass("active");
    }
}

function highlightBlipByIndex(index) {
    if (index === -1) {
        let p = JSON.parse(playerMarker.data("coords"));
        goToCoords(p);
        $(".blip").removeClass("active");
        revertAllGroupNames();
        return;
    }

    let blipId = persistentBlips[index].id;
    $(`.blip[data-ids*="${blipId}"]`).get(0)?.scrollIntoView({ block: "nearest" });

    let blip = $(`.map-blip[data-id="${blipId}"]`);
    if (!blip.length) return; // or throw an error if you prefer

    let c = JSON.parse(blip.data("coords"));
    c.y -= 10;
    c.x -= 10;

    revertAllGroupNames();
    $(".blip").removeClass("active");
    $(".map-blip").removeClass("active");

    let foundGroup = getGroupDataByBlipId(blipId);
    if (foundGroup) {
        foundGroup.addClass("active");
        let g = foundGroup.data("groupData");
        let idx = g.items.findIndex((x) => x.id === blipId);
        if (g.items.length === 1) {
            foundGroup.find("p").text(g.name);
        } else {
            foundGroup.find("p").text(`${g.name} (${idx + 1}/${g.items.length})`);
        }
    }
    blip.addClass("active");
    goToCoords(c);
}

// Recalculate blip opacity based on distance to center of the screen
function recalculateBlips() {
    if (calculating) return;
    calculating = true;
    var viewportWidth = $(window).width();
    var viewportHeight = $(window).height();
    var centerScreenX = viewportWidth / 2;
    var centerScreenY = viewportHeight / 2;

    var maxDistance = Math.sqrt(Math.pow(centerScreenX, 2) + Math.pow(centerScreenY, 2));

    $(".map-blip").each(function () {
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

// Convert game coordinates to map coordinates
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

// Convert map coordinates to game coordinates
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

// Center map on player coordinates
function goToPlayerCoords() {
    let playerCoords = JSON.parse(playerMarker.data("coords"));
    goToCoords(playerCoords);
}

const hardcodedBlips = [];
setBlips(hardcodedBlips);
setMapScale(1);
playerMarker.data("coords", JSON.stringify({ x: 2181, y: 556 }));

// Event listeners
Events.Subscribe("Map:AddBlip", function (blip) {
    persistentBlips.push(blip);
    setBlips(persistentBlips);
});

Events.Subscribe("Map:RemoveBlip", function (id) {
    persistentBlips = persistentBlips.filter((blip) => blip.id !== id);
    setBlips(persistentBlips);
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

// Event handler for setting blips

Events.Subscribe("SetBlips", (blips) => {
    allOriginalBlips = blips.slice();
    setBlips(blips);
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

Events.Subscribe("Map:UpdatePlayersPos", function (playerBlips) {
    if (!showPlayers) return;
    let updatedIds = new Set();
    for (let id in playerBlipElements) {
        if (!updatedIds.has(Number(id))) {
            playerBlipElements[id].remove();
            delete playerBlipElements[id];
        }
    }
    playerBlips.forEach((p) => {
        updatedIds.add(p.id);
        let blip = playerBlipElements[p.id];
        if (!blip) {
            blip = document.createElement("div");
            blip.className = "player-blip";
            blip.dataset.id = p.id;
            mapWrapper.append(blip);
            playerBlipElements[p.id] = blip;
        }
        let coords = barycentricInterpolation({ x: p.x, y: p.y });
        blip.style.position = "absolute";
        blip.style.left = coords.x + "px";
        blip.style.bottom = coords.y + "px";
    });
});
