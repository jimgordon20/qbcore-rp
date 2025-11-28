document.addEventListener("DOMContentLoaded", function () {
    let buttonParams = [];
    let images = [];

    function openMenu(buttons) {
        let html = "";
        buttons.forEach((item, index) => {
            if (!item.hidden) {
                let header = item.header;
                let message = item.txt || item.text;
                let isMenuHeader = item.isMenuHeader;
                let isDisabled = item.disabled;
                let icon = item.icon;
                images[index] = item;
                html += getButtonRender(header, message, index, isMenuHeader, isDisabled, icon);
                if (item.params) buttonParams[index] = item.params;
            }
        });
        $("#buttons").html(html);
        $(".button").click(function () {
            const target = $(this);
            if (!target.hasClass("title") && !target.hasClass("disabled")) {
                postData(target.attr("id"));
            }
        });
    }

    function getButtonRender(header, message = null, id, isMenuHeader, isDisabled, icon) {
        return `
            <div class="${isMenuHeader ? "title" : "button"} ${isDisabled ? "disabled" : ""}" id="${id}">
                <div class="icon"> <img src=${icon} width=30px onerror="this.onerror=null; this.remove();"> <i class="${icon}" onerror="this.onerror=null; this.remove();"></i> </div>
                <div class="column">
                <div class="header"> ${header}</div>
                ${message ? `<div class="text">${message}</div>` : ""}
                </div>
            </div>
        `;
    }

    function closeMenu() {
        $("#buttons").html(" ");
        $("#imageHover").css("display", "none");
        buttonParams = [];
        images = [];
    }

    function postData(id) {
        hEvent("clickedButton", JSON.stringify(parseInt(id) + 1));
        return closeMenu();
    }

    function cancelMenu() {
        hEvent("closeMenu");
        return closeMenu();
    }

    window.addEventListener("message", (event) => {
        const data = event.data;
        switch (data.name) {
            case "openMenu":
                return openMenu(data.args[0]);
            case "closeMenu":
                return closeMenu();
            default:
                return;
        }
    });

    function handleMouseDown(event) {
        if (event.button === 2) {
            cancelMenu();
        }
    }

    window.addEventListener("mousedown", handleMouseDown);

    window.addEventListener("unload", function () {
        window.removeEventListener("mousedown", handleMouseDown);
    });

    window.addEventListener("keydown", (event) => {
        if (event.key === "Escape") {
            if (event.cancelable) {
                event.preventDefault();
            }
            cancelMenu();
        }
    });
});
