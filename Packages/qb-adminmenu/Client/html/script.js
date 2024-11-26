document.addEventListener("DOMContentLoaded", () => {
    const menuItems = document.querySelectorAll(".menu-item");
    const adminOptions = [
        { name: "NoClip", command: "noclip" },
        { name: "Heal", command: "heal" },
        { name: "Kill", command: "kill" },
        { name: "Revive", command: "revive" },
        { name: "Revive All", command: "reviveall" },
        { name: "Invisible", command: "invisible" },
        { name: "Godmode", command: "godmode" },
        { name: "Names", command: "names" },
        { name: "Blips", command: "blips" },
    ];
    const devOptions = [
        { name: "Copy Vector", command: "coords" },
        { name: "Copy Rotation", command: "rotation" },
        { name: "Copy Heading", command: "heading" },
        { name: "Show Coords", command: "showcoords" },
        { name: "Teleport", command: "tp" },
        { name: "Laser", command: "laser" },
    ];
    const weaponOptions = [
        { name: "Spawn", command: "weapon" },
        { name: "Fix", command: "fixweapon" },
        { name: "Max Ammo", command: "maxammo" },
    ];
    const vehicleOptions = [
        { name: "Spawn", command: "car" },
        { name: "Fix", command: "fix" },
        { name: "Buy", command: "admincar" },
        { name: "Delete", command: "dv" },
        { name: "Max Mods", command: "maxmods" },
    ];
    const weatherOptions = [
        { name: "clear", command: "weather" },
        { name: "cloudy", command: "weather" },
        { name: "foggy", command: "weather" },
        { name: "overcast", command: "weather" },
        { name: "partlycloudy", command: "weather" },
        { name: "rain", command: "weather" },
        { name: "lightrain", command: "weather" },
        { name: "thunderstorm", command: "weather" },
        { name: "dust", command: "weather" },
        { name: "duststorm", command: "weather" },
        { name: "snow", command: "weather" },
        { name: "blizzard", command: "weather" },
        { name: "lightsnow", command: "weather" },
    ];
    const timeOptions = Array.from({ length: 25 }, (_, i) => ({ name: String(i).padStart(2, "0"), command: "time" }));
    timeOptions.push({ name: "Freeze Time", command: "freezetime" });

    let currentMenuItemIndex = 0;
    let currentOptionIndices = {
        "admin-options": 0,
        "dev-options": 0,
        "weapon-options": 0,
        "vehicle-options": 0,
        "weather-options": 0,
        "time-options": 0,
    };

    const inputContainer = document.getElementById("input-container");
    const inputBox = document.getElementById("input-box");
    const submitButton = document.getElementById("submit-button");

    function updateMenuItemSelection() {
        menuItems.forEach((item, index) => {
            if (index === currentMenuItemIndex) {
                item.classList.add("selected");
            } else {
                item.classList.remove("selected");
            }
        });
    }

    function updateOptionValue() {
        const selectedItem = menuItems[currentMenuItemIndex];
        const valueElement = selectedItem.querySelector(".value");
        const itemId = selectedItem.id;
        const optionsArray = itemId === "admin-options" ? adminOptions : itemId === "dev-options" ? devOptions : itemId === "weapon-options" ? weaponOptions : itemId === "vehicle-options" ? vehicleOptions : itemId === "weather-options" ? weatherOptions : timeOptions;
        const currentIndex = currentOptionIndices[itemId];
        valueElement.textContent = optionsArray[currentIndex].name;
    }

    function getSelectedOption() {
        const selectedItem = menuItems[currentMenuItemIndex];
        const itemId = selectedItem.id;
        const option = selectedItem.querySelector(".value").textContent;
        const command = itemId === "admin-options" ? adminOptions : itemId === "dev-options" ? devOptions : itemId === "weapon-options" ? weaponOptions : itemId === "vehicle-options" ? vehicleOptions : itemId === "weather-options" ? weatherOptions : timeOptions;
        const currentIndex = currentOptionIndices[itemId];
        return { itemId, option, command: command[currentIndex].command };
    }

    function performAction(itemId, option, command, inputValue) {
        const args = inputValue ? inputValue : option;
        const commandData = {
            name: command,
            argsString: args,
        };
        Events.Call("execute", commandData);
    }

    submitButton.addEventListener("click", () => {
        const inputValue = inputBox.value;
        const { itemId, option, command } = getSelectedOption();
        inputContainer.style.display = "none";
        inputBox.value = "";
        Events.Call("mouseInput", false);
        performAction(itemId, option, command, inputValue);
    });

    inputBox.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
            const inputValue = inputBox.value;
            const { itemId, option, command } = getSelectedOption();
            inputContainer.style.display = "none";
            inputBox.value = "";
            Events.Call("mouseInput", false);
            performAction(itemId, option, command, inputValue);
        }
    });

    Events.Subscribe("navigateUp", () => {
        currentMenuItemIndex = (currentMenuItemIndex - 1 + menuItems.length) % menuItems.length;
        updateMenuItemSelection();
    });

    Events.Subscribe("navigateDown", () => {
        currentMenuItemIndex = (currentMenuItemIndex + 1) % menuItems.length;
        updateMenuItemSelection();
    });

    Events.Subscribe("navigateLeft", () => {
        const selectedItem = menuItems[currentMenuItemIndex];
        const itemId = selectedItem.id;
        if (["admin-options", "dev-options", "weapon-options", "vehicle-options", "weather-options", "time-options"].includes(itemId)) {
            const optionsArray = itemId === "admin-options" ? adminOptions : itemId === "dev-options" ? devOptions : itemId === "weapon-options" ? weaponOptions : itemId === "vehicle-options" ? vehicleOptions : itemId === "weather-options" ? weatherOptions : timeOptions;
            currentOptionIndices[itemId] = (currentOptionIndices[itemId] - 1 + optionsArray.length) % optionsArray.length;
            updateOptionValue();
        }
    });

    Events.Subscribe("navigateRight", () => {
        const selectedItem = menuItems[currentMenuItemIndex];
        const itemId = selectedItem.id;
        if (["admin-options", "dev-options", "weapon-options", "vehicle-options", "weather-options", "time-options"].includes(itemId)) {
            const optionsArray = itemId === "admin-options" ? adminOptions : itemId === "dev-options" ? devOptions : itemId === "weapon-options" ? weaponOptions : itemId === "vehicle-options" ? vehicleOptions : itemId === "weather-options" ? weatherOptions : timeOptions;
            currentOptionIndices[itemId] = (currentOptionIndices[itemId] + 1) % optionsArray.length;
            updateOptionValue();
        }
    });

    Events.Subscribe("select", () => {
        const { itemId, option, command } = getSelectedOption();
        if ((itemId === "vehicle-options" && option === "Spawn") || (itemId === "weapon-options" && option === "Spawn") || (itemId === "dev-options" && option === "Teleport")) {
            inputContainer.style.display = "block";
            inputBox.focus();
            Events.Call("mouseInput", true);
        } else {
            performAction(itemId, option, command);
        }
    });

    updateMenuItemSelection();
    menuItems.forEach(updateOptionValue);
});
