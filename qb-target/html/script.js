document.addEventListener("DOMContentLoaded", function () {
    const config = {
        StandardEyeIcon: "fas fa-eye",
        StandardColor: "white",
        SuccessColor: "#DC143C",
    };

    const targetEye = document.getElementById("target-eye");
    const targetLabel = document.getElementById("target-label");
    const TargetEyeStyleObject = targetEye.style;

    function openTarget() {
        targetLabel.textContent = "";
        targetEye.style.display = "block";
        targetEye.className = config.StandardEyeIcon;
        TargetEyeStyleObject.color = config.StandardColor;
    }

    function closeTarget() {
        targetLabel.textContent = "";
        targetEye.style.display = "none";
    }

    function createTargetOption(index, itemData) {
        if (itemData !== null) {
            index = Number(index) + 1;
            const targetOption = document.createElement("div");
            targetOption.id = `target-option-${index}`;
            targetOption.style.marginBottom = "0.2vh";
            targetOption.style.borderRadius = "0.15rem";
            targetOption.style.padding = "0.45rem";
            targetOption.style.background = "rgba(23, 23, 23, 40%)";
            targetOption.style.color = config.StandardColor;
            const targetIcon = document.createElement("span");
            targetIcon.id = `target-icon-${index}`;
            const icon = document.createElement("i");
            icon.className = itemData.icon;
            targetIcon.appendChild(icon);
            targetIcon.appendChild(document.createTextNode(" "));
            targetOption.appendChild(targetIcon);
            targetOption.appendChild(document.createTextNode(itemData.label));
            targetLabel.appendChild(targetOption);
        }
    }

    function foundTarget(item) {
        if (item.data) {
            targetEye.className = item.data;
        }
        TargetEyeStyleObject.color = config.SuccessColor;
        targetLabel.textContent = "";
        for (let [index, itemData] of Object.entries(item.options)) {
            createTargetOption(index, itemData);
        }
    }

    function validTarget(item) {
        targetLabel.textContent = "";
        for (let [index, itemData] of Object.entries(item.data)) {
            createTargetOption(index, itemData);
        }
    }

    function leftTarget() {
        targetLabel.textContent = "";
        TargetEyeStyleObject.color = config.StandardColor;
        targetEye.className = config.StandardEyeIcon;
    }

    function handleMouseDown(event) {
        const element = event.target; // use const instead of let
        if (element.id) {
            const split = element.id.split("-");
            if (split[0] === "target" && split[1] !== "eye" && event.button === 0) {
                hEvent("selectTarget", split[2]);
                targetLabel.textContent = "";
            }
        }
        if (event.button === 2) {
            leftTarget();
            hEvent("leftTarget");
        }
    }

    function handleKeyDown(event) {
        if (event.key === "Escape" || event.key === "Backspace") {
            closeTarget();
            hEvent("closeTarget");
        }
    }

    function handleMouseOver(event) {
        const element = event.target;
        if (element.id) {
            const split = element.id.split("-");
            if (split[0] === "target" && split[1] === "option") {
                element.style.transform = "translateX(10px)";
                element.style.transition = "transform 0.3s ease";
            }
        }
    }

    function handleMouseOut(event) {
        const element = event.target;
        if (element.id) {
            const split = element.id.split("-");
            if (split[0] === "target" && split[1] === "option") {
                element.style.transform = "translateX(0)";
            }
        }
    }

    window.openTarget = openTarget;
    window.closeTarget = closeTarget;
    window.foundTarget = foundTarget;
    window.validTarget = validTarget;
    window.leftTarget = leftTarget;

    window.addEventListener("mousedown", handleMouseDown);
    window.addEventListener("keydown", handleKeyDown);
    window.addEventListener("mouseover", handleMouseOver);
    window.addEventListener("mouseout", handleMouseOut);

    window.addEventListener("unload", function () {
        window.removeEventListener("mousedown", handleMouseDown);
        window.removeEventListener("keydown", handleKeyDown);
        window.removeEventListener("mouseover", handleMouseOver);
        window.removeEventListener("mouseout", handleMouseOut);
    });
});
