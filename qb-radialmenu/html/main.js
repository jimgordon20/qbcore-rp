"use strict";
var QBRadialMenu = null;

$(document).ready(function () {
    window.addEventListener("message", function (event) {
        switch (event.data.name) {
            case "ui":
                const args = event.data.args[0];
                if (args.radial) {
                    createMenu(args.items);
                    QBRadialMenu.open();
                } else {
                    QBRadialMenu.close(true);
                }
        }
    });
});

function createMenu(items) {
    QBRadialMenu = new RadialMenu({
        parent: document.body,
        size: 375,
        menuItems: items,
        onClick: function (item) {
            if (item.shouldClose) {
                QBRadialMenu.close(true);
            }
            if (item.items == null && item.shouldClose != null) {
                hEvent("selectItem", { itemData: item });
            }
        },
    });
}
